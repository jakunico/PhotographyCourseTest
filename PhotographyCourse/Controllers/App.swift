//
//  App.swift
//  PhotographyCourse
//
//  Created by Nicolas Jakubowski on 4/10/20.
//  Copyright © 2020 Nicolas Jakubowski. All rights reserved.
//

import Foundation

class App: ObservableObject {
    let state = AppState()
    let network = Network()
    let videoListCache = Cache(identifier: "videoList")
    let videoDownloadsCache = Cache(identifier: "videoDownloads")
    let videoDownloader = VideoDownloader()
    
    lazy private(set) var videoLoader = VideoLoader(app: self)
}

class AppState: ObservableObject {
    @Published var videos: [Video] = []
    @Published var isLoadingVideos = false
    @Published var videoLoadingError: Error?
}
