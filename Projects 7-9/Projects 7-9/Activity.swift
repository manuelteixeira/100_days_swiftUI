//
//  Activity.swift
//  Projects 7-9
//
//  Created by Manuel Teixeira on 13/11/2020.
//

import Foundation

class Activity: Codable, Identifiable, ObservableObject {
    var id: String = UUID().uuidString
    let title: String
    let description: String
    @Published var timesCompleted: Int
    
    enum CodingKeys: CodingKey {
        case id, title, description, timesCompleted
    }
    
    init(title: String, description: String, timesCompleted: Int = 0) {
        self.title = title
        self.description = description
        self.timesCompleted = timesCompleted
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decode(String.self, forKey: .description)
        timesCompleted = try container.decode(Int.self, forKey: .timesCompleted)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(description, forKey: .description)
        try container.encode(timesCompleted, forKey: .timesCompleted)
    }
}

class ActivityList: Codable, ObservableObject {
    @Published var activities: [Activity]
    
    enum CodingKeys: CodingKey {
        case activities
    }
    
    init(activities: [Activity]) {
        self.activities = activities
    }
    
    init() {
        activities = []
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        activities = try container.decode([Activity].self, forKey: .activities)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(activities, forKey: .activities)
    }
}
