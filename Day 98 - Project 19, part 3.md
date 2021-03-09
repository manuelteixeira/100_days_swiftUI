# Day 98 - Project 19, part 3

- **Changing a view's layout in response to size classes**

    **SwiftUI gives us two environment values to monitor the current size class of our app**, which in practice means **we can show one layout when space is restricted and another when space is plentiful.**

    For example, in our current layout we’re displaying the resort details and snow details in a **`HStack`**, like this:

    ```swift
    HStack {
        Spacer()
        ResortDetailsView(resort: resort)
        SkiDetailsView(resort: resort)
        Spacer()
    }
    ```

    **Each of those subviews are internally using a `VStack`, so we end up with a two by two grid**: **two rows, with two views in each row.** 

    This looks great when space is restricted, but when we have more space it would look better to have them all in one row.

    To make this happen we *could* create copies of **`ResortDetailsView`** and **`SkiDetailsView`** that handle the alternative layout, **but a much smarter solution is to have both those views be *layout neutral* – to have them automatically adapt to being placed in a `HStack` or `VStack` depending on the parent that places them.**

    First, add this new **`@Environment`** property to **`ResortView`**:

    ```swift
    @Environment(\.horizontalSizeClass)var sizeClass
    ```

    **That will tell us whether we have a regular or compact size class**. Very roughly:

    - **All iPhones in portrait have compact width and regular height.**
    - Most iPhones in landscape have compact width and compact height.
    - Large iPhones (Plus-sized and Max devices) in landscape have regular width and compact height.
    - **All iPads in both orientations have regular width and regular height.**

    Things get a little more complex for **iPad when it comes to split view mode, which is when you have two apps running side by side – iOS will automatically downgrade our app to a compact size class at various points depending on the exact iPad model.**

    Fortunately, all we care about are these two horizontal options: do we have lots of space (regular) or is space restricted (compact). 

    If space is low we’re going to keep the current nested **`VStack`** approach so that we don’t try and squeeze everything onto one line, but if there’s more space we’ll ditch that and place the views directly into the parent **`HStack`**.

    So, find the **`HStack`** that contains **`ResortDetailsView`** and **`SkiDetailsView`** and replace it with this:

    ```swift
    HStack {
    		if sizeClass == .compact {
            Spacer()
            VStack { ResortDetailsView(resort: resort) }
            VStack { SkiDetailsView(resort: resort) }
            Spacer()
        } else {
            ResortDetailsView(resort: resort)
            Spacer()
            SkiDetailsView(resort: resort)
        }
    }
    .font(.headline)
    .foregroundColor(.secondary)
    .padding(.top)
    ```

    As you can see, that moves the **`VStack`** work up to the parent view, rather than keeping it inside **`ResortDetailsView`** and **`SkiDetailsView`**.

    This hasn’t really changed much, and in fact things have gotten a little worse because if you run in an iPhone 11 Pro Max in landscape (regular size class) the two child views are spaced oddly because we went from two spacers down to one.

    Fixing that problem is easy, but it creates other problems at the same time. Fortunately, *those* are easy to fix as well, so stick with me – we’ll get there!

    **To make our two child views layout neutral – to make them have no specific layout direction of their own, but instead be directed by their parent** – we **need to make them use `Group` rather than `VStack`.**

    So, update **`SkiDetailsView`** to this:

    ```swift
    var body: some View {
        Group {
            Text("Elevation: \(resort.elevation)m")
            Text("Snow: \(resort.snowDepth)cm")
        }
    }
    ```

    And update **`ResortDetailsView`** to this:

    ```swift
    var body: some View {
        Group {
            Text("Size: \(size)")
            Text("Price: \(price)")
        }
    }
    ```

    On an iPhone in portrait mode these look identical, because we’ve gone from having a **`VStack`** nested inside another **`VStack`** to having a **`Group`** nested inside a **`VStack`** – there’s no layout difference. But i**n *landscape* things are looking a little better because all four text views are now being laid out in a single line.** They are laid out *badly* on a single line, but at least they are on a single line!

    The **next step is to add some spacers into our two child views, to make sure they put space between their text views.**

    So, update **`SkiDetailsView`** to this:

    ```swift
    var body: some View {
        Group {
            Text("Elevation: \(resort.elevation)m")
            Spacer()
            Text("Snow: \(resort.snowDepth)cm")
        }
    }
    ```

    And update **`ResortDetailsView`** to this:

    ```swift
    var body: some View {
        Group {
            Text("Size: \(size)")
            Spacer()
            Text("Price: \(price)")
        }
    }
    ```

    If you run the app again you’ll see things have gotten both better and worse at the same time: **better in landscape because all four pieces of text are spaced neatly across the view, but worse in portrait because those new spacers are causing havoc in our vertical stacks** – we have Size and Elevation at the top, then a large gap, then Price and Snow below.

    **To fix *this* problem we need to tell the spacers we only want them to work in landscape mode – they shouldn’t try to add space vertically.** 

    So, modify the spacers inside **`ResortDetailView`** and **`SkiDetailsView`** to **have zero height**, like this:

    ```swift
    Spacer().frame(height: 0)
    ```

    Once again this is a step forward combined with a step backward: **our vertical spacing has now disappeared as intended, but now the two child views don’t have space between them – the spacer we placed between them is now tiny.**

    This happens because using **`Spacer().frame(height: 0)`** **creates a frame that has a flexible width, causing the child views to take up all available space, which in turn means there’s nothing left for the spacer we placed between those two child views.**

    So, **we need to give that outer spacer a flexible width too – any frame at all is fine, because it will result in the same flexible frame**. Try this, for example:

    ```swift
    ResortDetailsView(resort: resort)
    Spacer().frame(height: 0)
    SkiDetailsView(resort: resort)
    ```

    Now we’re *almost* there: the layout looks good in portrait, and in landscape the four pieces of text are spaced evenly. However, **you might notice the elevation wraps across two lines even though there’s a lot of space free. This is another place where I think SwiftUI is at fault, because I think text should always have a higher layout priority than a spacer – hopefully this will get fixed in a future SwiftUI update.**

    In the meantime, **if this problem affects you then what we need to do is tell SwiftUI that our text is more important than our spacers.** This can be done by adding the **`layoutPriority(1)`** modifier to each of our four text views.

    So, the result of all these changes is that **`SkiDetailsView`** should look like this:

    ```swift
    var body: some View {
        Group {
            Text("Elevation: \(resort.elevation)m").layoutPriority(1)
            Spacer().frame(height: 0)
            Text("Snow: \(resort.snowDepth)cm").layoutPriority(1)
        }
    }
    ```

    **`ResortDetailsView`** should look like this:

    ```swift
    var body: some View {
        Group {
            Text("Size: \(size)").layoutPriority(1)
            Spacer().frame(height: 0)
            Text("Price: \(price)").layoutPriority(1)
        }
    }
    ```

    And the **`HStack`** in **`ResortView`** should look like this:

    ```swift
    HStack {
    		if sizeClass == .compact {
            Spacer()
            VStack { ResortDetailsView(resort: resort) }
            VStack { SkiDetailsView(resort: resort) }
            Spacer()
        } else {
            ResortDetailsView(resort: resort)
            Spacer().frame(height: 0)
            SkiDetailsView(resort: resort)
        }
    }
    .font(.headline)
    .foregroundColor(.secondary)
    .padding(.top)
    ```

    Now finally our layout should look great in both orientations: **one single line of text in a regular size class, and two rows of vertical stacks in a compact size class.** It took a little work, but we got there in the end!

    Our solution didn’t result in code duplication, which is a huge win, but it also left our two child views in a better place – they are now there just to serve up their content without specifying a layout. So, parent views can dynamically switch between **`HStack`** and **`VStack`** whenever they want, and SwiftUI will take care of the layout for us. The only rules we *did* encode are ones that make sense: our text is important, and should be even increased priority when it comes to layout.

- **Binding an alert to an optional string**

    **SwiftUI lets us present an alert when an optional value changes**, but this **isn’t quite so straightforward when working with optional strings as you’ll see.**

    To demonstrate this, **we’re going to rewrite the way our resort facilities are shown**. Right now we have a plain text view generated like this:

    ```swift
    Text(ListFormatter.localizedString(byJoining: resort.facilities))
        .padding(.vertical)
    ```

    **We’re going to replace that with icons that represent each facility, and when the user taps on one we’ll show an alert with a description of that facility.**

    As usual we’re going to start small then work our way up. **First, we need a way to convert facility names like “Accommodation” into an icon that can be displayed**. Although this will only happen in **`ResortView`** right now, **this functionality is exactly the kind of thing that should be available elsewhere in our project**. So, **we’re going to create a new struct to hold all this information for us.**

    Create a new Swift file called Facility.swift, replace its Foundation import with SwiftUI, and give it this code:

    ```swift
    struct Facility {
    		static func icon(for facility: String) -> some View {
    				let icons = [
                "Accommodation": "house",
                "Beginners": "1.circle",
                "Cross-country": "map",
                "Eco-friendly": "leaf.arrow.circlepath",
                "Family": "person.3"
            ]

    				if let iconName = icons[facility] {
    						let image = Image(systemName: iconName)
                                .accessibility(label: Text(facility))
                                .foregroundColor(.secondary)
    						return image
            } else {
                fatalError("Unknown facility type: \(facility)")
            }
        }
    }
    ```

    As you can see, **that has a single static method that accepts a facility name, looks it up in a dictionary, and returns a new image we can use for that facility**. I’ve picked out various SF Symbols icons that work well for the facilities we have, and I also used an **`accessibility(label:)`** modifier for the image to make sure it works well in VoiceOver.

    We can now drop that facilities view into **`ResortView`** by replacing this code:

    ```swift
    Text(ListFormatter.localizedString(byJoining: resort.facilities))
        .padding(.vertical)
    ```

    With this:

    ```swift
    HStack {
        ForEach(resort.facilities, id: \.self) { facility in
    				Facility.icon(for: facility)
                .font(.title)
        }
    }
    .padding(.vertical)
    ```

    **That loops over each item in the `facilities` array, converting it to an icon and placing it into a `HStack`**. 

    **I used the `.font(.title)` modifier to make the images larger – using the modifier here rather than inside `Facility` allows us more flexibility if we wanted to use these icons in other places.**

    That was the easy part. The harder part comes next: **we want to add an `onTapGesture()` modifier to those facility images so that we can show an alert when they are tapped.**

    Using the optional form of **`alert()`** this starts easily enough – add a new property to **`ResortView`** to store the currently selected facility name:

    ```swift
    @State private var selectedFacility: String?
    ```

    Now add this modifier to the facility icons, just below **`.font(.title)`**:

    ```swift
    .onTapGesture {
    		self.selectedFacility = facility
    }
    ```

    **We can create the alert in a very similar manner as we created the icons** – by adding a static method to the **`Facility`** struct that looks up the name in an dictionary:

    ```swift
    static func alert(for facility: String) -> Alert {
    		let messages = [
            "Accommodation": "This resort has popular on-site accommodation.",
            "Beginners": "This resort has lots of ski schools.",
            "Cross-country": "This resort has many cross-country ski routes.",
            "Eco-friendly": "This resort has won an award for environmental friendliness.",
            "Family": "This resort is popular with families."
        ]

    		if let message = messages[facility] {
    				return Alert(title: Text(facility), message: Text(message))
        } else {
            fatalError("Unknown facility type: \(facility)")
        }
    }
    ```

    **And now we can just add an `alert(item:)` modifier to the scroll view in `ResortView`, showing the correct alert whenever `selectedFacility` has a value:**

    ```swift
    .alert(item: $selectedFacility) { facility in
    		Facility.alert(for: facility)
    }
    ```

    If you try building that code you’ll be disappointed, because **it doesn’t work**. You see, **we can’t just bind any `@State` property to the `alert(item:)` modifier – it needs to be something that conforms to the `Identifiable` protocol**.

    The reason for this is subtle, but important: **if we set `selectedFacility` to some string an alert should appear, but if we then change it to a *different* string SwiftUI needs to be able to see that the value changed.**

    **Strings don’t conform to `Identifiable`, which is why we need to use `ForEach(resort.facilities, id: \.self) {`** when looping over the facilities.

    **There are two ways to fix this**: one that probably seems dubious at first but on reflection actually makes a lot of sense, and one that is more work but a bit less invasive.

    **The first solution is to make strings conform to `Identifiable`, so that we no longer need to use `id: \.self` everywhere**. This can be done with a tiny extension placed in any of the files in your project:

    ```swift
    extension String: Identifiable {
    		public var id: String { self }
    }
    ```

    With that our code now builds, and in fact you can change the aforementioned **`ForEach`** to this:

    ```swift
    ForEach(resort.facilities) { facility in
    ```

    **If you run the app now you’ll see it all works correctly**, and tapping any of the icons also shows an alert.

    Even better, we can now use strings natively anywhere that previously required us to use **`id: \.self`**. This simplifies quite a bit of SwiftUI, and if you ever do plan to use strings for these situations you have no choice but to use **`id: \.self`** regardless so this solution is exactly what you want.

    However, **one small thing does sit uncomfortably with me, which is this: it makes it a little too easy to use strings for identifiers, when often something like a `UUID` or an integer might work better.**

    If this also sits uncomfortably with you, I want to explore what a solution looks like. On the other hand if you’re perfectly comfortable using strings here – and honestly I think it’s a perfectly reasonable thing to do as long as you always remember that your strings need to be unique! – then by all means skip on to the next chapter.

    Still here? OK. To fix this we need to upgrade a few parts of our code.

    First, **we’re going to make `Facility` itself be `Identifiable`, which means giving it a unique `id` property and also storing the facility name somewhere in there**. This means we’ll create an instance of **`Facility`** and use its data, rather than relying on static methods.

    So, change the **`Facility`** struct to this:

    ```swift
    struct Facility: Identifiable {
    let id = UUID()
    var name: String

    var icon: some View {
    		let icons = [
                "Accommodation": "house",
                "Beginners": "1.circle",
                "Cross-country": "map",
                "Eco-friendly": "leaf.arrow.circlepath",
                "Family": "person.3"
            ]

    				if let iconName = icons[name] {
    						let image = Image(systemName: iconName)
                                .accessibility(label: Text(name))
                                .foregroundColor(.secondary)
    						return image
            } else {
                fatalError("Unknown facility type: \(name)")
            }
        }

    var alert: Alert {
    		let messages = [
                "Accommodation": "This resort has popular on-site accommodation.",
                "Beginners": "This resort has lots of ski schools.",
                "Cross-country": "This resort has many cross-country ski routes.",
                "Eco-friendly": "This resort has won an award for environmental friendliness.",
                "Family": "This resort is popular with families."
            ]

    				if let message = messages[name] {
    						return Alert(title: Text(name), message: Text(message))
            } else {
                fatalError("Unknown facility type: \(name)")
            }
        }
    }
    ```

    **Next, we’re going to update the `Resort` struct so that it has a computed property containing its facilities as an array of `Facility` rather than `String`.** 

    **This means we still load the original string array from JSON, but have a `[Facility]` alternative ready to hand. Ideally this would be done with a custom `Codable` initializer**, but I don’t want to cover that all over again!

    So, add this property to **`Resort`** now:

    ```swift
    var facilityTypes: [Facility] {
        facilities.map(Facility.init)
    }
    ```

    Now in **`ResortView`** we can update our code to use a **`Facility?`** rather than a **`String?`**.

    First, change the property:

    ```swift
    @State private var selectedFacility: Facility?
    ```

    Next, change the **`ForEach`** to use our new **`facilityTypes`** property rather than **`facilities`**, which in turn means we can access the icon directly because we have real **`Facility`** instances now:

    ```swift
    HStack {
        ForEach(resort.facilityTypes) { facility in
            facility.icon
                .font(.title)
                .onTapGesture {
    								self.selectedFacility = facility
                }
        }
    }
    .padding(.vertical)
    ```

    And finally we can replace the **`alert()`** modifier to use the facility alert, like this:

    ```swift
    .alert(item: $selectedFacility) { facility in
        facility.alert
    }
    ```

    That’s quite a bit of work, **but it does now mean we can remove the custom `String` extension – that’s quite an invasive change to make, and if Apple had meant it to be that easy I’m sure they would have made `alert(item:)` use a more common protocol that `String` already conforms to, such as `Equatable`.**

- **Letting the user mark favorites**

    The final task for this project is to l**et the user assign favorites to resorts they like**. This is mostly straightforward, using techniques we’ve already covered:

    - **Creating a new `Favorites` class that has a `Set` of resort IDs the user likes.**
    - **Giving it `add()`, `remove()`, and `contains()` methods that manipulate the data, sending update notifications to SwiftUI while also saving any changes to `UserDefaults`.**
    - **Injecting an instance of the `Favorites` class into the environment.**
    - **Adding some new UI to call the appropriate methods.**

    **Swift’s sets already contain methods for adding, removing, and checking for an element, but we’re going to add our own around them so we can use `objectWillChange` to notify SwiftUI that changes occurred**, and **also call a `save()` method so the user’s changes are persisted**. 

    This in turn means we can mark the favorites set using **`private`** access control, so we can’t accidentally bypass our methods and miss out saving.

    Create a new Swift file called Favorites.swift, replace its Foundation import with SwiftUI, then give it this code:

    ```swift
    class Favorites: ObservableObject {
        // the actual resorts the user has favorited
    		private var resorts: Set<String>

        // the key we're using to read/write in UserDefaults
    		private let saveKey = "Favorites"

    		init() {
            // load our saved data

            // still here? Use an empty array
    				self.resorts = []
        }

        // returns true if our set contains this resort
    		func contains(_ resort: Resort) -> Bool {
    	      resorts.contains(resort.id)
        }

        // adds the resort to our set, updates all views, and saves the change
    		func add(_ resort: Resort) {
            objectWillChange.send()
            resorts.insert(resort.id)
            save()
        }

        // removes the resort from our set, updates all views, and saves the change
    		func remove(_ resort: Resort) {
            objectWillChange.send()
            resorts.remove(resort.id)
            save()
        }

    		func save() {
            // write out our data
        }
    }
    ```

    You’ll notice I’ve missed out the actual functionality for loading and saving favorites – that will be your job to fill in shortly.

    We need to create a **`Favorites`** instance in **`ContentView`** and inject it into the environment so all views can share it. So, add this new property to **`ContentView`**:

    ```swift
    @ObservedObject var favorites = Favorites()
    ```

    Now inject it into the environment by adding this modifier to the **`NavigationView`**:

    ```swift
    .environmentObject(favorites)
    ```

    **Because that’s attached to the navigation view, every view the navigation view presents will also gain that `Favorites` instance to work with.** So, we can load it from inside **`ResortView`** by adding this new property:

    ```swift
    @EnvironmentObject var favorites: Favorites
    ```

    All this work hasn’t really accomplished much yet – sure, **the `Favorites` class gets loaded when the app starts, but it isn’t actually used anywhere despite having properties to store it.**

    This is easy enough to fix: **we’re going to add a button at the end of the scrollview in `ResortView` so that users can either add or remove the resort from their favorites, then display a heart icon in `ContentView` for favorite resorts.**

    First, add this to the end of the scrollview in **`ResortView`**:

    ```swift
    Button(favorites.contains(resort) ? "Remove from Favorites" : "Add to Favorites") {
    		if self.favorites.contains(self.resort) {
    				self.favorites.remove(self.resort)
        } else {
    				self.favorites.add(self.resort)
        }
    }
    .padding()
    ```

    Now we can show a colored heart icon next to favorite resorts in **`ContentView`** by adding this to the end of the **`NavigationLink`**:

    ```swift
    if self.favorites.contains(resort) {
        Spacer()
        
    		Image(systemName: "heart.fill")
    		    .accessibility(label: Text("This is a favorite resort"))
            .foregroundColor(.red)
    }
    ```

    **Tip:** As you can see, the **`foregroundColor()`** modifier works great here because our image uses SF Symbols.

    That *mostly* works, but you might notice a glitch: **if you favorite resorts with longer names you might find their name wraps onto two lines even though there’s space for it to be all on one.** This is yet another example where SwiftUI’s layout system allocates too much priority to spacers and not enough to text, so the fix for now – hopefully until Apple solves it soon! – is to **adjust the layout priority** of the **`VStack`** directly before the condition we just added:

    ```swift
    VStack(alignment: .leading) {
        Text(resort.name)
            .font(.headline)
        Text("\(resort.runs) runs")
            .foregroundColor(.secondary)
    }
    .layoutPriority(1)
    ```

    That should make the text layout correctly even with the spacer and heart icon – much better.

    And that also finishes our project, so give it one last try and see what you think. Good job!