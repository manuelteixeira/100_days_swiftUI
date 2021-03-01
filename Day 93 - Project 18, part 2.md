# Day 93 - Project 18, part 2

- **Absolute positioning for SwiftUI views**

    **SwiftUI gives us two ways of positioning views**: 

    - **absolute positions** using **`position()`**,
    - and **relative positions** using **`offset()`**.

    They might seem similar, but once you understand how SwiftUI places views inside frames the underlying differences between **`position()`** and **`offset()`** become clearer.

    The default SwiftUI template looks like this:

    ```swift
    struct ContentView: View {
        var body: some View {
            Text("Hello, world!")
        }
    }
    ```

    **SwiftUI offers the full available space to `ContentView`, which in turn passes it on to the text view**. 

    **The text view automatically uses only as much as space as its text needs, so it passes that back up to `ContentView`, which is always and exactly the same size as its `body`** (so it directly fits around the text). 

    **As a result, SwiftUI centers `ContentView` in the available space**, which from a user’s perspective is what places the text in the center.

    **If you want to absolutely position a SwiftUI view you should use the** **`position()`** modifier like this:

    ```swift
    Text("Hello, world!")
        .position(x: 100, y: 100)
    ```

    **That will position the text view at x:100 y:100 within its parent**. 

    Now, to *really* see what’s happening here I want you to add a background color:

    ```swift
    Text("Hello, world!")
        .background(Color.red)
        .position(x: 100, y: 100)
    ```

    **You’ll see the text has a red background tightly fitted around it**. 

    Now try moving the **`background()`** modifier below the **`position()`** modifier, like this:

    ```swift
    Text("Hello, world!")
        .position(x: 100, y: 100)    
        .background(Color.red)
    ```

    **Now you’ll see the text is in the same location, but the whole safe area is colored red**.

    To understand what’s happening here you need to **remember the three step layout process of SwiftUI**:

    1. **A parent view proposes a size for its child.**
    2. Based on that information, **the child then chooses its own size and the parent *must* respect that choice.**
    3. **The parent then positions the child in its coordinate space.**

    So, **the parent is responsible for positioning the child, not the child**. 

    This causes a problem, because **we’ve just told our text view to be at an exact position – how can SwiftUI resolve this?**

    The answer to this is also why our **`background()`** color made the whole safe area red: **when we use `position()` we get back a new view that takes up all available space, so it can position its child (the text) at the correct location.**

    **When we use text, position, then background** 

    **the position will take up all available space so it can position its text correctly, then the background will use that size for itself**. 

    **When we use text, background, then position**,

    **the background will use the text size for its size, then the position will take up all available space and place the background in the correct location**.

    When discussing the **`offset()`** modifier earlier, I said “**if you offset some text its original dimensions don’t actually change, even though the resulting view is rendered in a different location**.” With that in mind, try running this code:

    ```swift
    var body: some View {
        Text("Hello, world!")
            .offset(x: 100, y: 100)
            .background(Color.red)
    }
    ```

    You’ll see **the text appears in one place and the background in another.** 

    I’m going to explain why that is, but first I want you to think about it yourself because if you understand *that* then you really understand how SwiftUI’s layout system works.

    **When we use the `offset()` modifier, we’re changing the location where a view should be rendered without actually changing its underlying geometry**. 

    This means **when we apply `background()` afterwards it uses the original position of the text, *not* its offset.** 

    **If you move the modifier order so that `background()` comes before `offset()` then things work more like you might have expected, showing once again that modifier order matters.**

- **Understanding frames and coordinates inside GeometryReader**

    SwiftUI’s **`GeometryReader`** **allows us to determine the size and coordinates of views as a function of its own size and coordinates**, and it’s the key to creating some of the most remarkable effects in SwiftUI.

    You should always keep in mind SwiftUI’s three-step layout system when working with **`GeometryReader`**: parent proposes a size for the child, the child uses that to determine its own size, and parent uses that to position the child appropriately.

    In its most basic usage, what **`GeometryReader`** **does is let us read the size that was proposed by the parent, then use that to manipulate our view.** 

    For example, **we could use `GeometryReader` to make a text view have 90% of all available space regardless of its content**:

    ```swift
    struct ContentView: View {
        var body: some View {
            GeometryReader { geo inText("Hello, World!")
                    .frame(width: geo.size.width * 0.9)
                    .background(Color.red)
            }
        }
    }
    ```

    **That `geo` parameter that comes in is a `GeometryProxy`, and it contains the proposed size, any safe area insets that have been applied, plus a method for reading frame values** that we’ll look at in a moment.

    **`GeometryReader`** has an interesting side effect that might catch you out at first: **the view that gets returned has a flexible preferred size, which means it will expand to take up more space as needed**. You can see this in action if you place the **`GeometryReader`** into a **`VStack`** then put some more text below it, like this:

    ```swift
    struct ContentView: View {
        var body: some View {
            VStack {
                GeometryReader { geo inText("Hello, World!")
                        .frame(width: geo.size.width * 0.9, height: 40)
                        .background(Color.red)
                }

                Text("More text")
                    .background(Color.blue)
            }
        }
    }
    ```

    **You’ll see “More text” gets pushed right to the bottom of the screen, because the `GeometryReader` takes up all remaining space.** 

    To see it in action, add **`background(Color.green)`** as a modifier to the **`GeometryReader`** and you’ll see just how big it is. 

    Note: **This is a *preferred* size, not an *absolute* size, which means it’s still flexible depending on its parent.**

    **When it comes to reading the frame of a view, `GeometryProxy` provides a `frame(in:)` method** rather than simple properties. 

    This is because **the concept of a “frame” includes X and Y coordinates, which don’t make any sense in isolation – do you want the view’s absolute X and Y coordinates, or their X and Y coordinates compared to their parent?**

    **SwiftUI calls these options *coordinate spaces***, 

    and **those two in particular are called the** 

    - **global space (measuring our view’s frame relative to the whole screen),**
    - **and the local space (measuring our view’s frame relative to its parent)**.

    **We can also create custom coordinate spaces by attaching the `coordinateSpace()` modifier to a view – any children of that can then read its frame relative to that coordinate space**.

    To demonstrate how coordinate spaces work, we could create some example views in various stacks, attach a custom coordinate space to the outermost view, then add an **`onTapGesture`** to one of the views inside it so it can print out the frame globally, locally, and using the custom coordinate space.

    Try this code:

    ```swift
    struct OuterView: View {
        var body: some View {
            VStack {
                Text("Top")
                InnerView()
                    .background(Color.green)
                Text("Bottom")
            }
        }
    }

    struct InnerView: View {
        var body: some View {
            HStack {
                Text("Left")
                GeometryReader { geo in
    								Text("Center")
                        .background(Color.blue)
                        .onTapGesture {
                            print("Global center: \(geo.frame(in: .global).midX) x \(geo.frame(in: .global).midY)")
                            print("Custom center: \(geo.frame(in: .named("Custom")).midX) x \(geo.frame(in: .named("Custom")).midY)")
                            print("Local center: \(geo.frame(in: .local).midX) x \(geo.frame(in: .local).midY)")
                        }
                }
                .background(Color.orange)
                Text("Right")
            }
        }
    }

    struct ContentView: View {
        var body: some View {
            OuterView()
                .background(Color.red)
                .coordinateSpace(name: "Custom")
        }
    }
    ```

    **The output you get when that code runs depends on the device you’re using, but here’s what I got:**

    - **Global center: 202.0 x 455.16666666666663**
    - **Custom center: 202.0 x 411.16666666666663**
    - **Local center: 164.0 x 378.5**

    Those sizes are mostly different, so hopefully you can see the full range of how these frame work:

    - **A global center X of 202 means that the center of the text view is 202 points from the left edge of the screen. This isn’t dead in the center of the screen because the “Left” and “Right” labels have different sizes.**
    - **A global center Y of 455.167 means the center of the text view is 455.167 points from the top edge of the screen. This isn’t dead in the center of the screen because there is more safe area at the top than the bottom.**
    - A custom center X of 202 **means the center of the text view is 202 points from the left edge of whichever view owns the “Custom” coordinate space, which in our case is `OuterView` because we attach it in `ContentView`. This number matches the global position because `OuterView` runs edge to edge horizontally.**
    - A custom center Y of 411.167 **means the center of the text view is 411.167 points from the top edge of `OuterView`. This value is smaller than the global center Y because `OuterView` doesn’t extend into the safe area.**
    - **A local center X of 164 means the center of the text view is 164 points from the left edge of its direct container, which in this case is the `GeometryReader`.**
    - **A local center Y of 378.5 means the center of the text view is 378.6 points from the top edge of its direct container, which again is the `GeometryReader`.**

    Which coordinate space you want to use depends on what question you want to answer:

    - Want to know **where this view is on the screen**? Use the **global space.**
    - Want to know **where this view is relative to its parent**? Use the **local space**.
    - What to know **where this view is relative to some other view**? Use a **custom space**.

- **ScrollView effects using GeometryReader**

    **When we use the `frame(in:)` method of a `GeometryReader`, SwiftUI will calculate the view’s current position in the coordinate space we ask for**. 

    However, **as the view *moves* those values will change, and SwiftUI will automatically make sure `GeometryReader` stays updated**.

    **Previously we used `DragGesture` to store a width and height as an `@State` property, because it allowed us to adjust other properties based on the drag amount to create neat effects.** 

    However, **with `GeometryReader` we can grab values from a view’s environment dynamically, feeding in its absolute or relative position into various modifiers**. 

    Even better, **you can nest geometry readers so that one can read the geometry for a higher-up view and the other can read the geometry for something further down the tree**.

    To demonstrate this, **we could create a spinning helix effect by creating 50 text views in a vertical scroll view, each of which use the full width of the top-most view then apply a 3D rotation effect based on their own position.**

    Start by making a basic **`ScrollView`** of text views with varying background colors:

    ```swift
    struct ContentView: View {
        let colors: [Color] = [.red, .green, .blue, .orange, .pink, .purple, .yellow]

        var body: some View {
            GeometryReader { fullView inScrollView(.vertical) {
                    ForEach(0..<50) { index in
    										GeometryReader { geo in
    												Text("Row #\(index)")
                                .font(.title)
                                .frame(width: fullView.size.width)
                                .background(self.colors[index % 7])
                        }
                        .frame(height: 40)
                    }
                }
            }
        }
    }
    ```

    To **apply a helix-style spinning effect**, place this **`rotation3DEffect()`** directly below the **`background()`** modifier:

    ```swift
    .rotation3DEffect(
    		.degrees(Double(geo.frame(in: .global).minY) / 5), 
    		axis: (x: 0, y: 1, z: 0)
    )
    ```

    When you run that back **you’ll see that text views at the bottom of the screen are flipped, those at the center are rotated about 90 degrees, and those at the very top are normal.** 

    More importantly, **as you scroll around they all rotate as you move in the scroll view.**

    That’s a neat effect, but **it’s also problematic because the views only reach their natural orientation when they are at the very top – it’s really hard to read**. To fix this, we can apply a more complex **`rotation3DEffect()`** that **subtracts half the height of the main view**:

    ```swift
    .rotation3DEffect(
    		.degrees(
    				Double(geo.frame(in: .global).minY - fullView.size.height / 2) 
    				/ 5
    		), 
    		axis: (x: 0, y: 1, z: 0)
    )
    ```

    With that in place, the views will reach a natural orientation nearer the center of the screen, which will look much better.

    We can use a similar technique to create CoverFlow-style scrolling rectangles, this time adding a little padding so the views sit naturally in the center at the beginning and end:

    ```swift
    struct ContentView: View {
        let colors: [Color] = [.red, .green, .blue, .orange, .pink, .purple, .yellow]

        var body: some View {
            GeometryReader { fullView in
    						ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(0..<50) { index in
    												GeometryReader { geo in
    														Rectangle()
                                    .fill(self.colors[index % 7])
                                    .frame(height: 150)
                                    .rotation3DEffect(
    																		.degrees(-Double(geo.frame(in: .global).midX - fullView.size.width / 2) / 10), 
    																		axis: (x: 0, y: 1, z: 0)
    																)
                            }
                            .frame(width: 150)
                        }
                    }
                    .padding(.horizontal, (fullView.size.width - 150) / 2)
                }
            }
            .edgesIgnoringSafeArea(.all)
        }
    }
    ```

    There are so many interesting and creative ways to make special effects with **`GeometryReader`** – I hope you can take the time to experiment!