//
//  Person.swift
//  Projects 13-15
//
//  Created by Manuel Teixeira on 02/02/2021.
//

import Foundation
import SwiftUI

struct Person: Codable, Identifiable {
    let id: String
    let name: String
    let photo: Data
    
    var wrappedPhoto: Image {
        if let uiImage = UIImage(data: photo) {
            return Image(uiImage: uiImage)
        }
        return Image(systemName: "person") 
    }
}

struct People: Codable {
    var persons: [Person]
}
