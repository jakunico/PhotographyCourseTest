//
//  VideoDownloader.swift
//  PhotographyCourse
//
//  Created by Nicolas Jakubowski on 4/10/20.
//  Copyright © 2020 Nicolas Jakubowski. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import Combine

/// Takes care of downloading the videos into disk.
/// Videos are stored in a folder controlled by iOS and cannot be moved from there.
/// You may access videos downloaded on the device through the Settings.app > General > iPhone Storage.
class VideoDownloader: NSObject {
    
    private var session: AVAssetDownloadURLSession!
    private var applicationBecameActiveSubscriber: AnyCancellable!
    
    /// Called to inform of the download progress of a video (identified with the URL) is updated.
    var downloadProgress: (RemoteVideoURL, Double) -> Void = { _, _ in }
    
    /// Called when the download for a given video (identified with the URL) fails.
    var downloadFailedHandler: (RemoteVideoURL, Error) -> Void = { _, _ in }
    
    /// Called when the download for a given video (identified with the first URL parameter) succeeds.
    /// The second URL parameter is the location where the video is stored, should not be copied or moved from there as this is not allowed by the OS.
    /// You are in charge of storing this URL somewhere to persist this video location.
    var downloadCompletedHandler: (RemoteVideoURL, LocalVideoURL) -> Void = { _, _ in }
    
    override init() {
        super.init()
        session = AVAssetDownloadURLSession(configuration: .background(withIdentifier: "com.nicolasjakubowski.VideoDownloader"), assetDownloadDelegate: self, delegateQueue: .main)
        resumeExistingDownloadTasks()
        registerForApplicationBecomingActiveToResumeDownloads()
    }
    
    /// Initiates the download for the given video.
    /// If an existing download for it is found, that will be resumed instead.
    func downloadVideo(_ video: Video) {
        
        func createNewDownload() {
            let url = video.video
            let asset = AVURLAsset(url: url)
            if let task = session.makeAssetDownloadTask(asset: asset, assetTitle: video.name, assetArtworkData: nil, options: nil) {
                task.resume()
            } else {
                print("VideoDownloader: Failed to create download task for video with id \(video.id)")
            }
        }
        
        getExistingDownloadTask(for: video) { task in
            if let task = task {
                task.resume()
            } else {
                createNewDownload()
            }
        }
    }
    
    /// Cancels the download for the given video.
    /// If the video is not being downloaded then it does nothing.
    func cancelDownload(for video: Video) {
        session.getAllTasks { tasks in
            tasks
                .compactMap({ $0 as? AVAssetDownloadTask })
                .filter({ $0.urlAsset.url == video.video })
                .filter({ $0.state == .running })
                .forEach({ $0.cancel() })
        }
    }
    
    /// Returns an existing download task for the given Video.
    private func getExistingDownloadTask(for video: Video, completion: @escaping (AVAssetDownloadTask?) -> Void) {
        session.getAllTasks { tasks in
            if let existingTask = tasks
                .compactMap({ $0 as? AVAssetDownloadTask })
                .filter({ $0.urlAsset.url == video.video })
                .first {
                
                existingTask.resume()
                completion(existingTask)
            } else {
                completion(nil)
            }
        }
    }
    
    /// Searches for existing downloads and resumes them.
    private func resumeExistingDownloadTasks() {
        session.getAllTasks { tasks in
            tasks
                .compactMap({ $0 as? AVAssetDownloadTask })
                .forEach { $0.resume() }
        }
    }
    
    /// Registers for application becoming active.
    private func registerForApplicationBecomingActiveToResumeDownloads() {
        applicationBecameActiveSubscriber = NotificationCenter
            .default
            .publisher(for: UIApplication.didBecomeActiveNotification)
            .sink(receiveValue: { [weak self] _ in
                
                // Without this call any existing download that a previous session of the app would have created where not firing delegate calls.
                self?.resumeExistingDownloadTasks()
            })
    }
}

// MARK: - AVAssetDownloadDelegate

extension VideoDownloader: AVAssetDownloadDelegate {
    
    /// Called to inform progress of a video download.
    func urlSession(_ session: URLSession, assetDownloadTask: AVAssetDownloadTask, didLoad timeRange: CMTimeRange, totalTimeRangesLoaded loadedTimeRanges: [NSValue], timeRangeExpectedToLoad: CMTimeRange) {
        let progress = loadedTimeRanges.reduce(0.0, { $0 + $1.timeRangeValue.duration.seconds / timeRangeExpectedToLoad.duration.seconds })
        downloadProgress(assetDownloadTask.urlAsset.url, progress)
    }
    
    /// Called when the download finishes, EITHER SUCCESSFULLY OR NOT.
    /// The `location` parameter points to the downloaded file.
    /// This file might be downloaded completely or not, to know you have to analyze the `assetDownloadTask.error` property.
    /// Will still call `urlSession(_:task:didCompleteWithError:)` after this.
    /// If the download does not even start for some reason, this method will not be called and the `urlSession(_:task:didCompleteWithError:)` will be called instead.
    func urlSession(_ session: URLSession, assetDownloadTask: AVAssetDownloadTask, didFinishDownloadingTo location: URL) {
        if let error = assetDownloadTask.error  {
            handleDownloadError(task: assetDownloadTask, error: error)
        } else if assetDownloadTask.state != .canceling {
            downloadCompletedHandler(assetDownloadTask.urlAsset.url, location)
        }
    }
    
    /// Called when the download completes.
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error, let downloadTask = task as? AVAssetDownloadTask {
            handleDownloadError(task: downloadTask, error: error)
        }
    }
    
    private func handleDownloadError(task: AVAssetDownloadTask, error: Error) {
        #if targetEnvironment(simulator)
        
        // The feature to download assets is not available in the simulator, it will fail immediately upon initiating the download.
        // In order to test this feature you must use a real device.
        
        let message = "Downloading videos in the simulator is not supported. You must use a real device to test this feature."
        let error = NSError.errorWithLocalizedDescription(message)
        downloadFailedHandler(task.urlAsset.url, error)
        
        #else
        
        let nsError = error as NSError
        if nsError.code == NSURLErrorCancelled {
            // Cancelled by the user, not need to do anything here.
        } else if let videoUrl = nsError.userInfo[NSURLErrorFailingURLErrorKey] as? URL {
            downloadFailedHandler(videoUrl, error)
        } else {
            print("VideoDownloader: The download of a video failed but we don't have the URL to remove that file from disk.")
        }
        
        #endif
    }
}
