# Day 58 - Project 12, part 2

- **Filtering @FetchRequest using NSPredicate**

    **When we use SwiftUI’s `@FetchRequest` property wrapper**, we can provide an array of sort descriptors to control the ordering of results, but **we can also provide an `NSPredicate` to control *which* results should be shown**. 

    **Predicates are simple tests, and the test will be applied to each object in our Core Data entity – only objects that pass the test will be included in the resulting array.**

    The syntax for **`NSPredicate`** isn’t something you can guess easily, but realistically you’re only ever going to want a few types of predicate so it’s not as bad as you think.

    To try out some predicates, create a new entity called Ship with two string attributes: “name” and “universe”.

    Now modify ContentView.swift to this:

    ```swift
    import CoreData
    import SwiftUI

    struct ContentView: View {
        @Environment(\.managedObjectContext) var moc
        @FetchRequest(entity: Ship.entity(), sortDescriptors: [], predicate: nil) var ships: FetchedResults<Ship>

        var body: some View {
            VStack {
                List(ships, id: \.self) { ship in
    								Text(ship.name ?? "Unknown name")
                }

                Button("Add Examples") {
                    let ship1 = Ship(context: self.moc)
                    ship1.name = "Enterprise"
                    ship1.universe = "Star Trek"

                    let ship2 = Ship(context: self.moc)
                    ship2.name = "Defiant"
                    ship2.universe = "Star Trek"

                    let ship3 = Ship(context: self.moc)
                    ship3.name = "Millennium Falcon"
                    ship3.universe = "Star Wars"

                    let ship4 = Ship(context: self.moc)
                    ship4.name = "Executor"
                    ship4.universe = "Star Wars"

                    try? self.moc.save()
                }
            }
        }
    }
    ```

    We can now press the button to inject some sample data into Core Data, but right now we don’t have a predicate. To fix that we need to replace the **`nil`** predicate value with some sort of test that can be applied to our objects.

    For example, **we could ask for ships that are from Star Wars**, like this:

    ```swift
    @FetchRequest(entity: Ship.entity(), sortDescriptors: [], predicate: NSPredicate(format: "universe == 'Star Wars'")) var ships: FetchedResults<Ship>
    ```

    That gets complicated if your data includes quote marks, so **it’s more common to use special syntax instead: `%@‘ means “insert some data here”, and allows us to provide that data as a parameter to the predicate rather than inline.**

    So, we could instead write this:

    ```swift
    NSPredicate(format: "universe == %@", "Star Wars"))
    ```

    **As well as `==`, we can also use comparisons such as `<` and `>` to filter our objects**. For example this will return Defiant, Enterprise, and Executor:

    ```swift
    NSPredicate(format: "name < %@", "F")) var ships: FetchedResults<Ship>
    ```

    **`%@`** is doing a lot of work behind the scenes, particularly when it comes to converting native Swift types to their Core Data equivalents. For example, **we could use an `IN` predicate to check whether the universe is one of three options from an array**, like this:

    ```swift
    NSPredicate(format: "universe IN %@", ["Aliens", "Firefly", "Star Trek"])
    ```

    **We can also use predicates to examine part of a string, using operators such as `BEGINSWITH` and `CONTAINS`**. For example, this will return all ships that start with a capital E:

    ```swift
    NSPredicate(format: "name BEGINSWITH %@", "E"))
    ```

    **That predicate is case-sensitive;** 

    **if you want to ignore case** you need to modify it to this:

    ```swift
    NSPredicate(format: "name BEGINSWITH[c] %@", "e"))
    ```

    **`CONTAINS[c]`** **works similarly, except rather than starting with your substring it can be anywhere inside the attribute.**

    Finally, **you can flip predicates around using `NOT`**, to get the inverse of their regular behavior. For example, this finds all ships that don’t start with an E:

    ```swift
    NSPredicate(format: "NOT name BEGINSWITH[c] %@", "e"))
    ```

    **If you need more complicated predicates, join them using `AND` to build up as much precision as you need, or add an import for Core Data and take a look at `NSCompoundPredicate` – it lets you build one predicate out of several smaller ones.**

- **Dynamically filtering @FetchRequest with SwiftUI**

    One of the SwiftUI questions I’ve been asked more than any other is this: **how can I dynamically change a Core Data `@FetchRequest` to use a different predicate or sort order?** 

    **The question arises because fetch requests are created as a property, so if you try to make them reference another property Swift will refuse.**

    There is a simple solution here, and it is usually pretty obvious in retrospect because it’s exactly how everything else works: **we should carve off the functionality we want into a separate view, then inject values into it.**

    I want to demonstrate this with some real code, so I’ve put together the simplest possible example: it adds three singers to Core Data, then uses two buttons to show either singers whose last name ends in A or S.

    Start by creating a new Core Data entity called Singer and give it two string attributes: “firstName” and “lastName”. Use the data model inspector to change its Codegen to Manual/None, then go to the Editor menu and select Create NSManagedObject Subclass so we can get a **`Singer`** class we can customize.

    Once Xcode has generated files for us, open Singer+CoreDataProperties.swift and add these two properties that make the class easier to use with SwiftUI:

    ```swift
    var wrappedFirstName: String {
        firstName ?? "Unknown"
    }

    var wrappedLastName: String {
        lastName ?? "Unknown"
    }
    ```

    OK, now onto the real work.

    The **first step is to design a view that will host our information**. 

    Like I said, this is also going to have two buttons that lets us change the way the view is filtered, and we’re going to have an extra button to insert some testing data so you can see how it works.

    First, **add two properties to your `ContentView` struct so that we have a managed object context we can save objects to, and some state we can use as a filter**:

    ```swift
    @Environment(\.managedObjectContext) var moc
    @State private var lastNameFilter = "A"
    ```

    For the body of the view, we’re going to use a **`VStack`** with three buttons, plus a comment for where we want the **`List`** to show matching singers:

    ```swift
    VStack {
        // list of matching singers

        Button("Add Examples") {
            let taylor = Singer(context: self.moc)
            taylor.firstName = "Taylor"
            taylor.lastName = "Swift"

            let ed = Singer(context: self.moc)
            ed.firstName = "Ed"
            ed.lastName = "Sheeran"

            let adele = Singer(context: self.moc)
            adele.firstName = "Adele"
            adele.lastName = "Adkins"

            try? self.moc.save()
        }

        Button("Show A") {
            self.lastNameFilter = "A"
        }

        Button("Show S") {
            self.lastNameFilter = "S"
        }
    }
    ```

    So far, so easy. Now for the interesting part: we need to replace that **`// list of matching singers`** comment with something real. 

    **This *isn’t* going to use `@FetchRequest` because we want to be able to create a custom fetch request inside an initializer**, but the code we’ll be using instead is almost identical.

    **Create a new SwiftUI view called “FilteredList”**, and give it this property:

    ```swift
    var fetchRequest: FetchRequest<Singer>
    ```

    **That will store our fetch request**, so that we can loop over it inside the **`body`**. 

    **However, we don’t *create* the fetch request here, because we still don’t know what we’re searching for.** 

    Instead, **we’re going to create a custom initializer that accepts a filter string and uses that to set the `fetchRequest` property**.

    Add this initializer now:

    ```swift
    init(filter: String) {
        fetchRequest = FetchRequest<Singer>(entity: Singer.entity(), sortDescriptors: [], predicate: NSPredicate(format: "lastName BEGINSWITH %@", filter))
    }
    ```

    That will run a fetch request using the current managed object context. Because this view will be used inside **`ContentView`**, **we don’t even need to inject a managed object context into the environment – it will inherit the context from `ContentView`.**

    All that remains is to write the body of the view, and **the only interesting thing here is that without `@FetchRequest` we need to read the `wrappedValue` property of `fetchRequest` to pull out our data**. So, give the view this body:

    ```swift
    var body: some View {
        List(fetchRequest.wrappedValue, id: \.self) { singer inText("\(singer.wrappedFirstName) \(singer.wrappedLastName)")
        }
    }
    ```

    **If you don’t like using `fetchRequest.wrappedValue`, you could create a simple computed property like this**:

    ```swift
    var singers: FetchedResults<Singer> { fetchRequest.wrappedValue }
    ```

    **As for the preview struct for `FilteredList`, you can remove it safely.**

    Now that the view is complete, we can return to **`ContentView`** and replace the comment with some actual code that passes our filter into **`FilteredList`**:

    ```swift
    FilteredList(filter: lastNameFilter)
    ```

    Now run the program to give it a try: tap the Add Examples button first to create three singer objects, then tap either “Show A” or “Show S” to toggle between surname letters. 

    **You should see our `List` dynamically update with different data, depending on which button you press.**

    So, it took a *little* new knowledge to make this work, but it really wasn’t that hard – as long as you think like SwiftUI, the solution is right there.

    ## **Want to go further?**

    **For more flexibility, we could improve our `FilteredList` view so that it works with any kind of entity, and can filter on any field**. 

    To make this work properly, we need to make a few changes:

    1. **Rather than specifically referencing the `Singer` class, we’re going to use generics with a constraint that whatever is passed in must be an `NSManagedObject`.**
    2. **We need to accept a second parameter to decide which key name we want to filter on**, because we might be using an entity that doesn’t have a **`lastName`** attribute.
    3. **Because we don’t know ahead of time what each entity will contain, we’re going to let our containing view decide**. So, **rather than just using a text view of a singer’s name, we’re instead going to ask for a closure that can be run to configure the view however they want.**

    There are two complex parts in there. 

    **The first is the closure that decides the content of each list row, because it needs to use two important pieces of syntax**. We looked at these towards the end of our earlier technique project on views and modifiers, but if you missed them:

    - **`@ViewBuilder`** **lets our containing view (whatever is using the list) send in multiple views, and our list will create an implicit `HStack` just like the regular `List`.**
    - **`@escaping` says the closure will be stored away and used later, which means Swift needs to take care of its memory.**

    **The second complex part is how we let our container view customize the search key**. Previously we controlled the filter value like this:

    ```swift
    NSPredicate(format: "lastName BEGINSWITH %@", filter)
    ```

    So you *might* take an educated guess and write code like this:

    ```swift
    NSPredicate(format: "%@ BEGINSWITH %@", keyName, filter)
    ```

    **However, that won’t work.** 

    You see, when we write **`%@`** **Core Data automatically inserts quote marks for us so that the predicate reads correctly.** This is helpful, because if our string contains quote marks it will automatically make sure they don’t clash with the quote marks it adds.

    **This means when we use `%@` for the attribute name we might end up with a predicate like this:**

    ```swift
    NSPredicate(format: "'lastName' BEGINSWITH 'S'")
    ```

    And that’s not correct: **the attribute name should *not* be in quote marks.**

    **To resolve this, `NSPredicate` has a special symbol that can be used to replace attribute names: `%K`, for “key”**. 

    This will insert values we provide, but won’t add quote marks around them. The correct predicate is this:

    ```swift
    NSPredicate(format: "%K BEGINSWITH %@", filterKey, filterValue)
    ```

    So, replace your current **`FilteredList`** struct with this:

    ```swift
    struct FilteredList<T: NSManagedObject, Content: View>: View {
        var fetchRequest: FetchRequest<T>
        var singers: FetchedResults<T> { fetchRequest.wrappedValue }

        // this is our content closure; we'll call this once for each item in the list
        let content: (T) -> Content

        var body: some View {
            List(fetchRequest.wrappedValue, id: \.self) { singer in
    					self.content(singer)
            }
        }

        init(filterKey: String, filterValue: String, @ViewBuilder content: @escaping (T) -> Content) {
            fetchRequest = FetchRequest<T>(entity: T.entity(), sortDescriptors: [], predicate: NSPredicate(format: "%K BEGINSWITH %@", filterKey, filterValue))
            self.content = content
        }
    }
    ```

    We can now use that new filtered list by upgrading **`ContentView`** like this:

    ```swift
    FilteredList(filterKey: "lastName", filterValue: lastNameFilter) { (singer: Singer) in
    	Text("\(singer.wrappedFirstName) \(singer.wrappedLastName)")
    }
    ```

    **Notice how I’ve specifically used `(singer: Singer)` as the closure’s parameter – this is required so that Swift understands how `FilteredList` is being used.** 

    **Remember, we said it could be any type of `NSManagedObject`, but in order for Swift to know exactly *what* type of managed object it is we need to be explicit.**

    Anyway, with that change in place we now use our list with any kind of filter key and any kind of entity – it’s much more useful!

- **One-to-many relationships with Core Data, SwiftUI, and @FetchRequest**

    **Core Data allows us to link entities together using relationships, and when we use `@FetchRequest` Core Data sends all that data back to us for use**. 

    However, this is one area where Core Data shows its age a little: **to get relationships to work well we need to make a custom `NSManagedObject` subclass that providers wrappers that are more friendly to SwiftUI.**

    To demonstrate this, **we’re going to build two Core Data entities: one to track candy bars, and one to track countries where those bars come from.**

    Relationships come in four forms:

    - **A one to one** relationship means that **one object in an entity links to exactly one object in another entity**.

        In our example, this would mean that each type of candy has one country of origin, and each country could make only one type of candy.

    - **A one to many** relationship means that **one object in an entity links to many objects in another entity**.

        In our example, this would mean that one type of candy could have been introduced simultaneously in many countries, but that each country still could only make one type of candy.

    - **A many to one** relationship means that **many objects in an entity link to one object in another entity**.

        In our example, this would mean that each type of candy has one country of origin, and that each country can make many types of candy.

    - **A many to many** relationship means that **many objects in an entity link to many objects in another entity**.

        In our example, this would mean that one type of candy had been introduced simultaneously in many countries, and each country can make many types of candy.

    All of those are used at different times, but in our candy example the many to one relationship makes the most sense – each type of candy was invented in a single country, but each country can have invented many types of candy.

    So, **open your data model and add two entities**: **Candy**, with a string attribute called “name”, **and Country**, with string attributes called “fullName” and “shortName”. Although some types of candy have the same name – see “Smarties” in the US and the UK – countries are definitely unique, so please **add a constraint for “shortName”.**

    **Tip:** Don’t worry if you’ve forgotten how to add constraints: select the Country entity, go to the View menu and choose Inspectors > Show Data Model Inspector, click the + button under Constraints, and rename the example to “shortName”.

    Before we’re done with this data model, **we need to tell Core Data there’s a one-to-many relationship between Candy and Country**:

    - With Country selected, press + under the Relationships table. Call the relationship “candy”, change its destination to Candy, then over in the data model inspector change Type to To Many.
    - Now select Candy, and add another relationship there. Call the relationship “origin”, change its destination to “Country”, then set its inverse to “candy” so Core Data understands the link goes both ways.

    That completes our entities, the next step is to take a look at the code Xcode generates for us. **Remember to press Cmd+S to force Xcode to save your changes.**

    Select both Candy and Country and set their Codegen to Manual/None, then go to the Editor menu and choose Create NSManagedObject Subclass to create code for both our entities – remember to save them in the CoreDataProject group and folder.

    As we chose two entities, Xcode will generate four Swift files for us. Candy+CoreDataProperties.swift will be pretty much exactly what you expect, although notice how **`origin`** is now a **`Country`**. Country+CoreDataProperties.swift is more complex, because Xcode also generated some methods for us to use.

    Previously we looked at how to clean up Core Data’s optionals using **`NSManagedObject`** subclasses, but here there’s a bonus complexity: **the `Country` class has a `candy` property that is an `NSSet`.** 

    **This is the older, Objective-C data type that is equivalent to Swift’s `Set`, but we can’t use it with SwiftUI’s `ForEach`.**

    To fix this we need to modify the files Xcode generated for us, **adding convenience wrappers that make SwiftUI work well**. For the **`Candy`** class this is as easy as just wrapping the **`name`** property so that it always returns a string:

    ```swift
    public var wrappedName: String {
        name ?? "Unknown Candy"
    }
    ```

    For the **`Country`** class we can create the same string wrappers around **`shortName`** and **`fullName`**, like this:

    ```swift
    public var wrappedShortName: String {
        shortName ?? "Unknown Country"
    }

    public var wrappedFullName: String {
        fullName ?? "Unknown Country"
    }
    ```

    However, things are more complicated when it comes to **`candy`**. **This is an `NSSet`, which could contain anything at all, because Core Data hasn’t restricted it to just instances of `Candy`.**

    So, **to get this thing into a useful form for SwiftUI we need to**:

    1. **Convert it from an `NSSet` to a `Set<Candy>` – a Swift-native type where we know the types of its contents.**
    2. **Convert that `Set<Candy>` into an array, so that `ForEach` can read individual values from there.**
    3. **Sort that array, so the candy bars come in a sensible order.**

    **Swift actually lets us perform steps 2 and 3 in one, because sorting a set automatically returns an array**. 

    However, **sorting the array is harder than you might think: this is an array of custom types, so we can’t just use `sorted()` and let Swift figure it out. Instead, we need to provide a closure that accepts two candy bars and returns true if the first candy should be sorted before the second.**

    So, please add this computed property to **`Country`** now:

    ```swift
    public var candyArray: [Candy] {
        let set = candy as? Set<Candy> ?? []
        return set.sorted {
            $0.wrappedName < $1.wrappedName
        }
    }
    ```

    That completes our Core Data classes, so now we can write some SwiftUI code to make all this work.

    Open ContentView.swift and give it these two properties:

    ```swift
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: Country.entity(), sortDescriptors: []) var countries: FetchedResults<Country>
    ```

    Notice how **we don’t need to specify anything about the relationships in our fetch request – Core Data understands the entities are linked, so it will just fetch them all as needed.**

    As for the body of the view, **we’re going to use a `List` with two `ForEach` views inside it: one to create a section for each country, and one to create the candy inside each country.** 

    This **`List`** will in turn go inside a **`VStack`** so we can add a button below to generate some sample data:

    ```swift
    VStack {
        List {
            ForEach(countries, id: \.self) { country inSection(header: Text(country.wrappedFullName)) {
                    ForEach(country.candyArray, id: \.self) { candy inText(candy.wrappedName)
                    }
                }
            }
        }

        Button("Add") {
            let candy1 = Candy(context: self.moc)
            candy1.name = "Mars"
            candy1.origin = Country(context: self.moc)
            candy1.origin?.shortName = "UK"
            candy1.origin?.fullName = "United Kingdom"

            let candy2 = Candy(context: self.moc)
            candy2.name = "KitKat"
            candy2.origin = Country(context: self.moc)
            candy2.origin?.shortName = "UK"
            candy2.origin?.fullName = "United Kingdom"

            let candy3 = Candy(context: self.moc)
            candy3.name = "Twix"
            candy3.origin = Country(context: self.moc)
            candy3.origin?.shortName = "UK"
            candy3.origin?.fullName = "United Kingdom"

            let candy4 = Candy(context: self.moc)
            candy4.name = "Toblerone"
            candy4.origin = Country(context: self.moc)
            candy4.origin?.shortName = "CH"
            candy4.origin?.fullName = "Switzerland"

            try? self.moc.save()
        }
    }
    ```

    Make sure you run that code, because it works really well – all our candy bars are automatically sorted into sections when the Add button is tapped. 

    Even better, because we did all the heavy lifting inside our **`NSManagedObject`** subclasses, the resulting SwiftUI code is actually remarkably straightforward – it has no idea that an **`NSSet`** is behind the scenes, and is much easier to understand as a result.

    **Tip:** If you don’t see your candy bars sorted into sections after pressing Add, make sure you haven’t removed the **`mergePolicy`** change from the **`willConnectTo`** method in **`SceneDelegate`**. As a reminder, it should be this: **`context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy`**.