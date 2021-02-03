//
//  ContentView.swift
//  Projects 13-15
//
//  Created by Manuel Teixeira on 02/02/2021.
//

import SwiftUI

struct ContentView: View {
    @State private var people = People(persons: [Person]())
    

    var body: some View {
        NavigationView {
            List(people.persons, id: \.id) { person in
                NavigationLink(
                    destination: PersonDetailView(person: person),
                    label: {
                        PersonRowView(person: person)
                    })
            }
            .navigationBarTitle("Meetup saviour")
            .navigationBarItems(trailing:
                NavigationLink(
                    destination: PersonUploadPhotoView(people: $people),
                    label: {
                        Image(systemName: "plus")
                    })
            )
        }
        .onAppear(perform: loadData)
    }
    
    func loadData() {
        let url = FileManager.getDocumentsDirectory().appendingPathComponent("people")
        
        if let data = try? Data(contentsOf: url) {
            do {
                people = try JSONDecoder().decode(People.self, from: data)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
