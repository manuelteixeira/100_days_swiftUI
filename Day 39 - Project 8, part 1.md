# Day 39 - Project 8, part 1

- **Resizing images to fit the screen using GeometryReader**

    When we create an **`Image`** view in SwiftUI, **it will automatically size itself according to the dimensions of its contents.** 

    So, if the picture is 1000x500, the **`Image`** view will also be 1000x500. This is sometimes what you want, but mostly you’ll want to show the image at a lower size, and I want to show you how that can be done, but also how we can make an image fit the width of the user’s screen using a new view type called **`GeometryReader`**.

    First, add some sort of image to your project. It doesn’t matter what it is, as long as it’s wider than the screen. I called mine “Example”, but obviously you should substitute your image name in the code below.

    Now let’s draw that image on the screen:

    ```swift
    struct ContentView: View {
        var body: some View {
            VStack {
                Image("Example")
            }
        }
    }
    ```

    Even in the preview you can see that’s way too big for the available space. **Images have the same `frame()` modifier as other views, so you might try to scale it down like this:**

    ```swift
    Image("Example")
        .frame(width: 300, height: 300)
    ```

    However, **that won’t work – your image will still appear to be its full size.** 

    If you want to know *why*, take a close look at the preview window: you’ll see your image is full size, but there’s now a blue box that’s 300x300, sat in the middle. 

    **The *image view’s* frame has been set correctly, but the *content* of the image is still shown as its original size.**

    Try changing the image to this:

    ```swift
    Image("Example")
        .frame(width: 300, height: 300)
        .clipped()
    ```

    Now you’ll see things more clearly: our image view is indeed 300x300, but that’s not really what we wanted.

    **If you want the image *contents* to be resized too, we need to use the `resizable()` modifier like this**:

    ```swift
    Image("Example")
        .resizable()
        .frame(width: 300, height: 300)
    ```

    That’s better, but only just. Yes, the image is now being resized correctly, but it’s probably looking squashed. My image was not square, so it looks distorted now that it’s been resized into a square shape.

    **To fix this we need to ask the image to resize itself proportionally, which can be done using the `aspectRatio()` modifier**. 

    This lets us provide an exact aspect ratio and how it should be applied, but if we skip the aspect ratio itself SwiftUI will automatically use the original aspect ratio.

    When it comes to the “how should it be applied” part, SwiftUI calls this the ***content mode* and gives us two option**s:

    - **`.fit`** means the **entire image will fit inside the container even if that means leaving some parts of the view empty,**
    - and **`.fill`** means the **view will have no empty parts even if that means some of our image lies outside the container.**

    Try them both to see the difference for yourself. Here is **`.fit`** mode applied:

    ```swift
    Image("Example")
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: 300, height: 300)
    ```

    And here is **`.fill`** mode applied:

    ```swift
    Image("Example")
        .resizable()
        .aspectRatio(contentMode: .fill)
        .frame(width: 300, height: 300)
    ```

    **All this works great if we want fixed-sized images, but very often you want images that automatically scale up to fill the screen in one or both dimensions**. 

    That is, **rather than hard-coding a width of 300, what you *really* want to say is “make this image fill the width of the screen.”**

    **SwiftUI gives us a dedicated type for this called `GeometryReader`**, and it’s remarkably powerful. Yes, I know lots of SwiftUI is powerful, but honestly: what you can do with **`GeometryReader`** will blow you away.

    We’ll go into much more detail on **`GeometryReader`** in project 15, but for now we’re going to use it for one job: to make sure our image fills the full width of its container view.

    **`GeometryReader`** **is a view just like the others we’ve used, except when we create it we’ll be handed a `GeometryProxy` object to use. This lets us query the environment: how big is the container? What position is our view? Are there any safe area insets? And so on.**

    We can use this geometry proxy to set the width of our image, like this:

    ```swift
    VStack {
        GeometryReader { geo inImage("Example")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: geo.size.width, height: 300)
        }
    }
    ```

    And now the image will fill the width of our screen regardless of what device we use.

    For our final trick, let’s remove the **`height`** from the image, like this:

    ```swift
    VStack {
        GeometryReader { geo inImage("Example")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: geo.size.width)
        }
    }
    ```

    We’ve given SwiftUI enough information that it can automatically figure out the height: it knows the original width, it knows our target width, and it knows our content mode, so it understands how the target height of the image will be proportional to the target width.

- **How ScrollView lets us work with scrolling data**

    You’ve seen how **`List`** and **`Form`** let us create scrolling tables of data, but for times when we want to scroll *arbitrary* date – i.e., just some views we’ve created by hand – we need to turn to SwiftUI’s **`ScrollView`**.

    Scroll views **can scroll horizontally, vertically, or in both directions**, and you can also control whether the system should show scroll indicators next to them 

    – those are the little scroll bars that appear to give users a sense of how big the content is. 

    **When we place views inside scroll views, they automatically figure out the size of that content so users can scroll from one edge to the other.**

    As an example, we could create a scrolling list of 100 text views like this:

    ```swift
    ScrollView(.vertical) {
        VStack(spacing: 10) {
            ForEach(0..<100) {
                Text("Item \($0)")
                    .font(.title)
            }
        }
    }
    ```

    If you run that back in the simulator you’ll see that you can drag the scroll view around freely, and **if you scroll to the bottom you’ll also see that `ScrollView` treats the safe area just like `List` and `Form` – their content goes *under* the home indicator, but they add some extra padding so the final views are fully visible.**

    **You might also notice that it’s a bit annoying having to tap directly in the center** – it’s more common to have the whole area scrollable. To get *that* behavior, **we should make the `VStack` take up more space while leaving the default centre alignment intact**, like this:

    ```swift
    ScrollView(.vertical) {
        VStack(spacing: 10) {
            ForEach(0..<100) {
                Text("Item \($0)")
                    .font(.title)
            }
        }
        .frame(maxWidth: .infinity)
    }
    ```

    Now you can tap and drag anywhere on the screen, which is much more user-friendly.

    This all seems really straightforward, and it’s true that **`ScrollView`** is significantly easier than the older **`UIScrollView`** we had to use with UIKit. However, there’s an important catch that you need to be aware of: 

    **when we add views to a scroll view they get created immediately.**

    To demonstrate this, we can create a simple wrapper around a regular text view, like this:

    ```swift
    struct CustomText: View {
        var text: String

        var body: some View {
            Text(text)
        }

        init(_ text: String) {
            print("Creating a new CustomText")
            self.text = text
        }
    }
    ```

    Now we can use that inside our **`ForEach`**:

    ```swift
    ForEach(0..<100) {
        CustomText("Item \($0)")
            .font(.title)
    }
    ```

    The result will look identical, but now when you run the app you’ll see “Creating a new CustomText” printed a hundred times in Xcode’s log – **SwiftUI won’t wait until you scroll down to see them, it will just create them immediately.**

    You can try the same experiment with a **`List`**, like this:

    ```swift
    List {
        ForEach(0..<100) {
            CustomText("Item \($0)")
                .font(.title)
        }
    }
    ```

    When *that* code runs you’ll see it acts lazily: it creates instances of **`CustomText`** only when really needed.

- **Pushing new views onto the stack using NavigationLink**

    SwiftUI’s **`NavigationView`** shows a navigation bar at the top of our views, but also does something else: **it lets us push views onto a view stack**. 

    In fact, this is really the most fundamental form of iOS navigation – you can see it in Settings when you tap Wi-Fi or General, or in Messages whenever you tap someone’s name.

    **This view stack system is very different from the sheets we’ve used previously**. Yes, **both show some sort of new view**, but there’s a **difference in the *way* they are presented that affects the way users think about them.**

    Let’s start by looking at some code so you can see for yourself. If we wrap the default text view with a navigation view and give it a title, we get this:

    ```swift
    struct ContentView: View {
        var body: some View {
            NavigationView {
                VStack {
                    Text("Hello World")
                }
                .navigationBarTitle("SwiftUI")
            }
        }
    }
    ```

    That text view is just static text; it’s not a button with any sort of action attached to it. We’re going to make it so that when the user taps on “Hello World” we present them with a new view, and that’s done using **`NavigationLink`**: **give this a destination and something that can be tapped, and it will take care of the rest.**

    One of the many things I love about SwiftUI is that we can use **`NavigationLink`** with any kind of destination view. **Yes, we can design a custom view to push to, but we can also push straight to some text.**

    To try this out, change your view to this:

    ```swift
    NavigationView {
        VStack {
            NavigationLink(destination: Text("Detail View")) {
                Text("Hello World")
            }
        }
        .navigationBarTitle("SwiftUI")
    }
    ```

    Now run the code and see what you think. **You will see that “Hello World” now looks like a button, and tapping it makes a new view slide in from the right saying “Detail View”.** 

    Even better, **you’ll see that the “SwiftUI” title animates down to become a back button, and you can tap that or swipe from the left edge to go back.**

    So, **both `sheet()` and `NavigationLink` allow us to show a new view from the current one**, **but the *way* they do it is differen**t and you should choose them carefully:

    - **`NavigationLink`** is for s**howing details about the user’s selection**, like you’re digging deeper into a topic.
    - **`sheet()`** is for **showing unrelated content**, such as settings or a compose window.

    **The most common place you see `NavigationLink` is with a list**, and there SwiftUI does something quite marvelous.

    Try modifying your code to this:

    ```swift
    NavigationView {
        List(0..<100) { row inNavigationLink(destination: Text("Detail \(row)")) {
                Text("Row \(row)")
            }
        }
        .navigationBarTitle("SwiftUI")
    }
    ```

    **When you run the app now you’ll see 100 list rows that can be tapped to show a detail view, but you’ll also see gray disclosure indicators on the right edge**. 

    **This is the standard iOS way of telling users another screen is going to slide in from the right when the row is tapped**, and SwiftUI is smart enough to add it automatically here. 

    If those rows weren’t navigation links – if you comment out the **`NavigationLink`** line and its closing brace – you’ll see the indicators disappear.

- **Working with hierarchical Codable data**

    The **`Codable`** protocol makes it trivial to decode flat data: if you’re decoding a single instance of a type, or an array or dictionary of those instances, then things Just Work. However, in this project we’re going to be decoding slightly more complex JSON: there will be an array inside another array, using different data types.

    **If you want to decode this kind of hierarchical data, the key is to create separate types for each level you have**. 

    **As long as the data matches the hierarchy you’ve asked for, `Codable` is capable of decoding everything with no further work from us.**

    To demonstrate this, put this button in to your content view:

    ```swift
    Button("Decode JSON") {
        let input = """
        {
            "name": "Taylor Swift",
            "address": {
                "street": "555, Taylor Swift Avenue",
                "city": "Nashville"
            }
        }
        """

        // more code to come
    }
    ```

    That creates a string of JSON in code. In case you aren’t too familiar with JSON, it’s probably best to look at the Swift structs that match it – you can put these directly into the button action or outside of the **`ContentView`** struct, it doesn’t matter:

    ```swift
    struct User: Codable {
        var name: String
        var address: Address
    }

    struct Address: Codable {
        var street: String
        var city: String
    }
    ```

    Hopefully you can now see what the JSON contains: a user has a name string and an address, and addresses are a street string and a city string.

    Now for the best part: **we can convert our JSON string to the `Data` type** (which is what **`Codable`** works with), t**hen decode that into a `User` instance:**

    ```swift
    let data = Data(input.utf8)
    let decoder = JSONDecoder()
    if let user = try? decoder.decode(User.self, from: data) {
        print(user.address.street)
    }
    ```

    If you run that program and tap the button you should see the address printed out – although just for the avoidance of doubt I should say that it’s not her actual address!

    There’s no limit to the number of levels **`Codable`** will go through – **all that matters is that the structs you define match your JSON string.**

    That brings us to the end of the overview for this project, so please go ahead and reset ContentView.swift to its original state.