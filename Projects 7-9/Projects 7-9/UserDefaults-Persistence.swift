//
//  UserDefaults.swift
//  Projects 7-9
//
//  Created by Manuel Teixeira on 13/11/2020.
//

import Foundation

extension UserDefaults {
    static func save(activityList: ActivityList) {
        let encoder = JSONEncoder()
        
        if let data = try? encoder.encode(activityList) {
            UserDefaults.standard.setValue(data, forKey: "activityList")
        }
    }
    
    static func loadData() -> ActivityList {
        let decoder = JSONDecoder()

        if let data = UserDefaults.standard.data(forKey: "activityList") {
            if let decodedActivityList = try? decoder.decode(ActivityList.self, from: data) {
                return decodedActivityList
            }
        }
        
        return ActivityList()
    }
}
