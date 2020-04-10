//
//  SampleVideoStore.swift
//  TestSwiftUI
//
//  Created by Nicolas Jakubowski on 4/6/20.
//  Copyright © 2020 nicolasjakubowski. All rights reserved.
//

import Foundation
import SwiftUI

/// A sample video store to provide a model for SwiftUI previews.
class SampleVideoStore {
    
    static let all = [
        SampleVideoStore.notDownloaded,
        SampleVideoStore.downloading,
        SampleVideoStore.downloadFailed,
        SampleVideoStore.downloaded,
        SampleVideoStore.withImage
    ]
    
    static let notDownloaded = Video(id: 1,
                                     name: "This video is not downloaded",
                                     thumbnail: URL(string: "https://picsum.photos/600/400")!,
                                     description: veryLongText,
                                     remoteVideoUrl: URL(string: "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8")!)
    
    static let downloading: Video = {
        let video = Video(id: 2,
                          name: "This Video Is Downloading",
                          thumbnail: URL(string: "https://picsum.photos/600/400")!,
                          description: veryLongText,
                          remoteVideoUrl: URL(string: "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8")!)
        video.downloadProgress = 0.58
        return video
    }()
    
    static let downloadFailed: Video = {
        let video = Video(id: 3,
                          name: "This Video download failed",
                          thumbnail: URL(string: "https://picsum.photos/600/400")!,
                          description: veryLongText,
                          remoteVideoUrl: URL(string: "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8")!)
        video.downloadError = NSError(domain: "com.nicolasjakubowski.thisapp", code: 9000, userInfo: [NSLocalizedDescriptionKey:"You are not connected to internet."])
        return video
    }()
    
    static let downloaded = Video(id: 4,
                                  name: "This Video Is Downloaded",
                                  thumbnail: URL(string: "https://picsum.photos/600/400")!,
                                  description: veryLongText,
                                  remoteVideoUrl: URL(string: "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8")!)
    
    static let withImage: Video = {
        let video = Video(id: 5,
                          name: "This has an image loaded in memory",
                          thumbnail: URL(string: "https://picsum.photos/600/400")!,
                          description: veryLongText,
                          remoteVideoUrl: URL(string: "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8")!)
        video.image = UIImage(named: "sample_video")
        return video
    }()
    
    
}

private let veryLongText = """
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla in laoreet risus. Suspendisse et sapien scelerisque, tincidunt erat eget, facilisis mauris. Mauris convallis dolor vel placerat condimentum. Morbi facilisis tellus non fermentum ultrices. In a ante ac erat interdum efficitur. Sed a dignissim turpis. Etiam blandit nec lectus congue tincidunt. Quisque nec sapien pretium, euismod mi sit amet, ornare ligula. Nullam feugiat bibendum mi, ac venenatis sapien mattis sed. Curabitur ac metus elementum, posuere sem ut, faucibus nisl. Phasellus bibendum congue posuere. Vivamus lacinia erat vitae arcu volutpat posuere. Vivamus cursus efficitur tellus, ac porta sem imperdiet eget. Integer aliquam velit ex, sit amet cursus dui consequat quis.

Mauris dapibus massa et sem mollis dapibus. Donec faucibus euismod nunc sit amet commodo. Sed est erat, efficitur vel rhoncus at, consequat eu arcu. Duis porttitor diam odio. Sed fringilla, justo in interdum dictum, sapien nunc consequat ligula, ac fringilla massa turpis in dolor. Praesent consequat, dolor at volutpat interdum, libero nunc gravida felis, ut fringilla felis neque vitae neque. Sed auctor sapien et egestas aliquet. Ut nec pellentesque quam. Praesent fermentum elementum purus in rutrum. Suspendisse tempus risus sit amet leo aliquet auctor eu nec leo.

Donec venenatis sed nisi eget venenatis. Nunc mollis, orci pulvinar fermentum auctor, libero mauris rhoncus quam, quis dapibus felis ante vitae sapien. Donec non mattis ex. Aenean a sodales risus, sed consequat libero. Mauris ac risus mi. Integer pellentesque, nunc vitae ultrices mollis, enim lectus consectetur purus, quis vehicula enim lorem in ex. Nunc ut metus nec lectus tempus hendrerit. Sed placerat turpis sagittis dignissim pellentesque. Vestibulum nec laoreet lectus. Proin at quam mattis, finibus diam non, rhoncus massa. Ut ac quam tempor, iaculis leo vitae, finibus enim.

Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Etiam sit amet luctus diam. Suspendisse vulputate vitae quam at varius. Donec faucibus accumsan mollis. Aenean sodales augue orci, molestie interdum sapien malesuada id. Maecenas nisi libero, pharetra nec elementum ut, laoreet ac urna. Vestibulum eget sagittis arcu.

Sed eu commodo mi. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Aliquam porttitor non turpis varius tristique. Integer eget sapien ut justo auctor elementum non id quam. Cras sed orci nibh. Maecenas bibendum sapien massa, eget feugiat purus semper eu. Aliquam efficitur arcu nec diam maximus ullamcorper. Praesent bibendum vehicula odio sed eleifend. Phasellus facilisis orci eu dui gravida, ac gravida dolor rhoncus. Proin sit amet dolor eu mauris posuere ornare. Curabitur fermentum sapien id ligula placerat, a tristique dui fringilla. Sed eu ipsum libero. Fusce bibendum, mi congue pharetra semper, neque arcu commodo diam, id congue lacus leo nec sem. Quisque leo leo, blandit sed imperdiet eu, hendrerit ut lacus. Phasellus dolor orci, rutrum vitae nulla id, venenatis iaculis erat. Phasellus tincidunt orci et purus euismod, id convallis elit sollicitudin.
"""
