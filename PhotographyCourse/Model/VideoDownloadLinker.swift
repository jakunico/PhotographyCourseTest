//
//  VideoDownloadLinker.swift
//  PhotographyCourse
//
//  Created by Nicolas Jakubowski on 4/10/20.
//  Copyright © 2020 Nicolas Jakubowski. All rights reserved.
//

import Foundation

struct VideoDownloadLinker: Codable {
    typealias LocalVideoURL = URL
    typealias RemoteVideoURL = URL
    
    var entries: [RemoteVideoURL: LocalVideoURL]
}
