//
//  AstronautView.swift
//  Moonshot
//
//  Created by Manuel Teixeira on 04/11/2020.
//  Copyright © 2020 Manuel Teixeira. All rights reserved.
//

import SwiftUI

struct AstronautView: View {
    let astronaut: Astronaut
    let missions: [Mission]

    var body: some View {
        GeometryReader { geometry in
            ScrollView(.vertical) {
                VStack {
                    Image(self.astronaut.id)
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width)

                    Text(self.astronaut.description)
                        .padding()
                        .layoutPriority(1)

                    Text("Missions")
                        .font(.headline)

                    HStack {
                        ScrollView(.horizontal) {
                            ForEach(self.missions) {
                                Image($0.image)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 80, height: 80)
                            }
                        }
                        .padding([.leading, .trailing])
                    }
                }
            }
        }
        .navigationBarTitle(Text(astronaut.name), displayMode: .inline)
    }

    init(astronaut: Astronaut) {
        self.astronaut = astronaut

        let decodedMissions: [Mission] = Bundle.main.decode("missions.json")

        missions = decodedMissions.filter({ $0.crew.contains(where: { $0.name == astronaut.id }) })
    }
}

struct AstronautView_Previews: PreviewProvider {
    static let astronauts: [Astronaut] = Bundle.main.decode("astronauts.json")
    static let missions: [Mission] = Bundle.main.decode("missions.json")

    static var previews: some View {
        AstronautView(astronaut: astronauts[0])
    }
}
