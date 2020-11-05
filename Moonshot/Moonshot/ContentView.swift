//
//  ContentView.swift
//  Moonshot
//
//  Created by Manuel Teixeira on 30/10/2020.
//  Copyright © 2020 Manuel Teixeira. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    let astronauts: [Astronaut] = Bundle.main.decode("astronauts.json")
    let missions: [Mission] = Bundle.main.decode("missions.json")
    
    @State private var barButtonTitle = "Launch dates"
    @State private var isShowingLaunchDates = false

    var body: some View {
        NavigationView {
            List(missions) { mission in
                NavigationLink(destination: MissionView(mission: mission, astronauts: self.astronauts)) {
                    Image(mission.image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 44, height: 44)

                    VStack(alignment: .leading) {
                        Text(mission.displayName)
                            .font(.headline)
                        Text(self.isShowingLaunchDates ? mission.formattedLaunchDate : mission.formattedCrewMembers)
                    }
                }
            }
            .navigationBarTitle("Moonshot")
            .navigationBarItems(trailing:
                Button(barButtonTitle) {
                    self.toggleButtonInformation()
                }
            )
        }
    }
    
    func toggleButtonInformation() {
        isShowingLaunchDates.toggle()
        barButtonTitle = isShowingLaunchDates ? "Crew members" : "Launch dates"
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
