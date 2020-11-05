# Day 42 - Project 8, part 4

- Challenge

    1. Add the launch date to **`MissionView`**, below the mission badge.

        ```swift
        VStack {
            Image(self.mission.image)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: geometry.size.width * 0.7)
                .padding(.top)
            Text(self.mission.formattedLaunchDate)
                .font(.caption)
        }
        ```

    2. Modify **`AstronautView`** to show all the missions this astronaut flew on.

        ```swift
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
        ```

    3. Make a bar button in **`ContentView`** that toggles between showing launch dates and showing crew names.

        ```swift
        var formattedCrewMembers: String {
            return crew.map({ $0.name.capitalized }).joined(separator: ", ")
        }
        ```

        ```swift
        @State private var barButtonTitle = "Launch dates"
        @State private var isShowingLaunchDates = false
        ```

        ```swift
        func toggleButtonInformation() {
            isShowingLaunchDates.toggle()
            barButtonTitle = isShowingLaunchDates ? "Crew members" : "Launch dates"
        }
        ```

        ```swift
        .navigationBarItems(trailing:
            Button(barButtonTitle) {
                self.toggleButtonInformation()
            }
        )
        ```

        ```swift
        Text(self.isShowingLaunchDates ? mission.formattedLaunchDate : mission.formattedCrewMembers)
        ```