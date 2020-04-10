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

class ImageLoader: ObservableObject, Identifiable {
    @Published var image: UIImage?
    
    let id = UUID()
    let url: URL
    
    init(url: URL, completion: @escaping (UIImage?) -> Void) {
        self.url = url
        URLSession.shared.dataTask(with: url, completionHandler: { data, _, error in
            guard error == nil else { return }
            self.image = UIImage(data: data!)
            DispatchQueue.main.async { completion(self.image) }
        }).resume()
    }
}
