//
//  VideoDetail.swift
//  TestSwiftUI
//
//  Created by nicolasjakubowski on 4/6/20.
//  Copyright © 2020 nicolasjakubowski. All rights reserved.
//

import Foundation
import SwiftUI
import Combine

struct VideoDetail: View {
    @ObservedObject var video: Video
    @EnvironmentObject var app: App
    
    @State private var isPlayingVideo = false
    @State private var isShowingCancelVideoSheet = false
    
    var body: some View {
        ScrollView {
            if video.downloadError != nil {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Download failed: \(video.downloadError!.localizedDescription)")
                        .foregroundColor(.red)
                    Button("Dismiss") {
                        self.video.downloadError = nil
                    }
                }.padding()
            }
            Spacer()
            ZStack {
                if video.image != nil {
                    Image(uiImage: video.image!)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipped()
                } else {
                    Rectangle()
                        .frame(height: 200)
                }
                Button(action: { self.isPlayingVideo = true }) {
                    Image(systemName: "play.circle")
                    .resizable()
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                }
            }
            Spacer()
            Text(video.name)
                .font(.title)
                .bold()
                .multilineTextAlignment(.center)
                .padding([.horizontal])
            Spacer()
            Text(video.description)
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding([.horizontal])
        }
        .navigationBarItems(trailing: downloadStatus)
        .navigationBarTitle("", displayMode: .inline)
        .sheet(isPresented: $isPlayingVideo) {
            VideoPlayer(videoUrl: self.video.urlForVideoPlayer)
        }
        .actionSheet(isPresented: $isShowingCancelVideoSheet) {
            ActionSheet(title: Text(video.name), message: nil, buttons: [
                .destructive(Text("Cancel Download"), action: {
                    self.app.videoLoader.cancelDownload(video: self.video)
                }),
                .cancel(Text("Dismiss"))
            ])
        }
    }
    
    private var downloadStatus: some View {
        if video.localVideoUrl != nil {
            return Image(systemName: "checkmark.circle")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 25, alignment: .trailing)
                .eraseToAnyView()
        } else if let progress = video.downloadProgress {
            return Button(action: {
                self.isShowingCancelVideoSheet = true
            }) {
                ProgressCircle(lineWidth: 4, progress: CGFloat(progress))
                    .frame(width: 25, height: 25)
            }.eraseToAnyView()
        } else {
            return HStack {
                Button(action: { self.app.videoLoader.downloadVideo(video: self.video) }) {
                    Image(systemName: "square.and.arrow.down")
                        .imageScale(.large)
                }
            }.eraseToAnyView()
        }
    }
    
}

struct VideoDetail_Preview: PreviewProvider {
    static var previews: some View {
        let devices = ["iPhone X"]
        let videos = SampleVideoStore.all
        
        return
            ForEach(videos, id: \.id) { video in
                ForEach(devices, id: \.self) { deviceName in
                    NavigationView {
                        VideoDetail(video: video)
                            .previewDevice(PreviewDevice(rawValue: deviceName))
                    }
                }
        }
    }
}
