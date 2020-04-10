//
//  ImageLoader.swift
//  TestSwiftUI
//
//  Created by Nicolas Jakubowski on 4/7/20.
//  Copyright © 2020 nicolasjakubowski. All rights reserved.
//

import Foundation
import Combine
import UIKit

/// Takes care of loading images from a remote server.
class ImageLoader: ObservableObject, Identifiable {
    @Published var image: UIImage?
    
    let id = UUID()
    let url: URL
    
    private var imageLoadingCancellable: AnyCancellable?
    
    init(url: URL) {
        self.url = url
        imageLoadingCancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .compactMap { UIImage(data: $0) }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { self.image = $0 })
    }
}
