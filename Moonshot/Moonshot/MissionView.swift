//
//  MissionView.swift
//  Moonshot
//
//  Created by Manuel Teixeira on 04/11/2020.
//  Copyright © 2020 Manuel Teixeira. All rights reserved.
//

import SwiftUI

struct MissionView: View {
    struct CrewMember {
        let role: String
        let astronaut: Astronaut
    }

    let mission: Mission
    let astronauts: [CrewMember]

    var body: some View {
        GeometryReader { geometry in
            ScrollView(.vertical) {
                VStack {
                    VStack {
                        Image(self.mission.image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: geometry.size.width * 0.7)
                            .padding(.top)
                        Text(self.mission.formattedLaunchDate)
                            .font(.caption)
                    }

                    Text(self.mission.description)
                        .padding()

                    ForEach(self.astronauts, id: \.role) { crewMember in
                        NavigationLink(destination: AstronautView(astronaut: crewMember.astronaut)) {
                            HStack {
                                Image(crewMember.astronaut.id)
                                    .resizable()
                                    .frame(width: 83, height: 60)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .shadow(radius: 10)
                                    .accessibility(label: Text(crewMember.astronaut.name))

                                VStack(alignment: .leading) {
                                    Text(crewMember.astronaut.name)
                                        .font(.headline)

                                    Text(crewMember.role)
                                        .foregroundColor(.secondary)
                                }

                                Spacer()
                            }
                            .padding(.horizontal)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }

                    Spacer(minLength: 25)
                }
            }
        }
        .navigationBarTitle(Text(mission.displayName), displayMode: .inline)
    }

    init(mission: Mission, astronauts: [Astronaut]) {
        self.mission = mission

        var matches = [CrewMember]()

        for member in mission.crew {
            if let match = astronauts.first(where: { $0.id == member.name }) {
                matches.append(CrewMember(role: member.role, astronaut: match))
            } else {
                fatalError("Missing \(member)")
            }
        }

        self.astronauts = matches
    }
}

struct MissionView_Previews: PreviewProvider {
    static let missions: [Mission] = Bundle.main.decode("missions.json")
    static let astronauts: [Astronaut] = Bundle.main.decode("astronauts.json")

    static var previews: some View {
        MissionView(mission: missions[0], astronauts: astronauts)
    }
}
