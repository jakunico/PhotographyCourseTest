//
//  App.swift
//  PhotographyCourse
//
//  Created by Nicolas Jakubowski on 4/10/20.
//  Copyright © 2020 Nicolas Jakubowski. All rights reserved.
//

import Foundation

/// The super object of this app, root of the model graph.
class App: ObservableObject {
    let state = AppState()
    let network = Network()
    let videoListCache = Cache<[Video]>(identifier: "videoList")
    let videoDownloadsCache = Cache<VideoDownloadLinker>(identifier: "videoDownloads")
    let videoDownloader = VideoDownloader()
    
    lazy private(set) var videoLoader = VideoNetwork(app: self)
}

/// The state of the App, observed by the UI.
class AppState: ObservableObject {
    
    /// The list of videos to be listed in the Video List screen.
    @Published var videos: [Video] = []
    
    /// Indicates whether we are loading the video list or not.
    @Published var isLoadingVideos = false
    
    /// Indicates if the video list failed to load.
    @Published var videoLoadingError: Error?
}
