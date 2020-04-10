//
//  VideosResponse.swift
//  PhotographyCourse
//
//  Created by Nicolas Jakubowski on 4/10/20.
//  Copyright © 2020 Nicolas Jakubowski. All rights reserved.
//

import Foundation

class VideosResponse: Decodable {
    let videos: [Video]
    
    enum CodingKeys: String, CodingKey {
        case videos
    }
}
