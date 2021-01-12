//
//  FileManager.swift
//  BucketList
//
//  Created by Manuel Teixeira on 12/01/2021.
//

import Foundation

extension FileManager {
    static func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func decoded<T: Codable>(_ url: URL) -> T {
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Failed to load from data.")
        }
        
        let decoder = JSONDecoder()
        
        guard let decoded = try? decoder.decode(T.self, from: data) else {
            fatalError("Failed to decoded.")
        }
        
        return decoded
    }
}
