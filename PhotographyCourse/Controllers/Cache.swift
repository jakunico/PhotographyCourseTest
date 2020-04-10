//
//  Cache.swift
//  PhotographyCourse
//
//  Created by Nicolas Jakubowski on 4/10/20.
//  Copyright © 2020 Nicolas Jakubowski. All rights reserved.
//

import Foundation

class Cache {
    let identifier: String
    
    private let manager = FileManager.default
    private var documentsDirectory: URL { manager.urls(for: .documentDirectory, in: .userDomainMask).last! }
    private var cacheFile: URL { documentsDirectory.appendingPathComponent(identifier).appendingPathExtension(".json") }
    
    init(identifier: String) {
        self.identifier = identifier
    }
    
    func store<T: Codable>(_ object: T) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(object)
        let string = String(data: data, encoding: .utf8)
        try string?.write(toFile: cacheFile.path, atomically: true, encoding: .utf8)
    }
    
    func retrieve<T: Codable>() throws -> T? {
        guard manager.fileExists(atPath: cacheFile.path) else { return nil }
        let data = try Data(contentsOf: cacheFile)
        let decoder = JSONDecoder()
        let object = try decoder.decode(T.self, from: data)
        return object
    }
}
