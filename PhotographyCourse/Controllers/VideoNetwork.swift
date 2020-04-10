//
//  VideoNetwork.swift
//  PhotographyCourse
//
//  Created by Nicolas Jakubowski on 4/10/20.
//  Copyright © 2020 Nicolas Jakubowski. All rights reserved.
//

import Foundation
import Combine

class VideoNetwork {
    let app: App
    var state: AppState { app.state }
    var network: Network { app.network }
    var videoDownloader: VideoDownloader { app.videoDownloader }
    var videoListCache: Cache<[Video]> { app.videoListCache }
    var videoDownloadsCache: Cache<VideoDownloadLinker> { app.videoDownloadsCache }
    
    private var getVideosCancellable: AnyCancellable?
    
    init(app: App) {
        self.app = app
        
        videoDownloader.downloadFailedHandler = { [weak self] url, error in
            self?.state.videos
                .filter({ $0.video == url })
                .forEach({ $0.downloadError = error })
        }
        
        videoDownloader.downloadCompletedHandler = { [weak self] video, urlInDisk in
            
            guard let `self` = self else { return }
            
            self.state.videos
                .filter({ $0.video == video })
                .forEach({
                    $0.videoUrlInDisk = urlInDisk
                })
            
            do {
                var linker = try self.videoDownloadsCache.retrieve() ?? VideoDownloadLinker(entries: [:])
                linker.entries[video] = urlInDisk
                try self.videoDownloadsCache.store(linker)
            } catch {
                print("VideoLoader: Finished download a video but was unable to create the link between the VideoURL and the VideoURLInDisk")
            }
            
        }
        
        videoDownloader.downloadProgress = { [weak self] url, progress in
            self?.state.videos
                .filter({ $0.video == url })
                .forEach({ $0.downloadProgress = progress })
        }
    }
    
    func getVideos() {
        guard !state.isLoadingVideos else { return }
        
        state.isLoadingVideos = true
        state.videoLoadingError = nil
        
        let url = URL(string: "https://iphonephotographyschool.com/test-api/videos")!
        
        let handleSuccess: ([Video], Bool) -> Void = { videos, isFromCache in
            
            if !isFromCache {
                do {
                    try self.videoListCache.store(videos)
                } catch {
                    print("Unable to store video list in cache: \(error)")
                }
            }
            
            videos.forEach { video in
                video.video = URL(string: "https://bitdash-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8")!
                video.videoUrlInDisk = self.videoUrlInDisk(for: video)
            }
            
            self.state.videos = videos
        }
        
        let handleError: (Error) -> Void = { error in
            if let videos = try? self.videoListCache.retrieve(), videos.count > 0 {
                handleSuccess(videos, true)
            } else {
                self.state.videoLoadingError = error
            }
        }
        
        getVideosCancellable = network
            .getVideos(url: url)
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
    
    func downloadVideo(video: Video) {
        guard video.videoUrlInDisk == nil else { return } // already downloaded
        video.downloadError = nil // clear any previous error
        videoDownloader.downloadVideo(video)
    }
    
    func cancelDownload(video: Video) {
        videoDownloader.cancelDownload(for: video)
        video.downloadProgress = nil
    }
    
    private func videoUrlInDisk(for video: Video) -> URL? {
        guard let linker = try? self.videoDownloadsCache.retrieve() else { return nil }
        return linker.entries[video.video]
    }
}
