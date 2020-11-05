//
//  Mission.swift
//  Moonshot
//
//  Created by Manuel Teixeira on 03/11/2020.
//  Copyright © 2020 Manuel Teixeira. All rights reserved.
//

import Foundation

struct Mission: Codable, Identifiable {
    struct CrewRole: Codable {
        let name: String
        let role: String
    }

    let id: Int
    let launchDate: Date?
    let crew: [CrewRole]
    let description: String
    
    var displayName: String {
        "Apollo \(id)"
    }
    
    var image: String {
        "apollo\(id)"
    }
    
    var formattedLaunchDate: String {
        if let launchDate = launchDate {
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            return formatter.string(from: launchDate)
        } else {
            return "N/A"
        }
    }
    
    var formattedCrewMembers: String {
        return crew.map({ $0.name.capitalized }).joined(separator: ", ")
    }
}
