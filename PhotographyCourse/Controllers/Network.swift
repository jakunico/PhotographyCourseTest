//
//  Network.swift
//  PhotographyCourse
//
//  Created by Nicolas Jakubowski on 8/4/20.
//  Copyright © 2020 Nicolas Jakubowski. All rights reserved.
//

import Foundation
import Combine

class Network {
    
    func getVideos(url: URL) -> AnyPublisher<VideosResponse, Error> {
        return get(url: url)
    }
    
    private func get<T: Decodable>(url: URL) -> AnyPublisher<T, Error> {
        return URLSession.shared
            .dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: T.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
        
    }
    
}
