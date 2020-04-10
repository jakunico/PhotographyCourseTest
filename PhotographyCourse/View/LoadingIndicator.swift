//
//  LoadingIndicator.swift
//  TestSwiftUI
//
//  Created by Nicolas Jakubowski on 4/7/20.
//  Copyright © 2020 nicolasjakubowski. All rights reserved.
//

import Foundation
import SwiftUI

struct LoadingIndicator: UIViewRepresentable {
    func makeUIView(context: Context) -> UIActivityIndicatorView {
        let view = UIActivityIndicatorView(style: .medium)
        view.startAnimating()
        return view
    }
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {
    }
}
