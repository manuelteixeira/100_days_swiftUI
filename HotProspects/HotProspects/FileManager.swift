//
//  FileManager.swift
//  HotProspects
//
//  Created by Manuel Teixeira on 17/02/2021.
//

import Foundation

extension FileManager {
    static func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
}
