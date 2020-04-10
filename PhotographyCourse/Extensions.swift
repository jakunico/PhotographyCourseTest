//
//  Extensions.swift
//  PhotographyCourse
//
//  Created by Nicolas Jakubowski on 4/10/20.
//  Copyright © 2020 Nicolas Jakubowski. All rights reserved.
//

import Foundation

extension NSError {
    static func errorWithLocalizedDescription(_ description: String) -> NSError {
        return NSError(domain: "com.nicolasjakubowski",
                       code: 9000,
                       userInfo: [NSLocalizedDescriptionKey:description])
    }
}
