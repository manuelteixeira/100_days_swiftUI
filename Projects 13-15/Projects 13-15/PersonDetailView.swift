//
//  PersonDetailView.swift
//  Projects 13-15
//
//  Created by Manuel Teixeira on 02/02/2021.
//

import SwiftUI

struct PersonDetailView: View {
    let gradient = Gradient(colors: [Color.purple, Color.pink])
    let person: Person

    var body: some View {
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 30)
                    .fill(
                        LinearGradient(
                            gradient: gradient,
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 300, height: 300)
                    .shadow(radius: 10)

                person.wrappedPhoto
                    .resizable()
                    .frame(width: 250, height: 250)
                    .cornerRadius(30)
                    .shadow(radius: 10)
            }
            
            MapView(location: .constant(person.wrappedLocation))
                .frame(height: 300)
                .clipShape(RoundedRectangle(cornerRadius: 30))
                .padding(.top, 40)
                .padding([.leading, .trailing, .bottom], 24)
                .shadow(radius: 10)
            
            Text(person.name)
                .font(.title)
            
            Spacer()

        }
    }
}

struct PersonDetailView_Previews: PreviewProvider {
    static var previews: some View {
        PersonDetailView(person: Person.mock)
    }
}
