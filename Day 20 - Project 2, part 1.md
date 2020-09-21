# Day 20 - Project 2, part 1

- **Using stacks to arrange views**

    When we return **`some View`** for our body, w**e mean “one specific type that conforms to the `View` protocol**. 

    That might be a navigation view, a form, a text view, a picker, or something else entirely, **but it’s always exactly one thing that conforms to the `View` protocol.**

    **If we want to return *multiple* things we have various options, but three are particularly useful**. 

    **They are `HStack`, `VStack`, and `ZStack`, which handle horizontal, vertical, and, er, zepth.**

    Let’s try it out now. Our default template looks like this:

    ```swift
    var body: some View {
        Text("Hello World")
    }
    ```

    **That returns precisely one kind of view, which is a text view.** 

    If we wanted to return two text views, this kind of code simply isn’t allowed:

    ```swift
    var body: some View {
        Text("Hello World")
        Text("This is another text view")
    }
    ```

    Instead, **we need to make sure SwiftUI gets exactly one kind of view back, and that’s where stacks come in: they allow us to say “here are two text views, and I want them to be positioned like this…”**

    So, for **`VStack`** – a **vertical stack** of views – **the two text views would be placed one above the other, like this:**

    ```swift
    var body: some View {
        VStack {
            Text("Hello World")
            Text("This is inside a stack")
        }
    }
    ```

    **By default `VStack` places little or no spacing between the two views**, but **we can control the spacing by providing a parameter** when we create the stack, like this:

    ```swift
    VStack(spacing: 20) {
        Text("Hello World")
        Text("This is inside a stack")
    }
    ```

    Just like SwiftUI’s other views, **`VStack`** **can have a maximum of 10 children** – **if you want to add more, you should wrap them inside a `Group`.**

    **By default, `VStack` aligns its views so they are centered,** but **you can control that with its `alignment` property**. 

    For example, this aligns the text views to their leading edge, which in a left-to-right language such as English will cause them to be aligned to the left:

    ```swift
    VStack(alignment: .leading) {
        Text("Hello World")
        Text("This is inside a stack")
    }
    ```

    Alongside **`VStack`** we have **`HStack`** **for arranging things horizontally**. This has the same syntax as **`VStack`**, including the ability to add spacing and alignment:

    ```swift
    HStack(spacing: 20) {
        Text("Hello World")
        Text("This is inside a stack")
    }
    ```

    **Vertical and horizontal stacks automatically fit their content, and prefer to align themselves to the center of the available space**. 

    **If you want to change that you can use one or more `Spacer` views to push the contents of your stack to one side.** 

    **These automatically take up all remaining space**, so if you add one at the end a **`VStack`** it will push all your views to the top of the screen:

    ```swift
    VStack {
        Text("First")
        Text("Second")
        Text("Third")
        Spacer()
    }
    ```

    **If you add more than one spacer they will divide the available space between them.**

    We also have **`ZStack`** **for arranging things by depth** – **it makes views that overlap**. ****

    **In the case of our two text views, this will make things rather hard to read**:

    ```swift
    ZStack {
        Text("Hello World")
        Text("This is inside a stack")
    }
    ```

    **`ZStack`** **doesn’t have the concept of spacing because the views overlap, but it *does* have alignment.** 

    **So, if you have one large thing and one small thing inside your `ZStack`, you can make both views align to the top like this: `ZStack(alignment: .top) {`.**

    **`ZStack`** **draws its contents from top to bottom, back to front.** 

    This means **if you have an image then some text `ZStack` will draw them in that order, placing the text on top of the image.**

- **Colors and frames**

    SwiftUI gives us a range of functionality to render colors, and manages to be both simple and powerful – a difficult combination, but one they really pulled off.

    To try this out, let’s create a **`ZStack`** with a single text label:

    ```swift
    ZStack {
        Text("Your content")
    }
    ```

    If we want to put something behind the text, we need to place it above it in the **`ZStack`**. But **what if we wanted to put some red behind there – how would we do that?**

    **One option is to use the `background()` modifier, which can be given a color to draw like this**:

    ```swift
    ZStack {
        Text("Your content")
    }
    .background(Color.red)
    ```

    **That *might* have done what you expected, but there’s a good chance it was a surprise: only the text view had a background color, even though we’ve asked the whole `ZStack` to have it.**

    In fact, **there’s no difference between that code and this**:

    ```swift
    ZStack {
        Text("Your content")
            .background(Color.red)
    }
    ```

    **If you want to fill in red the whole area behind the text, you should place the color into the** **`ZStack`** – **treat it as a whole view**, all by itself:

    ```swift
    ZStack {
        Color.red
        Text("Your content")
    }
    ```

    In fact, **`Color.red`** ***is* a view in its own right, which is why it can be used like shapes and text.** 

    **It automatically takes up all the space available, but you can also use the `frame()` modifier to ask for specific sizes**:

    ```swift
    Color.red.frame(width: 200, height: 200)
    ```

    **SwiftUI gives us a number of built-in colors to work with, such as `Color.blue`, `Color.green`, and more**. 

    **We also have some *semantic* colors: colors that don’t say what hue they contain, but instead describe their purpose.**

    For example, **`Color.primary`** **is the default color of text in SwiftUI, and will be either black or white depending on whether the user’s device is running in light mode or dark mode.** 

    There’s also **`Color.secondary`**, which is also black or white depending on the device, but now has slight transparency so that a little of the color behind it shines through.

    **If you need something specific, you can create custom colors by passing in values between 0 and 1 for red, green, and blue**, like this:

    ```swift
    Color(red: 1, green: 0.8, blue: 0)
    ```

    **Even when taking up the full screen, you’ll see that using `Color.red` will leave some space white.**

    **How much space is white depends on your device, but on iPhone X designs – iPhone X, XS, and 11 – you’ll find that both the status bar (the clock area at the top) and the home indicator (the horizontal stripe at the bottom) are left uncolored.**

    **This space is left intentionally blank, because Apple doesn’t want important content to get obscured by other UI features or by any rounded corners on your device.** 

    So, **the remaining part – that whole middle space – is called *the safe area***, and you can draw into it freely without worrying that it might be clipped by the notch on an iPhone.

    **If you *want* your content to go under the safe area, you can use the `edgesIgnoringSafeArea()` modifier to specify which screen edges you want to run up to**. 

    For example, this creates a **`ZStack`** which fills the screen edge to edge with red then draws some text on top:

    ```swift
    ZStack {
        Color.red.edgesIgnoringSafeArea(.all)
        Text("Your content")
    }
    ```

    **It is *critically important* that no important content be placed outside the safe area, because it might be hard if not impossible for the user to see.** 

    **Some views, such as `List`, allow content to scroll outside the safe area but then add extra insets so the user can scroll things into view**.

    **If your content is just decorative – like our background color here – then extending it outside the safe area is OK.**

- **Gradients**

    **SwiftUI gives us three kinds of gradients to work with, and like colors they are also views that can be drawn in our UI.**

    **Gradients are made up of several components**:

    - **An array of colors to show**
    - **Size and direction information**
    - **The type of gradient to use**

    For example, a l**inear gradient goes in one direction, so we provide it with a start and end point like this:**

    ```swift
    LinearGradient(
    	gradient: Gradient(colors: [.white, .black]), 
    	startPoint: .top, 
    	endPoint: .bottom
    )
    ```

    The inner **`Gradient`** type used there can also be provided with gradient stops, **which let you specify both a color and how far along the gradient the color should be used.**

    In contrast, **radial gradients move outward in a circle shape, so instead of specifying a direction we specify a start and end radius** – **how far from the center of the circle the color should start and stop changing**. For example:

    ```swift
    RadialGradient(
    	gradient: Gradient(colors: [.blue, .black]), 
    	center: .center, 
    	startRadius: 20, 
    	endRadius: 200
    )
    ```

    The last gradient type is called an **angular gradient**, although you might have heard it referred to elsewhere as a conic or conical gradient. T**his cycles colors around a circle rather than radiating outward, and can create some beautiful effects.**

    For example, **this cycles through a range of colors in a single gradient, centered on the middle of the gradient**:

    ```swift
    AngularGradient(
    	gradient: Gradient(colors: [.red, .yellow, .green, .blue, .purple, .red]), 
    	center: .center
    )
    ```

    **All of these gradients are able to stand alone as views, or be used as part of a modifier** – **you can use them as the background for a text view, for example.**

- **Buttons and images**

    **Buttons in SwiftUI can be made in two ways depending on how they should look.**

    The **simplest way to make a button is when it just contains some text**: **you pass in the title of the button**, **along with a closure that should be run when the button is tapped**:

    ```swift
    Button("Tap me!") {
        print("Button was tapped")
    }
    ```

    **If you want something more, such as an image or a combination of views, you can use this alternative form**

    ```swift
    Button(action: {
        print("Button was tapped")
    }) { 
        Text("Tap me!")
    }
    ```

    This is particularly **common when you want to incorporate images into your buttons.**

    **SwiftUI has a dedicated `Image` type for handling pictures in your apps**, and **there are three main ways you will create them**:

    - **`Image("pencil")`** **will load an image called “Pencil” that you have added to your project.**
    - **`Image(decorative: "pencil")`** **will load the same image, but won’t read it out for users who have enabled the screen reader**. **This is useful for images that don’t convey additional important information**.
    - **`Image(systemName: "pencil")`** **will load the pencil icon that is built into iOS**. **This uses Apple’s SF Symbols icon collection**, and you can search for icons you like – download Apple’s free SF Symbols app from the web to see the full set.

    **By default the screen reader will read your image name if it is enabled, so make sure you give your images clear names if you want to avoid confusing the user**. 

    Or, **if they don’t actually add information that isn’t already elsewhere on the screen, use the `Image(decorative:)` initializer**.

    Because **the longer form of buttons can have any kind of views inside them, you can use images like this:**

    ```swift
    Button(action: {
        print("Edit button was tapped")
    }) { 
        Image(systemName: "pencil")
    }
    ```

    **And of course you can combine these with stacks to make more advanced button layouts**:

    ```swift
    Button(action: {
        print("Edit button was tapped")
    }) {
        HStack(spacing: 10) { 
            Image(systemName: "pencil")
            Text("Edit")
        }
    }
    ```

    **If you find that your images have become filled in with a color, for example showing as solid blue rather than your actual picture, this is probably SwiftUI coloring them to show that they are tappable**. **To fix the problem, use the `renderingMode(.original)` modifier to force SwiftUI to show the original image rather than the recolored version.**

- **Showing alert messages**

    If something important happens, a common way of notifying the user is using an **alert – a pop up window that contains a title, message, and one or two buttons depending on what you need.**

    But think about it: *when* should an alert be shown and *how*? Views are a function of our program state, and alerts aren’t an exception to that. So, **rather than saying “show the alert”, we instead create our alert and set the conditions under which it should be shown.**

    **A basic SwiftUI alert has a title, message, and one dismiss button, like this:**

    ```swift
    Alert(title: Text("Hello SwiftUI!"), message: Text("This is some detail message"), dismissButton: .default(Text("OK")))
    ```

    You can add more code to configure the buttons in more detail if you want, but that’s enough for now. 

    More interesting is how we present that alert: **we don’t assign the alert to a variable then write something like `myAlert.show()`, because that would be back the old “series of events” way of thinking.**

    Instead, w**e create some state that tracks whether our alert is showing, like this:**

    ```swift
    @State private var showingAlert = false
    ```

    **We then attach our alert somewhere to our user interface, telling it to use that state to determine whether the alert is presented or not. SwiftUI will watch `showingAlert`, and as soon as it becomes true it will show the alert.**

    Putting that all together, **here’s some example code that shows an alert when a button is tapped:**

    ```swift
    struct ContentView: View {
        @State private var showingAlert = false

        var body: some View {
            Button("Show Alert") {
                self.showingAlert = true
            }
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Hello SwiftUI!"), message: Text("This is some detail message"), dismissButton: .default(Text("OK")))
            }
        }
    }
    ```

    That attaches the alert to the button, but honestly it doesn’t matter where the **`alert()`** modifier is used – all we’re doing is saying that an alert exists and is shown when **`showingAlert`** is true.

    Take a close look at the **`alert()`** modifier:

    ```swift
    .alert(isPresented: $showingAlert)
    ```

    **That’s another two-way data binding, and it’s here because SwiftUI will automatically set `showingAlert` back to false when the alert is dismissed.**