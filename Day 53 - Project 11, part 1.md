# Day 53 - Project 11, part 1

- **Creating a custom component with @Binding**

    You’ve already seen how **SwiftUI’s `@State` property wrapper lets us work with local value types**, and how **`@ObservedObject`** **lets us work with shareable reference types**. 

    Well, there’s a third option, called `**@Binding`, which lets us connect an `@State` property of one view to some underlying model data.**

    Think about it: when we create a toggle switch we send in some sort of Boolean property that can be changed, like this:

    ```swift
    @State private var rememberMe = false

    var body: some View {
        Toggle(isOn: $rememberMe) {
            Text("Remember Me")
        }
    }
    ```

    So, the **toggle needs to change our Boolean when the user interacts with it, but how does it remember what value it should change?**

    That’s where **`@Binding`** comes in: **it lets us create a mutable value in a view, that actually points to some other value from elsewhere**. 

    In the case of **`Toggle`**, the switch changes its own local binding to a Boolean, but behind the scenes that’s actually manipulating the **`@State`** property in our view.

    This makes **`@Binding`** extremely important for whenever you want to create a custom user interface component. At their core, UI components are just SwiftUI views like everything else, but **`@Binding`** is what sets them apart: while they might have their local **`@State`** properties, they also expose **`@Binding`** properties that let them interface directly with other views.

    To demonstrate this, we’re going to create a new kind of button: one that stays down when pressed. Our basic implementation will all be stuff you’ve seen before: a button with some padding, a linear gradient for the background, a **`Capsule`** clip shape, and so on – add this to ContentView.swift now:

    ```swift
    struct PushButton: View {
        let title: String
        @State var isOn: Bool

        var onColors = [Color.red, Color.yellow]
        var offColors = [Color(white: 0.6), Color(white: 0.4)]

        var body: some View {
            Button(title) {
                self.isOn.toggle()
            }
            .padding()
            .background(LinearGradient(gradient: Gradient(colors: isOn ? onColors : offColors), startPoint: .top, endPoint: .bottom))
            .foregroundColor(.white)
            .clipShape(Capsule())
            .shadow(radius: isOn ? 0 : 5)
        }
    }
    ```

    The only vaguely exciting thing in there is that I used properties for the two gradient colors so they can be customized by whatever creates the button.

    We can now create one of those buttons as part of our main user interface, like this:

    ```swift
    struct ContentView: View {
        @State private var rememberMe = false

        var body: some View {
            VStack {
                PushButton(title: "Remember Me", isOn: rememberMe)
                Text(rememberMe ? "On" : "Off")
            }
        }
    }
    ```

    That has a text view below the button so we can track the state of the button – try running your code and see how it works.

    **What you’ll find is that tapping the button does indeed affect the way it appears, but our text view doesn’t reflect that change** – it always says “Off”. Clearly *something* is changing because the button’s appearance changes when it’s pressed, but that change isn’t being reflected in **`ContentView`**.

    **What’s happening here is that we’ve defined a one-way flow of data: `ContentView` has its `rememberMe` Boolean, which gets used to create a `PushButton` – the button has an initial value provided by `ContentView`. However, once the button was created it takes over control of the value: it toggles the `isOn` property between true or false internally to the button, but doesn’t pass that change back on to `ContentView`.**

    This is a problem, because **we now have two sources of truth: `ContentView` is storing one value, and `PushButton` another. Fortunately, this is where `@Binding` comes in: it allows us to create a two-way connection between `PushButton` and whatever is using it, so that when one value changes the other does too.**

    To switch over to **`@Binding`** we need to make just two changes. First, in **`PushButton`** change its **`isOn`** property to this:

    ```swift
    @Binding var isOn: Bool
    ```

    And second, in **`ContentView`** change the way we create the button to this:

    ```swift
    PushButton(title: "Remember Me", isOn: $rememberMe)
    ```

    **That adds a dollar sign before `rememberMe` – we’re passing in the binding itself, not the Boolean inside it.**

    Now run the code again, and you’ll find that everything works as expected: toggling the button now correctly updates the text view as well.

    **This is the power of `@Binding`: as far as the button is concerned it’s just toggling a Boolean – it has no idea that something else is monitoring that Boolean and acting upon changes.**

- **Using size classes with AnyView type erasure**

    **SwiftUI gives each of our views access to a shared pool of information known as the *environment***, and we already used it when dismissing sheets. If you recall, it meant creating a property like this:

    ```swift
    @Environment(\.presentationMode) var presentationMode
    ```

    Then when we were ready we could dismiss the sheet like this:

    ```swift
    Text("Hello World")
        .onTapGesture {
            self.presentationMode.wrappedValue.dismiss()
        }
    ```

    **This approach allows SwiftUI to make sure the correct state is updated when the view is dismissed – if we attached an `@State` property to present the sheet, for example, it would be set back to false when the sheet was dismissed.**

    **This environment is actually packed full of interesting things we can read to help make our apps work better.** 

    **In this project we’re going to be using the environment to work with Core Data, but here I’m going to show you another important use for it: *size classes*.** 

    **Size classes are Apple’s thoroughly vague way of telling us how much space we have for our views.**

    When I say “thoroughly vague” I mean it: 

    **we have only two size classes horizontally and vertically, called “compact” and “regular”.** 

    That’s it – that covers all screen sizes from the largest iPad Pro in landscape down to the smallest iPhone in portrait. That doesn’t mean it’s useless – far from it! – just that it only lets us reason about our user interfaces in the broadest terms.

    To demonstrate size classes in action, we could create a view that has a property to track the current size class and display it in a text view:

    ```swift
    struct ContentView: View {
        @Environment(\.horizontalSizeClass) var sizeClass

        var body: some View {
            if sizeClass == .compact {
                return HStack {
                    Text("Active size class:")
                    Text("COMPACT")
                }
                .font(.largeTitle)
            } else {
                return HStack {
                    Text("Active size class:")
                    Text("REGULAR")
                }
                .font(.largeTitle)
            }
        }
    }
    ```

    Please try running that in a landscape 12.9-inch iPad Pro simulator so you can get the full effect. At first you should see “REGULAR” displayed, because our app will be given the full screen. But if you swipe upwards gently from the bottom of the simulator screen the dock will appear, and you can drag out something like Safari into the right-hand side of the iPad to enter multi-tasking mode.

    Even when our app has only half the screen, you’ll still see our “REGULAR” label appear. But if you drag the splitter to the left – i.e., giving our app only a quarter or so of the available space – now it will change to “COMPACT”.

    **So, at full screen width we’re in a regular size class, and at half screen width we’re still in a regular size class, but when we go *smaller* then finally we’re compact.** Like I said: it’s broad terms.

    **Where things get more interesting is if we want to change our layouts depending on the environment.** 

    In this situation, it would make more sense to use a **`VStack`** rather than a **`HStack`** when we’re in a compact size class, however this is trickier than you might think.

    First, change the code so that we either return a **`VStack`** or a **`HStack`**:

    ```swift
    if sizeClass == .compact {
        return VStack {
            Text("Active size class:")
            Text("COMPACT")
        }
        .font(.largeTitle)
    } else {
        return HStack {
            Text("Active size class:")
            Text("REGULAR")
        }
        .font(.largeTitle)
    }
    ```

    **When you build the code you’ll see an ominous error: “Function declares an opaque return type, but the return statements in its body do not have matching underlying types.”**

    That is, **the `some View` return type of `body` requires that one single type is returned from all paths in our code – we can’t sometimes return one view and other times return something else.**

    You might think you’re going to be clever, and wrap our whole condition inside another view, such as a **`VStack`**, but that doesn’t work either. 

    Instead, **we need a more advanced solution called *type erasure***. 

    I say “advanced” because conceptually it’s very clever and because the implementation of it can be non-trivial, but from *our* perspective – i.e., actually using it – type erasure is marvelously simple.

    First, let’s look at the code – replace your current **`body`** code with this:

    ```swift
    if sizeClass == .compact {
        return AnyView(VStack {
            Text("Active size class:")
            Text("COMPACT")
        }
        .font(.largeTitle))
    } else {
        return AnyView(HStack {
            Text("Active size class:")
            Text("REGULAR")
        }
        .font(.largeTitle))
    }
    ```

    I know that’s quite dense to read, so let me simplify what’s changed:

    ```swift
    return AnyView(HStack {
        // ...
    }
    .font(.largeTitle))
    ```

    If you build the code again you’ll see it compiles cleanly, and even better it looks great when it runs – the app now smoothly switches between a **`HStack`** and a **`VStack`** depending on the size class.

    What’s changed is that **we wrapped both our stacks in a new view type called `AnyView`, which is what’s called a *type erased wrapper*.**

    **`AnyView`** **conforms to the same `View` protocol as `Text`, `Color`, `VStack`, and more, and it also contains inside it a view of a specific type**. 

    **However, externally `AnyView` doesn’t expose what it contains – Swift sees our condition as returning either an `AnyView` or an `AnyView`, so it’s considered the same type.** 

    This is where the name “type erasure” comes from: **`AnyView`** **effectively hides – or *erases* – the type of the views it contains.**

    Now, the logical conclusion here is to ask **why we don’t use `AnyView` *all* the time if it lets us avoid the restrictions of `some View`. The answer is simple: performance.** 

    **When SwiftUI knows exactly what’s in our view hierarchy, it can add and remove small parts trivially as needed, but when we use `AnyView` we’re actively denying SwiftUI that information. As a result, it’s likely to have to do significantly more work to keep our user interface updated when regular changes happen**, so 

    **it’s generally best to avoid `AnyView` unless you specifically need it.**

- **How to combine Core Data and SwiftUI**

    SwiftUI and Core Data were introduced almost exactly a decade apart – SwiftUI with iOS 13, and Core Data with iPhoneOS 3; so long ago it wasn’t even called iOS because the iPad wasn’t released yet. Despite their distance in time, Apple put in a ton of work to make sure these two powerhouse technologies work beautifully alongside each other, meaning that Core Data integrates into SwiftUI as if it were always designed that way.

    First, the basics: **Core Data is an object graph and persistence framework, which is a fancy way of saying it lets us define objects and properties of those objects, then lets us read and write them from permanent storage.** 

    On the surface this sounds like using **`Codable`** and **`UserDefaults`**, but it’s much more advanced than that: **Core Data is capable of sorting and filtering of our data, and can work with much larger data – there’s effectively no limit to how much data it can store**. 

    Even better, **Core Data implements all sorts of more advanced functionality for when you really need to lean on it: data validation, lazy loading of data, undo and redo, and much more**.

    In this project we’re going to be using only a small amount of Core Data’s power, but that will expand soon enough – I just want to give you a taste of it at first. When you created your Xcode project I asked you to check the Use Core Data box, and it should have resulted in changes to your project:

    - **You now have a file called Bookworm.xcdatamodeld. This describes your data model, which is effectively a list of classes and their properties.**
    - **There is now extra code in AppDelegate.swift and SceneDelegate.swift for setting up Core Data.**

    **Setting up Core Data requires two steps:** 

    - **creating what’s called a *persistent container*, which is what loads and saves the actual data from device storage,**
    - **and injecting that into the SwiftUI environment so that all our views can access it.**

    **Both of these steps are already done for us by the Xcode template.**

    So, **what remains is for us to decide what data we want to store in Core Data, and how to read it back out**. To start that, we need to open Bookworm.xcdatamodeld and start describing our data using Xcode’s model editor.

    Previously we described data like this:

    ```swift
    struct Student {
        var id: UUID
        var name: String
    }
    ```

    However, Core Data doesn’t work like that. You see, Core Data needs to know ahead of time what all our data types look like, what it contains, and how it relates to each other. This is where the **“xcdatamodeld” file comes in: we define our types as “entities”, then create properties in there as “attributes”, and Core Data is responsible for converting that into an actual database layout it can work with at runtime.**

    For trial purposes, please press the Add Entity button to create a new entity, then double click on its name to rename it “Student”. Next, click the + button directly below the Attributes table to add two attributes: “id” as a UUID and “name” as a string. That tells Core Data everything we need to know to create students and save them, so head back to ContentView.swift so we can write some code.

    **Retrieving information from Core Data is done using a *fetch request* – we describe what we want, how it should sorted, and whether any filters should be used, and Core Data sends back all the matching data**. 

    **We need to make sure that this fetch request stays up to date over time, so that as students are created or removed our UI stays synchronized.**

    SwiftUI has a solution for this, and – you guessed it – it’s another property wrapper. 

    This time it’s called **`@FetchRequest`** and **it takes two parameters: the entity we want to query, and how we want the results to be sorted**. 

    It has quite a specific format, so let’s start by adding a fetch request for our students – please add this property to **`ContentView`** now:

    ```swift
    @FetchRequest(entity: Student.entity(), sortDescriptors: []) var students: FetchedResults<Student>
    ```

    Broken down, **that creates a fetch request for our “Student” entity, applies no sorting, and places it into a property called `students` that has the the type `FetchedResults<Student>`**.

    **From there, we can start using `students` like a regular Swift array**, but there’s one catch as you’ll see. First, some code that puts the array into a **`List`**:

    ```swift
    var body: some View {
        VStack {
            List {
                ForEach(students, id: \.id) { student inText(student.name ?? "Unknown")
                }
            }
        }
    }
    ```

    Did you spot the catch? Yes, `**student.name` is an optional – it might have a value or it might not**. 

    **This is one area of Core Data that will annoy you greatly: it has the concept of optional data, but it’s an entirely different concept to Swift’s optionals.** 

    **If we say to Core Data “this thing can’t be optional” (which you can do inside the model editor), it will *still* generate optional Swift properties, because all Core Data cares about is that the properties have values when they are saved – they can be nil at other times.**

    You can run the code if you want to, but there isn’t really much point – the list will be empty because we haven’t added any data yet, so our database is empty. 

    To fix that **we’re going to create a button below our list that adds a new random student every time it’s tapped**, **but first we need a new property to store a *managed object context*.**

    Let me back up a little, because this matters. 

    **When we defined the “Student” entity, what actually happened was that Core Data created a class for us that inherits from one of its own classes: `NSManagedObject`**. 

    **We can’t see this class in our code, because it’s generated automatically when we build our project**, just like Core ML’s models. 

    **These objects are called *managed* because Core Data is looking after them**: **it loads them from the persistent container and writes their changes back too.**

    **All our managed objects live inside a *managed object context***, **which is the thing that’s responsible for actually fetching managed objects, as well as for saving changes and more**. 

    **You can have many managed object contexts if you want, but that’s quite a way away right now – realistically you’ll be fine with one for a long time yet.**

    **We don’t need to create this managed object context, because Xcode already made one for us**. Even better, **it already added it to the SwiftUI environment**, **which is what makes the `@FetchRequest` property wrapper work – it uses whatever managed object context is available in the environment.**

    Anyway, **when it comes to adding and saving objects, we need access to the managed object context that it is in SwiftUI’s environment**. 

    This is another use for the **`@Environment`** property wrapper – **we can ask it for the current managed object context, and assign it to a property for our use.**

    So, add this property to **`ContentView`** now:

    ```swift
    @Environment(\.managedObjectContext) var moc
    ```

    With that in place, the next step is add a button that generates random students and saves them in the managed object context. To help the students stand out, we’ll assign random names by creating **`firstNames`** and **`lastNames`** arrays, then using **`randomElement()`** to pick one of each.

    Start by adding this button just below the **`List`**:

    ```swift
    Button("Add") {
        let firstNames = ["Ginny", "Harry", "Hermione", "Luna", "Ron"]
        let lastNames = ["Granger", "Lovegood", "Potter", "Weasley"]

        let chosenFirstName = firstNames.randomElement()!
        let chosenLastName = lastNames.randomElement()!

        // more code to come        
    }
    ```

    **Note:** Inevitably there are people that will complain about me force unwrapping those calls to **`randomElement()`**, but we literally just hand-created the arrays to have values – it will always succeed. If you desperately hate force unwraps, perhaps replace them with nil coalescing and default values.

    Now for the interesting part: **we’re going to create a `Student` object, using the class Core Data generated for us**. 

    **This needs to be attached to a managed object context**, **so the object knows where it should be stored**.

    We can then assign values to it just like we normally would for a struct.

    So, add these three lines to the button’s action closure now:

    ```swift
    let student = Student(context: self.moc)
    student.id = UUID()
    student.name = "\(chosenFirstName) \(chosenLastName)"
    ```

    **Finally we need to ask our managed object context to save itself.** 

    **This is a throwing function call, because in theory it might fail**. 

    In practice, nothing about what we’ve done has any chance of failing, so we can call this using **`try?`** – we don’t care about catching errors.

    So, add this final line to the button’s action:

    ```swift
    try? self.moc.save()
    ```

    At last, you should now be able to run the app and try it out – click the Add button a few times to generate some random students, and you should see them slide somewhere into our list. Even better, if you relaunch the app you’ll find your students are still there, because Core Data saved them.

    Now, you might think this was an awful lot of learning for not a lot of result, but you now know what entities and attributes are, you know what managed objects and fetch requests are, and you’ve seen how to save changes. We’ll be looking at Core Data more later on in this project, as well in the future, but for now you’ve come far.

    This was the last part of the overview for this project, so please reset your code back to its initial state, and make sure you delete the Student entity from our data model – we don’t need it any more.