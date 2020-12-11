//
//  ContentView.swift
//  CoreDataProject
//
//  Created by Manuel Teixeira on 11/12/2020.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.managedObjectContext) var moc
    @State private var lastNameFilter = "A"
    @State private var sortAscending = true

    var body: some View {
        VStack {
            let sortDescriptor = NSSortDescriptor(keyPath: \Singer.lastName, ascending: sortAscending)
            
            FilteredListView(filterKey: "lastName", filterValue: lastNameFilter, sortDescriptors: [sortDescriptor], predicate: .contains) { (singer: Singer) in
                Text("\(singer.wrappedFirstName) \(singer.wrappedLastName)")
            }

            Button("Add Examples") {
                let taylor = Singer(context: self.moc)
                taylor.firstName = "Taylor"
                taylor.lastName = "Swift"

                let ed = Singer(context: self.moc)
                ed.firstName = "Ed"
                ed.lastName = "Sheeran"

                let adele = Singer(context: self.moc)
                adele.firstName = "Adele"
                adele.lastName = "Adkins"

                try? self.moc.save()
            }

            Button("Show A") {
                self.lastNameFilter = "A"
            }

            Button("Show S") {
                self.lastNameFilter = "S"
            }
            
            Button("Sort \(sortAscending ? "descending" : "ascending")") {
                self.sortAscending.toggle()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
