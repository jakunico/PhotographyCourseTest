//
//  PlayerView.swift
//  TestSwiftUI
//
//  Created by Nicolas Jakubowski on 4/7/20.
//  Copyright © 2020 nicolasjakubowski. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import SwiftUI

struct VideoPlayer: UIViewControllerRepresentable {
    
    @State var videoUrl: URL
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let playerViewController = AVPlayerViewController()
        playerViewController.player = AVPlayer(url: videoUrl)
        playerViewController.player?.play()
        return playerViewController
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        
    }
}
