# Day 62 - Project 13, part 1

- **How property wrappers become structs**

    You’ve seen how SwiftUI lets us store changing data in our structs by using the **`@State`** property wrapper, how we can bind that state to the value of a UI control using **`$`**, and how changes to that state automatically cause SwiftUI to reinvoke the **`body`** property of our struct.

    All that combined lets us write code such as this:

    ```swift
    struct ContentView: View {
        @State private var blurAmount: CGFloat = 0

        var body: some View {
            VStack {
                Text("Hello, World!")
                    .blur(radius: blurAmount)

                Slider(value: $blurAmount, in: 0...20)
            }
        }
    }
    ```

    If you run that, you’ll find that dragging the slider left and right adjusts the blur amount for the text label, exactly as you would expect.

    Now, **let’s say we want that binding to do *more* than just handle the radius of the blur effect. Perhaps we want to save that to `UserDefaults`, run a method, or just print out the value for debugging purposes**. **You might try updating the property like this**:

    ```swift
    @State private var blurAmount: CGFloat = 0 {
        didSet {
            print("New value is \(blurAmount)")
        }
    }
    ```

    If you run that code, you’ll be disappointed: as you drag the slider around you’ll see the blur amount change, but **you won’t see our `print()` statement being triggered – in fact, nothing will be output at all.**

    To understand what’s happening here, I want you to think about when we looked at Core Data: we used the **`@FetchRequest`** property wrapper to query our data, but I also showed you how to use the **`FetchRequest`** struct directly so that we had more control over how it was created.

    **Property wrappers have that name because they wrap our property inside another struct**. 

    **For many property wrappers that struct has the same name as the wrapper itself, but with `@FetchRequest` I showed you how we actually wanted to read the wrapped value inside – the fetched results – rather than the request itself.**

    **What this means is that when we use `@State` to wrap a string, the actual type of property we end up with is a `State<String>`**. 

    **Similarly, when we use `@Environment` and others we end up with a struct of type `Environment` that contains some other value inside it.**

    Previously I explained that **we can’t modify properties in our views because they are structs, and are therefore fixed**. However, ***now* you know that `@State` *itself* produces a struct, so we have a conundrum: how come *that* struct can be modified?**

    Xcode has a really helpful command called “Open Quickly” (accessed using Cmd+Shift+O), which lets you find any file or type in your project or any of the frameworks you have imported. Activate it now, and type “State” – hopefully the first result says SwiftUI below it, but if not please find that and select it.

    You’ll be taken to a generated interface for SwiftUI, which is essentially all the parts that SwiftUI exposes to us. There’s no implementation code in there, just lots of definitions for protocols, structs, modifiers, and such.

    We asked to see **`State`**, so you should have been taken to this line:

    ```swift
    @propertyWrapper public struct State<Value> : DynamicProperty {
    ```

    **That `@propertyWrapper` attribute is what makes this into `@State` for us to use.**

    Now look a few lines further down, and you should see this:

    ```swift
    public var wrappedValue: Value { get nonmutating set }
    ```

    **That wrapped value is the actual value we’re trying to store, such as a string.** 

    What **this generated interface is telling us is that the property can be read (`get`), and written (`set`)**, **but that when we set the value it won’t actually change the struct itself.** 

    **Behind the scenes, it sends that value off to SwiftUI for storage in a place where it can be modified freely, so it’s true that the struct itself never changes.**

    Now you know all that, let’s circle back to our broken code:

    ```swift
    @State private var blurAmount: CGFloat = 0 {
        didSet {
            print("New value is \(blurAmount)")
        }
    }
    ```

    On the surface, that states “when **`blurAmount`** changes, print out its new value.” However, because **`@State`** actually wraps its contents, what **it’s *actually* saying is that when the `State` struct that wraps `blurAmount` changes, print out the new blur amount.**

    Still with me? Now let’s go a stage further: **you’ve just seen how `State` wraps its value using a non-mutating setter, which means neither `blurAmount` or the `State` struct wrapping it are changing – our binding is directly changing the internally stored value, which means the property observer is never being triggered.**

    How then can we solve this – how can we attach some functionality to a wrapped property? For that we need custom bindings – let’s look at that next…

- **Creating custo bindings in SwiftUI**

    Because of the way SwiftUI sends binding updates to property wrappers, assigning property observers used with property wrappers won’t work, which means this kind of code won’t print anything even as the blur radius changes:

    ```swift
    struct ContentView: View {
        @State private var blurAmount: CGFloat = 0 {
            didSet {
                print("New value is \(blurAmount)")
            }
        }

        var body: some View {
            VStack {
                Text("Hello, World!")
                    .blur(radius: blurAmount)

                Slider(value: $blurAmount, in: 0...20)
            }
        }
    }
    ```

    **To fix this we need to create a custom binding – we need to use the `Binding` struct directly, which allows us to provide our own code to run when the value is read or written.**

    In our code, **we want a `Binding` to return the value of `blurAmount` when it’s read, but when it’s written we want to change the value of `blurAmount` and also print that new value** so we can see that it changed. 

    **Regardless of whether we’re reading or writing, we’re talking about something that reads our `blurAmount` property, and Swift doesn’t allow us to create properties that read other properties because the property we’re trying to read might not have been created yet**.

    So, putting all that together we need to create a custom **`Binding`** struct that acts as a passthrough around **`blurAmount`**, but when we’re setting the value we also want to print a message. 

    **It’s also a requirement that we *don’t* store it as a property of our view, because reading one property from another isn’t allowed**.

    As a result, we need to put this code into the **`body`** property of our view, like this:

    ```swift
    struct ContentView: View {
        @State private var blurAmount: CGFloat = 0

        var body: some View {
            let blur = Binding<CGFloat>(
                get: {
                    self.blurAmount
                },
                set: {
                    self.blurAmount = $0
                    print("New value is \(self.blurAmount)")
                }
            )

            return VStack {
                Text("Hello, World!")
                    .blur(radius: blurAmount)

                Slider(value: blur, in: 0...20)
            }
        }
    }
    ```

    Before we get into the binding itself, notice how some other things have stayed the same: we still use **`@State private var`** to declare the **`blurAmount`** property, and we still use **`blur(radius: blurRadius)`** as the modifier for our text view.

    **One thing that changed is the way we declare the binding in the slider: rather than using `$blurAmount` we can just use `blur`**. 

    **This is because using the dollar sign is what gets us the two-way binding from some state, but now that we’ve created the binding directly we no longer need it**.

    OK, now let’s look at the binding itself. As you should be able to figure out from the way we used it, the basic initializer for a **`Binding`** looks like this:

    ```swift
    init(get: @escaping () -> Value, set: @escaping (Value) -> Void)
    ```

    You can find that by press Cmd+Shift+O and looking up “Binding” in the generated interface for SwiftUI. 

    Breaking that down, it’s telling us that **the initializer takes two closures: a getter that takes no parameters and returns a value, and a setter that takes a value and returns nothing**. 

    `**Binding` uses generics, so that `Value` is really a placeholder for whatever we’re storing inside – a `CGFloat` in the case of our `blur` binding.** 

    **Both the `get` and `set` closures are marked as `@escaping`, meaning that the `Binding` struct stores them for use later on.**

    What all this means is that you can do whatever you want inside these closures: you can call methods, run an algorithm to figure out the correct value to use, or even just use random values – it doesn’t matter, as long as you return a value from **`get`**. So, if you want to make sure you update **`UserDefaults`** every time a value is changed, the **`set`** closure of a **`Binding`** is perfect.

- **Showing multiple options with ActionSheet**

    **SwiftUI gives us `Alert` for presenting important announcements with one or two buttons, and `sheet()` for presenting whole views on top of the current view, but it also gives us `ActionSheet`: an alternative to `Alert` that lets us add many buttons.**

    Visually alerts and action sheets are very different: on iPhones, **alert appear in the center of the screen and must actively be dismissed by choosing a button**, whereas **action sheets slide up from the bottom, can contain multiple buttons, and can be dismissed by tapping on Cancel or by tapping outside of the action sheet.**

    Apart from their presentation and differing numbers of buttons, action sheets and alerts share a lot of functionality. 

    **Both are created by attaching a modifier to our view hierarchy** – **`alert()`** for alerts and **`actionSheet()`** for action sheets – **both get shown automatically by SwiftUI when a condition is true, both use the same kind of button, and both have some built-in default styles for those buttons**: **`default()`**, **`cancel()`**, and **`destructive()`**.

    To demonstrate action sheets being used, we first need a basic view that toggles some sort of condition. For example, this shows some text, and tapping the text changes a Boolean:

    ```swift
    struct ContentView: View {
        @State private var showingActionSheet = false
        @State private var backgroundColor = Color.white

        var body: some View {
            Text("Hello, World!")
                .frame(width: 300, height: 300)
                .background(backgroundColor)
                .onTapGesture {
                    self.showingActionSheet = true
                }
        }
    }
    ```

    Now for the important part: we need to add another modifier to the text, creating and showing an action sheet when we’re ready.

    Just like **`alert()`**, **we have an `actionSheet()` modifier that accepts two parameters: a binding that decides whether the action sheet is currently presented or not, and a closure that provides the action sheet that should be shown** – usually provided as a trailing closure.

    **We provide our action sheet with a title and message, then an array of buttons**. 

    **These are stacked up vertically on the screen in the order you provide, and it’s generally a good idea to include a cancel button at the end** – yes, you *can* cancel by tapping elsewhere on the screen, but it’s much better to give users the explicit option!

    So, add this modifier to your text view:

    ```swift
    .actionSheet(isPresented: $showingActionSheet) {
        ActionSheet(title: Text("Change background"), message: Text("Select a new color"), buttons: [
            .default(Text("Red")) { self.backgroundColor = .red },
            .default(Text("Green")) { self.backgroundColor = .green },
            .default(Text("Blue")) { self.backgroundColor = .blue },
            .cancel()
        ])
    }
    ```

    When you run the app, you should find that tapping the text causes the action sheet to slide over, and tapping its options should cause the text’s background color to change.