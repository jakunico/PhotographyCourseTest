//
//  Network.swift
//  PhotographyCourse
//
//  Created by Nicolas Jakubowski on 8/4/20.
//  Copyright © 2020 Nicolas Jakubowski. All rights reserved.
//

import Foundation
import Combine

/// Provides access to all the endpoints in the API.
class Network {
    func getVideos(url: URL) -> AnyPublisher<VideosResponse, Error> {
        return get(url: url)
    }
}

// MARK: - Private extension with standard HTTP operations

private extension Network {
    func get<T: Decodable>(url: URL) -> AnyPublisher<T, Error> {
        return URLSession.shared
            .dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: T.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
        
    }
}
