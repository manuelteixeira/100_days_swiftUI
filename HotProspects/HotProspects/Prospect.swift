//
//  Prospect.swift
//  HotProspects
//
//  Created by Manuel Teixeira on 12/02/2021.
//

import SwiftUI

class Prospect: Identifiable, Codable {
    var id = UUID()
    var name = "Anonymous"
    var emailAddress = ""
    var dateAdded = Date()
    fileprivate(set) var isContacted = false
}

class Prospects: ObservableObject {
    @Published private(set) var people: [Prospect]
    static let saveKey = "SavedData"

    init() {
        let url = FileManager.getDocumentsDirectory().appendingPathComponent(Self.saveKey)

        do {
            let data = try Data(contentsOf: url)
            
            if let decoded = try? JSONDecoder().decode([Prospect].self, from: data) {
                people = decoded
                return
            }
        } catch {
            print(error.localizedDescription)
        }

        people = []
    }

    private func save() {
        if let encoded = try? JSONEncoder().encode(people) {
            let url = FileManager.getDocumentsDirectory().appendingPathComponent(Self.saveKey)

            do {
                try encoded.write(to: url)
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    func add(_ prospect: Prospect) {
        people.append(prospect)
        save()
    }

    func toggle(_ prospect: Prospect) {
        objectWillChange.send()
        prospect.isContacted.toggle()
        save()
    }
}
