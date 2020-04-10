//
//  Video.swift
//  TestSwiftUI
//
//  Created by Nicolas Jakubowski on 4/6/20.
//  Copyright © 2020 nicolasjakubowski. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

typealias LocalVideoURL = URL
typealias RemoteVideoURL = URL

class Video: Identifiable, Codable, ObservableObject {
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case thumbnail
        case description
        case remoteVideoUrl = "video_link"
    }
    
    var id: Int
    var name: String
    var thumbnail: URL
    var description: String
    var remoteVideoUrl: RemoteVideoURL
    
    init(id: Int, name: String, thumbnail: URL, description: String, remoteVideoUrl: RemoteVideoURL) {
        self.id = id
        self.name = name
        self.thumbnail = thumbnail
        self.description = description
        self.remoteVideoUrl = remoteVideoUrl
        self.imageLoader = ImageLoader(url: thumbnail)
        self.imageLoaderAssignmentCancellable = self.imageLoader.$image.assign(to: \.image, on: self)
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try values.decode(Int.self, forKey: .id)
        self.name = try values.decode(String.self, forKey: .name)
        self.thumbnail = try values.decode(URL.self, forKey: .thumbnail)
        self.description = try values.decode(String.self, forKey: .description)
        self.remoteVideoUrl = try values.decode(URL.self, forKey: .remoteVideoUrl)
        self.imageLoader = ImageLoader(url: thumbnail)
        self.imageLoaderAssignmentCancellable = self.imageLoader.$image.assign(to: \.image, on: self)
    }
    
    /// The thumbnail loaded from the remote server or `nil`if it is not available yet.
    @Published var image: UIImage?
    
    /// The URL to file the file in disk that contains the downloaded file of this video or `nil` if this video has not been downloaded yet.
    @Published var localVideoUrl: LocalVideoURL?
    
    /// The error that happened while downloading this video or `nil`if there is no error yet.
    @Published var downloadError: Error?
    
    /// The progress of the download of this video or `nil` if the video is not being downloaded.
    @Published var downloadProgress: Double?
    
    /// The `URL`to be used by the Video Player control.
    var urlForVideoPlayer: URL { localVideoUrl ?? remoteVideoUrl }
    
    private var imageLoader: ImageLoader
    private var imageLoaderAssignmentCancellable: AnyCancellable?
}
