//
//  PersonRowView.swift
//  Projects 13-15
//
//  Created by Manuel Teixeira on 02/02/2021.
//

import SwiftUI

struct PersonRowView: View {
    let person: Person

    var body: some View {
        HStack {
            person.wrappedPhoto
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .cornerRadius(10)
                .shadow(radius: 5)

            Text(person.name)
                .font(.headline)
        }
    }
}

struct PersonRowView_Previews: PreviewProvider {
    static var previews: some View {
        PersonRowView(person: Person(id: UUID().uuidString, name: "Text", photo: Data()))
    }
}
