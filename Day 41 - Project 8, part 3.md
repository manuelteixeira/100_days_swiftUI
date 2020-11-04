# Day 41 - Project 8, part 3

- **Showing mission details with ScrollView and GeometryReader**

    **When the user selects one of the Apollo missions from our main list, we want to show information about the mission: its image, its mission badge, and all the astronauts that were on the crew along with their roles**. 

    **The first two of those aren’t too hard, but the second requires more work because we need to match up crew IDs with crew details across our two JSON files.**

    Let’s start simple and work our way up: **make a new SwiftUI view called MissionView.swift.** Initially **this will just have a `mission` property so that we can show the mission badge and description**, but shortly we’ll add more to it.

    In terms of layout, **this thing needs to have a scrolling `VStack` with a resizable image for the mission badge, then a text view, then a spacer so that everything gets pushed to the top of the screen.** 

    We’ll u**se `GeometryReader` to set the maximum width of the mission image**, although through some trial and error I found that the mission badge worked best when it wasn’t full width – somewhere between 50% and 75% width looked better, to avoid it becoming weirdly big on the screen.

    Put this code into MissionView.swift now:

    ```swift
    struct MissionView: View {
        let mission: Mission

        var body: some View {
            GeometryReader { geometry inScrollView(.vertical) {
                    VStack {
                        Image(self.mission.image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: geometry.size.width * 0.7)
                            .padding(.top)

                        Text(self.mission.description)
                            .padding()

                        Spacer(minLength: 25)
                    }
                }
            }
            .navigationBarTitle(Text(mission.displayName), displayMode: .inline)
        }
    }
    ```

    **Did you notice that the spacer was created with `minLength: 25`**? 

    This isn’t something we’ve used before, but **it ensures the spacer has a minimum height of at least 25 points**. 

    **This is helpful inside scroll views because the total available height is flexible**: **a spacer would normally take up all available remaining space, but that has no meaning inside a scroll view**.

    We *could* have accomplished the same result using **`Spacer().frame(minHeight: 25)`**, but **using `Spacer(minLength: 25)` has the advantage that if you ever change your stack orientation** – if you go from a **`VStack`** to a **`HStack`**, for example – **then it effectively becomes `Spacer().frame(minWidth: 25)`.**

    Anyway, with our new view in place the code will no longer build, all because of the previews struct below it – that thing needs a **`Mission`** object passed in so it has something to render. Fortunately, our **`Bundle`** extension is available here as well:

    ```swift
    struct MissionView_Previews: PreviewProvider {
        static let missions: [Mission] = Bundle.main.decode("missions.json")

        static var previews: some View {
            MissionView(mission: missions[0])
        }
    }
    ```

    If you look in the preview you’ll see that’s a good start, but the next part is trickier: we want to show the list of astronauts who took part in the mission below the description. Let’s tackle that next…

- **Merging Codable structs using first(where:)**

    **Below our mission description we want to show the pictures, names, and roles of each crew member**, which is easier said than done.

    **The complexity here is that our JSON was provided in two parts**: **missions.json and astronauts.json**. 

    This eliminates duplication in our data, because some astronauts took part in multiple missions, but it also means **we need to write some code to join our data together** – to resolve “armstrong” to “Neil A. Armstrong”, for example. 

    **You see, on one side we have missions that know crew member “armstrong” had the role “Commander”, but has no idea who “armstrong” is, and on the other side we have “Neil A. Armstrong” and a description of him, but no concept that he was the commander on Apollo 11.**

    So, what **we need to do is make our `MissionView` accept the mission that got tapped, along with our full astronauts array, then have it figure out which astronauts actually took part in the launch**. 

    Because this merged data is only temporary we *could* use a tuple rather than a struct, but honestly there isn’t really much difference so we’ll be using a new struct here.

    Add this nested struct inside **`MissionView`** now:

    ```swift
    struct CrewMember {
        let role: String
        let astronaut: Astronaut
    }
    ```

    Now for the tricky part: **we need to add a property to `MissionView` that stores an array of `CrewMember` objects** – **these are the fully resolved role / astronaut pairings.** At first that’s as simple as adding another property:

    ```swift
    let astronauts: [CrewMember]
    ```

    But then how do we *set* that property? Well, think about it: if we make this view be handed its mission and all astronauts, **we can loop over the mission crew, then for each crew member loop over all our astronauts to find the one that has a matching ID**. 

    **When we find one we can convert that and their role into a `CrewMember` object**, but **if we don’t it means somehow we have a crew role with an invalid or unknown name.**

    **Swift gives us an array method called `first(where:)`** that really helps this process along. **We can give it a predicate** (a fancy word for a condition), **and it will send back the first array element that matches the predicate, or `nil` if none do**.

    In our case we can use that to say “give me the first astronaut with the ID of armstrong.”

    Let’s put all that into code, using a custom initializer for **`MissionView`**. Like I said, this will accept the mission it represents along with all the astronauts, and its job is to store the mission away then figure out the array of resolved astronauts.

    Here’s the code:

    ```swift
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
    ```

    As soon as that code is in, our preview struct will stop working again because it needs more information. So, add a second call to **`decode()`** there so it loads all the astronauts, then passes those in too:

    ```swift
    struct MissionView_Previews: PreviewProvider {
        static let missions: [Mission] = Bundle.main.decode("missions.json")
        static let astronauts: [Astronaut] = Bundle.main.decode("astronauts.json")

        static var previews: some View {
            MissionView(mission: missions[0], astronauts: astronauts)
        }
    }
    ```

    Now that we have all our astronaut data, **we can show this directly below the mission description using a `ForEach`**. 

    **This is going to use the same `HStack`/`VStack` combination we used in `ContentView`, except now we need a spacer at the end of our `HStack` to push our views to the left** – 

    **previously we got that for free before because we were in a `List`, but that isn’t the case now.** 

    **We’re also going to add a little extra styling to the astronaut pictures to make them look bette**r, using a capsule clip shape and overlay.

    Add this code before **`Spacer(minLength: 25)`** in **`MissionView`**:

    ```swift
    ForEach(self.astronauts, id: \.role) { crewMember inHStack {
            Image(crewMember.astronaut.id)
                .resizable()
                .frame(width: 83, height: 60)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Color.primary, lineWidth: 1))

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
    ```

    You should see that looks good in the preview, but to see it live in the simulator **we need to modify the** **`NavigationLink`** in **`ContentView`** – it pushes to **`Text("Detail View")`** right now, but please replace it with this:

    ```swift
    NavigationLink(destination: MissionView(mission: mission, astronauts: self.astronauts)) {
    ```

    Now go ahead and run the app in the simulator – it’s starting to become useful!

    Before you move on, try spending a few minutes customizing the way the astronauts are shown – I’ve used a capsule clip shape and overlay, but you could try circles or rounded rectangles, you could use different fonts or larger images, or even add some way of marking who the mission commander was.

- **Fixing problems with buttonStyle() and layoutPriority()**

    **To finish this program we’re going to make a third and final view to display astronaut details**, which will be reached by tapping one of the astronauts in the mission view. 

    This should mostly just be practice for you, but I do want to highlight an interesting quirk and how it can be resolved with a new modifier called **`layoutPriority()`**.

    **Start by making a new SwiftUI view called `AstronautView`. This will have a single `Astronaut` property so it knows what to show**, then it will lay that out using a similar **`GeometryReader`**/**`ScrollView`**/**`VStack`** combination as we had in **`MissionView`**. Give it this code:

    ```swift
    struct AstronautView: View {
        let astronaut: Astronaut

        var body: some View {
            GeometryReader { geometry inScrollView(.vertical) {
                    VStack {
                        Image(self.astronaut.id)
                            .resizable()
                            .scaledToFit()
                            .frame(width: geometry.size.width)

                        Text(self.astronaut.description)
                            .padding()
                    }
                }
            }
            .navigationBarTitle(Text(astronaut.name), displayMode: .inline)
        }
    }
    ```

    Once again we need to update the preview so that it creates its view with some data:

    ```swift
    struct AstronautView_Previews: PreviewProvider {
        static let astronauts: [Astronaut] = Bundle.main.decode("astronauts.json")

        static var previews: some View {
            AstronautView(astronaut: astronauts[0])
        }
    }
    ```

    **Now we can present that from `MissionView` using another `NavigationLink`.** 

    This needs to go just inside the **`ForEach`** so that it wraps the existing **`HStack`**:

    ```swift
    NavigationLink(destination: AstronautView(astronaut: crewMember.astronaut)) {
        HStack {
            // current code
        }
        .padding(.horizontal)
    }
    ```

    Run the app now and give it a thorough try – you should see at least one bug, and perhaps two depending on SwiftUI.

    **The first bug is pretty glaring: in the mission view, all our astronaut pictures are shown as solid blue capsules rather than their pictures.** 

    You might also notice that **each person’s name is written in the same shade of blue**, which might give you a clue what’s going on – **now that this is a navigation link, SwiftUI is making the whole thing look active by coloring our views blue.**

    To fix this **we need to ask SwiftUI to render the contents of the navigation link as a plain button**, which **means it won’t apply coloring to the image or text.** So, add this as a modifier to the astronaut **`NavigationLink`** in **`MissionView`**:

    ```swift
    .buttonStyle(PlainButtonStyle())
    ```

    As for the **second bug, it’s possible you didn’t even see it at all – this seems to me to be a bug in SwiftUI itself**, and so **it either might be fixed in a future release or it’s possible that it only affects specific device configurations**. So, if this bug doesn’t exist for you when using the same iPhone simulator as me it’s possible it has been resolved!

    The bug is this: **if you select certain astronauts, such as Edward H. White II from Apollo 1, you might see their description text gets clipped at the bottom.** So, rather than seeing all the text, you instead see just some, followed by an ellipsis where the rest should be. **And if you look closely at the top of the image, you’ll notice it’s no longer sitting directly against the navigation bar at the top.**

    **What we’re seeing is SwiftUI’s layout algorithm having a hard time coming to the right conclusion about our content**. 

    **In my view this is a SwiftUI bug, and it’s possible that by the time you try this yourself it won’t even exist.** 

    But it exists right here, so I’m going to show you how we can fix it by using the **`layoutPriority()`** modifier.

    **Layout priority lets us control how readily a view shrinks when space is limited, or expands when space is plentiful.
    All views have a layout priority of 0 by default**, which means **they each get equal chance** to grow or shrink.

    **We’re going to give our astronaut description a layout priority of 1, which is higher than the image’s 0, which means it will automatically take up all available space.**

    To do this, just add **`layoutPriority(1)`** to the description text view in **`AstronautView`**, like this:

    ```swift
    Text(self.astronaut.description)
        .padding()
        .layoutPriority(1)
    ```

    With those two bugs fixed our program is done – run it one last time and try it out!