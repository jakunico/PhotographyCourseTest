//
//  SceneDelegate.swift
//  PhotographyCourse
//
//  Created by Nicolas Jakubowski on 4/10/20.
//  Copyright © 2020 Nicolas Jakubowski. All rights reserved.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        
        let window = UIWindow(windowScene: windowScene)
        let app = App()
        let root = VideoList()
            .environmentObject(app)
            .environmentObject(app.state)
        window.rootViewController = UIHostingController(rootView: root)
        window.makeKeyAndVisible()
        
        self.window = window
    }
    
}

