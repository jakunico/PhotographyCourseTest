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

class VideoDownloader: NSObject, AVAssetDownloadDelegate {
    private var session: AVAssetDownloadURLSession!
    private var applicationBecameActiveSubscriber: AnyCancellable!
    
    /// Called to inform of the download progress of a video (identified with the URL) is updated.
    var downloadProgress: (URL, Double) -> Void = { _, _ in }
    
    /// Called when the download for a given video (identified with the URL) fails.
    var downloadFailedHandler: (URL, Error) -> Void = { _, _ in }
    
    /// Called when the download for a given video (identified with the first URL parameter) succeeds.
    /// The second URL parameter is the location where the video is stored, should not be copied or moved from there as this is not allowed by the OS.
    /// You are in charge of storing this URL somewhere to persist this video location.
    var downloadCompletedHandler: (URL, URL) -> Void = { _, _ in }
    
    override init() {
        super.init()
        session = AVAssetDownloadURLSession(configuration: .background(withIdentifier: "com.nicolasjakubowski.VideoDownloader"), assetDownloadDelegate: self, delegateQueue: .main)
        resumeExistingDownloadTasks()
        registerForApplicationBecomingActiveToResumeDownloads()
    }
    
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
    
    func cancelDownload(for video: Video) {
        session.getAllTasks { tasks in
            tasks
                .compactMap({ $0 as? AVAssetDownloadTask })
                .filter({ $0.urlAsset.url == video.video })
                .filter({ $0.state == .running })
                .forEach({ $0.cancel() })
        }
    }
    
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
    
    private func resumeExistingDownloadTasks() {
        session.getAllTasks { tasks in
            tasks
                .compactMap({ $0 as? AVAssetDownloadTask })
                .forEach { $0.resume() }
        }
    }
    
    private func registerForApplicationBecomingActiveToResumeDownloads() {
        applicationBecameActiveSubscriber = NotificationCenter
            .default
            .publisher(for: UIApplication.didBecomeActiveNotification)
            .sink(receiveValue: { [weak self] _ in
                self?.resumeExistingDownloadTasks()
            })
        
    }
    
    private func handleDownloadError(task: AVAssetDownloadTask, error: Error) {
        #if targetEnvironment(simulator)
        
        let error = NSError(domain: "com.nicolasjakowski.VideoDownloader",
                            code: 9000,
                            userInfo: [NSLocalizedDescriptionKey:"Downloading videos in the simulator is not supported. You must use a real device to test this feature."])
        downloadFailedHandler(task.urlAsset.url, error)
        
        #else
        
        let nsError = error as NSError
        if nsError.code == NSURLErrorCancelled {
            // Cancelled by the user
        } else if let videoUrl = nsError.userInfo[NSURLErrorFailingURLErrorKey] as? URL {
            downloadFailedHandler(videoUrl, error)
        } else {
            print("The download of a video failed but we don't have the URL to remove that file from disk.")
        }
        
        #endif
    }
    
    func urlSession(_ session: URLSession, assetDownloadTask: AVAssetDownloadTask, didLoad timeRange: CMTimeRange, totalTimeRangesLoaded loadedTimeRanges: [NSValue], timeRangeExpectedToLoad: CMTimeRange) {
        let progress = loadedTimeRanges.reduce(0.0, { $0 + $1.timeRangeValue.duration.seconds / timeRangeExpectedToLoad.duration.seconds })
        downloadProgress(assetDownloadTask.urlAsset.url, progress)
    }
    
    func urlSession(_ session: URLSession, assetDownloadTask: AVAssetDownloadTask, didFinishDownloadingTo location: URL) {
        if let error = assetDownloadTask.error  {
            handleDownloadError(task: assetDownloadTask, error: error)
        } else if assetDownloadTask.state != .canceling {
            UserDefaults.standard.set(location, forKey: "downloadURL")
            downloadCompletedHandler(assetDownloadTask.urlAsset.url, location)
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error, let downloadTask = task as? AVAssetDownloadTask {
            handleDownloadError(task: downloadTask, error: error)
        }
    }
}
