# Day 76 - Project 15, part 3

- Challenge

    1. The check out view in Cupcake Corner uses an image that doesn’t add anything to the UI, so find a way to make the screenreader not read it out.

        ```swift
        Image(decorative: "cupcakes")
            .resizable()
            .scaledToFit()
            .frame(width: geo.size.width)
        ```

    2. Fix the steppers in BetterRest so that they read out useful information when the user adjusts their values.

        ```swift
        Section(header: Text("Desired amount of sleep")) {
            Stepper(value: $sleepAmount, in: 4...12, step: 0.25) {
                Text("\(sleepAmount, specifier: "%g") hours")
            }
            .accessibility(value: Text("\(sleepAmount, specifier: "%g") hours with a minimum of 4 hours and a maximum of 12 hours."))
        }
        ```

    3. Do a full accessibility review of Moonshot – what changes do you need to make so that it’s fully accessible?

        ```swift
        ForEach(self.missions) {
            Image($0.image)
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .accessibility(removeTraits: .isImage)
                .accessibility(addTraits: .isButton)
        }
        ```

        ```swift
        Image(self.astronaut.id)
            .resizable()
            .scaledToFit()
            .frame(width: geometry.size.width)
            .accessibility(label: Text(self.astronaut.name))
        ```

        ```swift
        Image(crewMember.astronaut.id)
            .resizable()
            .frame(width: 83, height: 60)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(radius: 10)
            .accessibility(label: Text(crewMember.astronaut.name))
        ```