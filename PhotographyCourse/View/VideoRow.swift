//
//  VideoRow.swift
//  TestSwiftUI
//
//  Created by nicolasjakubowski on 4/6/20.
//  Copyright © 2020 nicolasjakubowski. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

struct VideoRow: View {
    @ObservedObject var video: Video
    
    var body: some View {
        HStack {
            if video.image != nil {
                Image(uiImage: video.image!)
                    .resizable()
                    .frame(width: 45.0, height: 45.0)
                    .aspectRatio(contentMode: .fill)
                    .cornerRadius(3)
            } else {
                Rectangle()
                    .frame(width: 45.0, height: 45.0)
                    .foregroundColor(.gray)
                    .cornerRadius(3)
            }
            Text(video.name)
                .font(.body)
                .lineLimit(2)
            Spacer()
        }
    }
}

struct VideoRow_Previews: PreviewProvider {
    static var previews: some View {
        
        return
            Group {
                VideoRow(video: SampleVideoStore.notDownloaded)
                VideoRow(video: SampleVideoStore.downloading)
                VideoRow(video: SampleVideoStore.downloaded)
                VideoRow(video: SampleVideoStore.withImage)
            }.previewLayout(.fixed(width: 320, height: 70))
        
    }
}
