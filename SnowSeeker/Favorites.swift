//
//  Favorites.swift
//  SnowSeeker
//
//  Created by Manuel Teixeira on 09/03/2021.
//

import SwiftUI

class Favorites: ObservableObject {
    private var resorts: Set<String>
    
    private let saveKey = "Favorites"
    
    init() {
        resorts = []
        load()
    }
    
    func contains(_ resort: Resort) -> Bool {
        resorts.contains(resort.id)
    }
    
    func add(_ resort: Resort) {
        objectWillChange.send()
        resorts.insert(resort.id)
        save()
    }
    
    func remove(_ resort: Resort) {
        objectWillChange.send()
        resorts.remove(resort.id)
        save()
    }
    
    func save() {
        if let data = try? JSONEncoder().encode(resorts) {
            UserDefaults.standard.set(data, forKey: saveKey)
        }
    }
    
    func load() {
        if let data = UserDefaults.standard.object(forKey: saveKey) as? Data {
            do {
                resorts = try JSONDecoder().decode(Set<String>.self, from: data)
            } catch {
                print("Couldn't decode")
            }
        }
    }
}
