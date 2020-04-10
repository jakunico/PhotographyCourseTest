//
//  ProgressBar.swift
//  TestSwiftUI
//
//  Created by Nicolas Jakubowski on 4/7/20.
//  Copyright © 2020 nicolasjakubowski. All rights reserved.
//

import SwiftUI

struct ProgressCircle: View {
    
    var lineWidth: CGFloat
    var progress: CGFloat
    
    var body: some View {
        return ZStack {
            Circle()
                .stroke(lineWidth: lineWidth)
                .foregroundColor(Color(.lightGray))
                .accentColor(.red)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(lineWidth: lineWidth)
                .foregroundColor(.accentColor)
                .rotationEffect(Angle(degrees: -90))
                .animation(.linear)
        }
    }
}

struct ProgressBar_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ProgressCircle(lineWidth: 5, progress: 0.0)
            ProgressCircle(lineWidth: 5, progress: 0.2)
            ProgressCircle(lineWidth: 5, progress: 0.6)
            ProgressCircle(lineWidth: 5, progress: 1.0)
        }
        .previewLayout(.fixed(width: 50, height: 50))
        .padding(5)
        
    }
}
