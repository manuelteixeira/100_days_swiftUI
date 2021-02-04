//
//  Person.swift
//  Projects 13-15
//
//  Created by Manuel Teixeira on 02/02/2021.
//

import Foundation
import SwiftUI
import MapKit

struct Person: Codable, Identifiable {
    let id: String
    let name: String
    let photo: Data
    let latitude: Double
    let longitude: Double
    
    var wrappedPhoto: Image {
        if let uiImage = UIImage(data: photo) {
            return Image(uiImage: uiImage)
        }
        return Image(systemName: "person") 
    }
    
    var wrappedLocation: MKPointAnnotation {
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        return annotation
    }
}

struct People: Codable {
    var persons: [Person]
}

extension Person {
    static var mock: Person {
        Person(id: UUID().uuidString, name: "Test", photo: Data(), latitude: 39.557191, longitude: -7.8536599)
    }
}

extension People {
    static var mock: People {
        People(persons: [Person.mock])
    }
}
