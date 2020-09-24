# Day 23 - Project 3, part 1

- **Why does SwiftUI use structs for views?**

    If you ever programmed for **UIKit** **or AppKit** (Apple’s original user interface frameworks for iOS and macOS) you’ll know that they **use *classes* for views rather than structs**. 

    **SwiftUI does not**: we prefer to use structs for views across the board, and there are a couple of **reasons why**.

    First, there is an element of **performance**: **structs are simpler and faster than classes**. I say *an element* of performance because lots of people think this is the primary reason SwiftUI uses structs, when really it’s just one part of the bigger picture.

    **In UIKit, every view descended from a class called `UIView` that had many properties and methods** – a background color, constraints that determined how it was positioned, a layer for rendering its contents into, and more. There were *lots* of these, and **every `UIView` and `UIView` subclass had to have them, because that’s how inheritance works.**

    Often this wasn’t a problem, but there was a particular subclass called **`UIStackView`**, which is analogous to **`VStack`** and **`HStack`** in SwiftUI. **In UIKit, `UIStackView` was a non-rendering view type designed to make layout easier, but it meant that even though it had a background color thanks to inheritance, that background color never actually got used.**

    **In SwiftUI, all our views are trivial structs and are almost free to create.** 

    Think about it: **if you make a struct that holds a single integer, the entire size of your struct is… that one integer. Nothing else.** No surprise extra values inherited from parent classes, or grandparent classes, or great-grandparent classes, etc – **they contain exactly what you can see and nothing more.**

    Thanks to the power of modern iPhones, I wouldn’t think twice about creating 1000 integers or even 100,000 integers – it would happen in the blink of an eye. The same is true of 1000 SwiftUI views or even 100,000 SwiftUI views; they are so fast it stops being worth thinking about.

    However, even though performance is important **there’s something much more important about views as structs: it forces us to think about isolating state in a clean way.** 

    You see, classes are able to change their values freely, which can lead to messier code – how would SwiftUI be able to know when a value changed in order to update the UI?

    By producing views that don’t mutate over time, **SwiftUI encourages us to move to a more functional design approach: our views become simple, inert things that convert data into UI, rather than intelligent things that can grow out of control.**

    You can see this in action when you look at the kinds of things that can be a view. **We already used `Color.red` and `LinearGradient` as views – trivial types that hold very little data.** In fact, you can’t get a great deal simpler than using **`Color.red`** as a view: it holds no information other than “fill my space with red”.

    In comparison, Apple’s [documentation for UIView](https://developer.apple.com/documentation/uikit/uiview) lists about 200 properties and methods that **`UIView`** has, all of which get passed on to its subclasses whether they need them or not.

    **Tip:** If you use a class for your view you might find your code either doesn’t compile or crashes at runtime. Trust me on this: use a struct.

- **What is behind the main SwiftUI view?**

    When you’re just starting out with SwiftUI, you get this code:

    ```swift
    struct ContentView: View {
        var body: some View {
            Text("Hello World")
        }
    }
    ```

    **It’s common to then modify that text view with a background color and expect it to fill the screen**:

    ```swift
    struct ContentView: View {
        var body: some View {
            Text("Hello World")
                .background(Color.red)
        }
    }
    ```

    However, that doesn’t happen. **Instead, we get a small red text view in the center of the screen, and a sea of white beyond it**.

    This confuses people, and usually leads to the question – “how do I make what’s behind the view turn red?”

    Let me say this as clearly as I can: **for SwiftUI developers, there is nothing behind our view.** 

    You shouldn’t try to make that white space turn red with weird hacks or workarounds, and you certainly shouldn’t try to reach outside of SwiftUI to do it.

    Now, **right now at least there is something behind our content view called a `UIHostingController`: it is the bridge between UIKit** (Apple’s original iOS UI framework) **and SwiftUI.** 

    However, **if you start trying to modify that you’ll find that your code no longer works on Apple’s other platforms, and in fact might stop working entirely on iOS at some point in the future.**

    Instead, **you should try to get into the mindset that there is nothing behind our view** – **that what you see is all we have.**

    **Once you’re in that mindset, the correct solution is to make the text view take up more space; to allow it to fill the screen rather than being sized precisely around its content**. We can do that by using the **`frame()`** modifier, passing in **`.infinity`** for both its maximum width and maximum height.

    ```swift
    Text("Hello World")
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.red)
    ```

    Using **`maxWidth`** and **`maxHeight`** is different from using **`width`** and **`height`** – **we’re not saying the text view *must* take up all that space, only that it *can***. 

    **If you have other views around, SwiftUI will make sure they all get enough space.**

    **By default your view won’t leave the safe area, but you can change that by using the `edgesIgnoringSafeArea()` modifier** like this:

    ```swift
    Text("Hello World")
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.red)
        .edgesIgnoringSafeArea(.all)
    ```

- **Why modifier order matters**

    **Whenever we apply a modifier to a SwiftUI view, we actually create a new view with that change applied** – **we don’t just modify the existing view in place**. 

    If you think about it, this behavior makes sense – our views only hold the exact properties we give them, so if we set the background color or font size there is no place to store that data.

    We’re going to look at *why* this happens in the next chapter, but first I want to look at the practical implications of this behavior. Take a look at this code:

    ```swift
    Button("Hello World") {
        // do nothing
    }    
    .background(Color.red)
    .frame(width: 200, height: 200)
    ```

    What do you think that will look like when it runs?

    Chances are you guessed wrong: **you *won’t* see a 200x200 red button with “Hello World” in the middle. Instead, you’ll see a 200x200 empty square, with “Hello World” in the middle and with a red rectangle directly around “Hello World”.**

    You can understand what’s happening here if you think about **the way modifiers work: each one creates a new struct with that modifier applied, rather than just setting a property on the view.**

    **You can peek into the underbelly of SwiftUI by asking for the type of our view’s body**. Modify the button to this:

    ```swift
    Button("Hello World") {
        print(type(of: self.body))
    }    
    .background(Color.red)
    .frame(width: 200, height: 200)
    ```

    Swift’s **`type(of:)`** method prints the exact type of a particular value, and **in this instance it will print** the following: **`ModifiedContent<ModifiedContent<Button<Text>, _BackgroundModifier<Color>>, _FrameLayout>`**

    **You can see two things here**:

    - **Every time we modify a view SwiftUI applies that modifier by using generics**: **`ModifiedContent<OurThing, OurModifier>`**.
    - **When we apply multiple modifiers, they just stack up**: **`ModifiedContent<ModifiedContent<…`**

    To read what the type is, **start from the innermost type and work your way out**:

    - **The innermost type is** **`ModifiedContent<Button<Text>, _BackgroundModifier<Color>`**: **our button has some text with a background color applied.**
    - **Around that we have** **`ModifiedContent<…, _FrameLayout>`**, which **takes our first view** (button + background color) **and gives it a larger frame.**

    As you can see, we end with **`ModifiedContent`** types stacking up – **each one takes a view to transform plus the actual change to make, rather than modifying the view directly.**

    What this means is that **the order of your modifiers matter.** 

    If we rewrite our code to apply the background color *after* the frame, then you might get the result you expected:

    ```swift
    Button("Hello World") {
        print(type(of: self.body))
    }
    .frame(width: 200, height: 200)
    .background(Color.red)
    ```

    **The best way to think about it for now is to imagine that SwiftUI renders your view after every single modifier**. So, as soon as you say **`.background(Color.red)`** it colors the background in red, regardless of what frame you give it. If you then later expand the frame, it won’t magically redraw the background – that was already applied.

    **Of course, this isn’t *actually* how SwiftUI works, because if it did it would be a performance nightmare, but it’s a neat mental shortcut to use while you’re learning.**

    **An important side effect of using modifiers is that we can apply the same effect multiple times: each one simply adds to whatever was there before.**

    For example, **SwiftUI gives us the `padding()` modifier, which adds a little space around a view** so that it doesn’t push up against other views or the edge of the screen. I**f we apply padding then a background color, then more padding and a different background color, we can give a view multiple borders**, like this:

    ```swift
    Text("Hello World")
        .padding()
        .background(Color.red)
        .padding()
        .background(Color.blue)
        .padding()
        .background(Color.green)
        .padding()
        .background(Color.yellow)
    ```

- **Why does SwiftUI use "some View" for its view type?**

    SwiftUI relies very heavily on a Swift power feature called **“opaque return types”**, which you can see in action every time you write `some View`. 

    **This means “one specific type that conforms to the `View` protocol, but we don’t want to say what.”**

    Returning **`some View`** **has two important differences compared to just returning** **`View`**:

    1. **We must always return the same type of view.**
    2. **Even though we don’t know what view type is going back, the compiler does.**

    **The first difference is important for performance: SwiftUI needs to be able to look at the views we are showing and understand how they change, so it can correctly update the user interface.** 

    If we were allowed to change views randomly, it would be really slow for SwiftUI to figure out exactly what changed – it would pretty much need to ditch everything and start again after every small change.

    **The second difference is important because of the way SwiftUI builds up its data using `ModifiedContent`**. Previously I showed you this code:

    ```swift
    Button("Hello World") {
        print(type(of: self.body))
    }
    .frame(width: 200, height: 200)
    .background(Color.red)
    ```

    That creates a simple button then makes it print its exact Swift type, and gives some long output with a couple of instances of **`ModifiedContent`**.

    **The `View` protocol has an associated type attached to it, which is Swift’s way of saying that `View` by itself doesn’t mean anything – we need to say exactly what kind of view it is.** 

    **It effectively has a hole in it, in just the same way Swift doesn’t let us say “this variable is an array” and instead requires that we say what’s *in* the array: “this variable is a string array.”**

    So, while **it’s not allowed to write a view like this**:

    ```swift
    struct ContentView: View {
        var body: View {
            Text("Hello World")
        }
    }
    ```

    **It is perfectly legal to write a view like this:**

    ```swift
    struct ContentView: View {
        var body: Text {
            Text("Hello World")
        }
    }
    ```

    **Returning `View` makes no sense, because Swift wants to know what’s inside the view – it has a big hole that must be filled**. 

    On the other hand, **returning `Text` is fine, because we’ve filled the hole; Swift knows what the view is.**

    Now let’s return to our code from earlier:

    ```swift
    Button("Hello World") {
        print(type(of: self.body))
    }
    .frame(width: 200, height: 200)
    .background(Color.red)
    ```

    If we want to return one of those from our **`body`** property, what should we write? While you could try to figure out the exact combination of **`ModifiedContent`** generics, it’s hideously painful and the simple truth is that we don’t care: it’s all internal SwiftUI stuff.

    What **`some View`** lets us do is say **“this will return one specific type of view, such as `Button` or `Text`, but I don’t want to say what.”** 

    So, the hole that View has will be filled by a real view, but we aren’t required to write out the exact long type.

    ## **Want to go further?**

    Now, in case you were curious you might wonder how SwiftUI is able to deal with **something like `VStack` – it conforms to the `View` protocol, but how does it fill the “what kind of content does it have?” hole if it can contain lots of different things inside it?**

    Well, **if you create a `VStack` with two text views inside, SwiftUI silently creates a `TupleView` to contain those two views** – **a special type of view that holds exactly two views inside it.** 

    **So, the `VStack` fills the “what kind of view is this?” with the answer “it’s a `TupleView` containing two text views.”**

    **And what if you have three text views inside the `VStack`? Then it’s a `TupleView` containing three views. Or four views. Or eight views, or even ten views – there is literally a version of `TupleView` that tracks ten different kinds of content**:

    ```swift
    TupleView<(C0, C1, C2, C3, C4, C5, C6, C7, C8, C9)>
    ```

    And **that’s why SwiftUI doesn’t allow more than 10 views inside a parent: they wrote versions of `TupleView` that handle 2 views through 10, but no more.**

- **Conditional modifiers**

    **It’s common to want modifiers that apply only when a certain condition is met**, and **in SwiftUI the easiest way to do that is with the ternary operator.**

    As a reminder, to use the ternary operator you write your condition first, then a question mark and what should be used if the condition is true, then a colon followed by what should be used if the condition is false.

    For example, **if you had a property that could be either true or false, you could use that to control the foreground color of a button** like this:

    ```swift
    struct ContentView: View {
        @State private var useRedText = false

        var body: some View {
            Button("Hello World") {
                // flip the Boolean between true and false
                self.useRedText.toggle()            
            }
            .foregroundColor(useRedText ? .red : .blue)
        }
    }
    ```

    So, **when `useRedText` is true the modifier effectively reads `.foregroundColor(.red)`, and when it’s false the modifier becomes `.foregroundColor(.blue)`.** 

    Because **SwiftUI watches for changes in our `@State` properties and re-invokes our `body` property**, whenever that property changes the color will immediately update.

    **You can sometimes use regular `if` conditions to return different views based on some state, but this is only possible in a handful of cases.**

    For example, **this kind of code isn’t allowed**:

    ```swift
    var body: some View {
        if self.useRedText {
            return Text("Hello World")
        } else {
            return Text("Hello World")
                .background(Color.red)
        }
    }
    ```

    Remember, **`some View`** **means “one specific type of View will be returned, but we don’t want to say what.”** 

    **Because of the way SwiftUI creates new views using generic `ModifiedContent` wrappers, `Text(…)` and `Text(…).background(Color.red)` are different underlying types and that isn’t compatible with `some View`.**

- **Environment modifiers**

    **Many modifiers can be applied to containers, which allows us to apply the same modifier to many views at the same time.**

    For example, **if we have four text views in a `VStack` and want to give them all the same font modifier, we could apply the modifier to the `VStack` directly and have that change apply to all four text views**:

    ```swift
    VStack {
        Text("Gryffindor")
        Text("Hufflepuff")
        Text("Ravenclaw")
        Text("Slytherin")
    }
    .font(.title)
    ```

    **This is called an environment modifier**, and is different from a regular modifier that is applied to a view.

    From a coding perspective these modifiers are used exactly the same way as regular modifiers. However, **they behave subtly differently because if any of those child views override the same modifier, the child’s version takes priority.**

    As an example, this shows our four text views with the title font, but one has a large title:

    ```swift
    VStack {
        Text("Gryffindor")
            .font(.largeTitle)
        Text("Hufflepuff")
        Text("Ravenclaw")
        Text("Slytherin")
    }
    .font(.title)
    ```

    There, `**font()` is an environment modifier, which means the Gryffindor text view can override it with a custom font.**

    However, this applies a blur effect to the **`VStack`** then attempts to disable blurring on one of the text views:

    ```swift
    VStack {
        Text("Gryffindor")
            .blur(radius: 0)
        Text("Hufflepuff")
        Text("Ravenclaw")
        Text("Slytherin")
    }
    .blur(radius: 5)
    ```

    That won’t work the same way: **`blur()`** **is a regular modifier, so any blurs applied to child views are *added* to the `VStack` blur rather than replacing it.**

    To the best of my knowledge **there is no way of knowing ahead of time which modifiers are environment modifiers and which are regular modifiers – you just need to experiment**. 

    Still, I’d rather have them than not: being able to apply one modifier everywhere is much better than copying and pasting the same thing into multiple places.

- **Views as properties**

    **There are lots of ways to make it easier to use complex view hierarchies in SwiftUI, and one option is to use properties** – **to create a view as a property of your own view, then use that property inside your layouts.**

    For example, we could create two text views like this as properties, then use them inside a **`VStack`**:

    ```swift
    struct ContentView: View {
        let motto1 = Text("Draco dormiens")
        let motto2 = Text("nunquam titillandus")

        var body: some View {
            VStack {
                motto1
                motto2
            }
        }
    }
    ```

    **You can even apply modifiers directly to those properties** as they are being used, like this:

    ```swift
    VStack {
        motto1
            .foregroundColor(.red)
        motto2
            .foregroundColor(.blue)
    }
    ```

    **Creating views as properties can be helpful to keep your `body` code clearer** – not only does it **help avoid repetition**, but it **can also get more complex code out of the `body` property**.

    **Swift doesn’t let us create one stored property that refers to other stored properties**, because it would cause problems when the object is created. 

    **This means trying to create a `TextField` bound to a local property will cause problems.**

    However, **you can create *computed* properties if you want**, like this:

    ```swift
    var motto1: some View { Text("Draco dormiens") }
    ```

- **View composition**

    SwiftUI lets us break complex views down into smaller views without incurring much if any performance impact. 

    This means that **we can split up one large view into multiple smaller views, and SwiftUI takes care of reassembling them for us.**

    For example, in this view we have a particular way of styling text views – they have a large font, some padding, foreground and background colors, plus a capsule shape:

    ```swift
    struct ContentView: View {
        var body: some View {
            VStack(spacing: 10) {
                Text("First")
                    .font(.largeTitle)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .clipShape(Capsule())

                Text("Second")
                    .font(.largeTitle)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .clipShape(Capsule())
            }
        }
    }
    ```

    **Because those two text views are identical apart from their text, we can wrap them up in a new custom view**, like this:

    ```swift
    struct CapsuleText: View {
        var text: String

        var body: some View {
            Text(text)
                .font(.largeTitle)
                .padding()
                .foregroundColor(.white)
                .background(Color.blue)
                .clipShape(Capsule())
        }
    }
    ```

    **We can then use that `CapsuleText` view inside our original view**, like this:

    ```swift
    struct ContentView: View {
        var body: some View {
            VStack(spacing: 10) {
                CapsuleText(text: "First")
                CapsuleText(text: "Second")
            }
        }
    }
    ```

    Of course, **we can also store some modifiers in the view and customize others when we use them**. 

    For example, **if we removed `foregroundColor` from `CapsuleText`, we could then apply custom colors when creating instances of that view** like this:

    ```swift
    VStack(spacing: 10) {
        CapsuleText(text: "First")
            .foregroundColor(.white)
        CapsuleText(text: "Second")
            .foregroundColor(.yellow)
    }
    ```

- **Custom modifiers**

    SwiftUI gives us a range of built-in modifiers, such as **`font()`**, **`background()`**, and **`clipShape()`**. 

    However, **it’s also possible to create custom modifiers that do something specific.**

    For example, **we might say that all titles in our app should have a particular style, so first we need to create a custom `ViewModifier` struct that does what we want**:

    ```swift
    struct Title: ViewModifier {
        func body(content: Content) -> some View {
            content
                .font(.largeTitle)
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
    ```

    **We can now use that with the `modifier()` modifier** – yes, it’s a modifier called “modifier”, but it lets us apply any sort of modifier to a view, like this:

    ```swift
    Text("Hello World")
        .modifier(Title())
    ```

    **When working with custom modifiers,** it’s usually a smart idea to **create extensions on `View`** that make them easier to use. 

    For example, **we might wrap the `Title` modifier in an extension** such as this:

    ```swift
    extension View {
        func titleStyle() -> some View {
            self.modifier(Title())
        }
    }
    ```

    **We can now use the modifier like this**:

    ```swift
    Text("Hello World")
        .titleStyle()
    ```

    **Custom modifiers can do much more than just apply other existing modifiers** – **they can also create new view structure**, as needed. 

    Remember, **modifiers return new objects rather than modifying existing ones**, so **we could create one that embeds the view in a stack and adds another view**:

    ```swift
    struct Watermark: ViewModifier {
        var text: String

        func body(content: Content) -> some View {
            ZStack(alignment: .bottomTrailing) {
                content
                Text(text)
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(5)
                    .background(Color.black)
            }
        }
    }

    extension View {
        func watermarked(with text: String) -> some View {
            self.modifier(Watermark(text: text))
        }
    }
    ```

    With that in place, **we can now add a watermark to any view** like this:

    ```swift
    Color.blue
        .frame(width: 300, height: 200)
        .watermarked(with: "Hacking with Swift")
    ```

- **Custom containers**

    Although it’s not something you’re likely to do often, I want to at least show you that **it’s perfectly possible to create custom containers in your SwiftUI apps.** 

    This takes more advanced Swift knowledge because it leverages some of Swift’s power features, so it’s OK to skip this if you find it too much.

    To try it out, **we’re going to make a new type of stack called a `GridStack`, which will let us create any number of views inside a grid**. 

    **What we want to say is that there is a new struct called `GridStack` that conforms to the `View` protocol and has a set number of rows and columns, and that inside the grid will be lots of content cells that themselves must conform to the `View` protocol.**

    In Swift we’d write this:

    ```swift
    struct GridStack<Content: View>: View {
        let rows: Int
        let columns: Int
        let content: (Int, Int) -> Content

        var body: some View {
            // more to come
        }
    }
    ```

    The first line – **`struct GridStack<Content: View>: View`** – **uses** a more advanced feature of Swift called ***generics*,** which in this case **means “you can provide any kind of content you like, but whatever it is it must conform to the `View` protocol.”** 

    **After the colon we repeat `View` again to say that `GridStack` itself also conforms to the `View` protocol.**

    Take particular note of the **`let content`** line – **that defines a closure that must be able to accept two integers and return some sort of content we can show.**

    We need to complete the **`body`** property with something that combines multiple vertical and horizontal stacks to create as many cells as was requested. **We don’t need to say what’s *in* each cell, because we can get that by calling our `content` closure with the appropriate row and column.**

    So, we might fill it in like this:

    ```swift
    var body: some View {
        VStack {
            ForEach(0..<rows, id: \.self) { row inHStack {
                    ForEach(0..<self.columns, id: \.self) { column in
    										self.content(row, column)
                    }
                }
            }
        }
    }
    ```

    **When looping over ranges, SwiftUI can use the range directly only if we know for sure the values in the range won’t change over time.**

     Here we’re using **`ForEach`** with **`0..<rows`** and **`0..<columns`**, **both of which are values that *can* change over time** – we might add more rows, for example. 

    In this situation, we need to add a second parameter to **`ForEach`**, **`id: \.self`**, to tell SwiftUI how it can identify each view in the loop. We’ll go into more detail on this in project 5.

    Now that we have a custom container, we can write a view using it like this:

    ```swift
    struct ContentView: View {
        var body: some View {
            GridStack(rows: 4, columns: 4) { row, col in
    						Text("R\(row) C\(col)")
            }
        }
    }
    ```

    Our **`GridStack`** **is capable of accepting any kind of cell content, as long as it conforms to the `View` protocol**. So, we could give cells a stack of their own if we wanted:

    ```swift
    GridStack(rows: 4, columns: 4) { row, col in
    		HStack {
            Image(systemName: "\(row * 4 + col).circle")
            Text("R\(row) C\(col)")
        }
    }
    ```

    ## **Want to go further?**

    **For more flexibility we could leverage one of SwiftUI’s features called** 

    ***view builders***, which **allows us to send in several views and have it form an implicit stack for us**.

    **To use this, we need to create a custom initializer** for our **`GridStack`** struct, so **we can mark the `content` closure as using SwiftUI’s view builders system**:

    ```swift
    init(rows: Int, columns: Int, @ViewBuilder content: @escaping (Int, Int) -> Content) {
        self.rows = rows
        self.columns = columns
        self.content = content
    }
    ```

    That is mostly just copying the parameters directly into the struct’s properties, but notice the **`@ViewBuilder`** attribute is there. 

    You’ll also see the **`@escaping`** attribute, which allows us to store closures away to be used later on.

    **With that in place SwiftUI will now automatically create an implicit horizontal stack inside our cell closure**:

    ```swift
    GridStack(rows: 4, columns: 4) { row, col in
    		Image(systemName: "\(row * 4 + col).circle")
        Text("R\(row) C\(col)")
    }
    ```

    Both options work, so do whichever you prefer.