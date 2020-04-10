//
//  VideoNetwork.swift
//  PhotographyCourse
//
//  Created by Nicolas Jakubowski on 4/10/20.
//  Copyright © 2020 Nicolas Jakubowski. All rights reserved.
//

import Foundation
import Combine

/// This `VideoNetwork` interfaces between the `Network` and the app.
/// Upon request it will fetch videos and put them in the `State`.
/// Will also handle callbacks from the `VideoDownloader`and update the `State` as well.
class VideoNetwork {
    let app: App
    
    private var state: AppState { app.state }
    private var network: Network { app.network }
    private var videoDownloader: VideoDownloader { app.videoDownloader }
    private var videoListCache: Cache<[Video]> { app.videoListCache }
    private var videoDownloadsCache: Cache<VideoDownloadLinker> { app.videoDownloadsCache }
    
    private var getVideosCancellable: AnyCancellable?
    
    init(app: App) {
        self.app = app
        
        // Register the handlers for the video downloads
        
        videoDownloader.downloadFailedHandler = { [weak self] url, error in
            self?.videoDownloadDidFail(url: url, error: error)
        }
        
        videoDownloader.downloadCompletedHandler = { [weak self] remoteVideoUrl, localVideoUrl in
            self?.videoDownloadDidComplete(remoteUrl: remoteVideoUrl, localUrl: localVideoUrl)
        }
        
        videoDownloader.downloadProgress = { [weak self] url, progress in
            self?.videoDownloadDidProgress(url: url, progress: progress)
        }
    }
    
}

// MARK: - Video List

extension VideoNetwork {
    
    private var videoListUrl: URL { URL(string: "https://iphonephotographyschool.com/test-api/videos")! }
    
    /// Fetches the video list and puts it into the `AppState.videos` property.
    /// If something goes wrong the error is put into the `AppState.videoLoadingError` property.
    func getVideosList() {
        guard !state.isLoadingVideos else { return }
        
        state.isLoadingVideos = true
        state.videoLoadingError = nil
        
        // Success handler for the request
        let handleSuccess: ([Video], Bool) -> Void = { videos, isFromCache in
            
            // Store this data in cache so that it is available without connection later
            
            if !isFromCache {
                do {
                    try self.videoListCache.store(videos)
                } catch {
                    print("VideoNetwork: Unable to store video list in cache: \(error)")
                }
            }
            
            // Update the localVideoUrl for each video
            
            videos.forEach { video in
                video.localVideoUrl = self.localVideoUrl(for: video)
            }
            
            self.state.videos = videos
        }
        
        // Error handler for the request
        let handleError: (Error) -> Void = { error in
            do {
                // Attempt to load the videos from cache
                if let videos = try self.videoListCache.retrieve(), videos.count > 0 {
                    handleSuccess(videos, true)
                } else {
                    self.state.videoLoadingError = error
                }
            } catch let thrownError {
                print("VideoNetwork: Unable to read from cache: \(thrownError)")
                self.state.videoLoadingError = error
            }
        }
        
        // Make the request
        getVideosCancellable = network
            .getVideos(url: videoListUrl)
            .map { $0.videos }
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished: break
                case .failure(let error): handleError(error)
                }
                self.state.isLoadingVideos = false
            }, receiveValue: { value in
                handleSuccess(value, false)
            })
    }
    
}

// MARK: - Video Download

extension VideoNetwork {
    
    /// Initiates the download for the given video.
    /// If the video is already downloaded the call is ignored.
    func downloadVideo(video: Video) {
        guard video.localVideoUrl == nil else { return } // already downloaded
        video.downloadError = nil // clear any previous error
        videoDownloader.downloadVideo(video)
    }
    
    /// Cancels the download for the given video.
    func cancelDownload(video: Video) {
        videoDownloader.cancelDownload(for: video)
        video.downloadProgress = nil
    }
    
    /// Called when the download of a video updates.
    fileprivate func videoDownloadDidProgress(url: RemoteVideoURL, progress: Double) {
        state.videos
            .filter({ $0.remoteVideoUrl == url })
            .forEach({ $0.downloadProgress = progress })
    }
    
    /// Called when the download of a video fails.
    fileprivate func videoDownloadDidFail(url: RemoteVideoURL, error: Error) {
        state.videos
            .filter({ $0.remoteVideoUrl == url })
            .forEach({ $0.downloadError = error })
    }
    
    /// Called when the download of a video completes.
    fileprivate func videoDownloadDidComplete(remoteUrl: RemoteVideoURL, localUrl: LocalVideoURL) {
        state.videos
            .filter({ $0.remoteVideoUrl == remoteUrl })
            .forEach({
                $0.localVideoUrl = localUrl
            })
        
        link(remoteVideoUrl: remoteUrl, with: localUrl)
    }
    
}

// MARK: - VideoDownloadLinker Methods

private extension VideoNetwork {
    
    /// Links the given remote video with a local video.
    func link(remoteVideoUrl: RemoteVideoURL, with localVideoUrl: LocalVideoURL) {
        do {
            var linker = try self.videoDownloadsCache.retrieve() ?? VideoDownloadLinker(entries: [:])
            linker.entries[remoteVideoUrl] = localVideoUrl
            try self.videoDownloadsCache.store(linker)
        } catch {
            print("VideoNetwork: Finished download a video but was unable to create the link between the VideoURL and the localVideoUrl: \(error)")
        }
    }
    
    /// Returns the local video URL for the given video or `nil` if the video is now downloaded.
    func localVideoUrl(for video: Video) -> LocalVideoURL? {
        do {
            if let linker = try self.videoDownloadsCache.retrieve() {
                return linker.entries[video.remoteVideoUrl]
            }
        }catch {
            print("VideoNetwork: Unable to read the video downloads cache: \(error)")
        }
        
        return nil
    }
}
