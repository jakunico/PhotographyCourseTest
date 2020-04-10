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

class Video: Identifiable, Codable, ObservableObject {
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case thumbnail
        case description
        case video = "video_link"
    }
    
    var id: Int
    var name: String
    var thumbnail: URL
    var description: String
    var video: URL
    
    init(id: Int, name: String, thumbnail: URL, description: String, video: URL) {
        self.id = id
        self.name = name
        self.thumbnail = thumbnail
        self.description = description
        self.video = video
        self.imageLoader = ImageLoader(url: thumbnail) { self.image = $0 }
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try values.decode(Int.self, forKey: .id)
        self.name = try values.decode(String.self, forKey: .name)
        self.thumbnail = try values.decode(URL.self, forKey: .thumbnail)
        self.description = try values.decode(String.self, forKey: .description)
        self.video = try values.decode(URL.self, forKey: .video)
        self.imageLoader = ImageLoader(url: thumbnail) { self.image = $0 }
    }
    
    @Published var image: UIImage?
    @Published var videoUrlInDisk: URL? = nil
    @Published var downloadError: Error?
    @Published var downloadProgress: Double?
    
    var urlForVideoPlayer: URL { videoUrlInDisk ?? video }
    
    private var imageLoader: ImageLoader!
}