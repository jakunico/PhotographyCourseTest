//
//  VideoList.swift
//  TestSwiftUI
//
//  Created by Nicolas Jakubowski on 4/6/20.
//  Copyright © 2020 nicolasjakubowski. All rights reserved.
//

import Foundation
import SwiftUI

struct VideoList: View {
    
    @EnvironmentObject var app: App
    @EnvironmentObject var state: AppState
    
    var body: some View {
        NavigationView {
            List {
                if state.videoLoadingError != nil {
                    VStack(alignment: .leading) {
                        Text("Failed to load videos: \(state.videoLoadingError!.localizedDescription)")
                        Spacer()
                        Button("Retry") {
                            self.app.videoLoader.getVideos()
                        }.buttonStyle(BorderlessButtonStyle())
                    }
                    Spacer()
                }
                if state.isLoadingVideos {
                    LoadingIndicator()
                }
                ForEach(state.videos) { video in
                    NavigationLink(destination: VideoDetail(video: video)) {
                        VideoRow(video: video)
                    }
                }
            }
            .navigationBarTitle("Videos")
        }
        .onAppear {
            self.app.videoLoader.getVideos()
        }
    }
    
}
struct VideoList_Preview: PreviewProvider {
    static var previews: some View {
        VideoList().environmentObject(App())
    }
}
