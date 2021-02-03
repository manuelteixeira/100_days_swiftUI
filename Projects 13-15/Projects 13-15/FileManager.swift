//
//  FileManager.swift
//  Projects 13-15
//
//  Created by Manuel Teixeira on 02/02/2021.
//

import Foundation

extension FileManager {
    static func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}
