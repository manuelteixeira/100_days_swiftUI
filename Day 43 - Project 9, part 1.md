# Day 43 - Project 9, part 1

- **Creating custom paths with SwiftUI**

    **SwiftUI gives us a dedicated `Path` type for drawing custom shapes**.

    It’s very low level, by which I mean you will usually want to wrap it in something else in order for it to be more useful, but as it’s the building block that underlies other work we’ll do we’re going to start there.

    Just like colors, gradients, and shapes, **paths are views in their own right.** This means we can use them just like text views and images, although as you’ll see it’s a bit clumsy.

    Let’s start with a simple shape: drawing a triangle. 

    There are a few ways of creating paths, including one that accepts a closure of drawing instructions. This closure must accept a single parameter, which is the path to draw into. 

    I realize this can be a bit brain-bending at first, because we’re creating a path and inside the initializer for the path we’re getting passed the path to draw into, but think of it like this: **SwiftUI is creating an empty path for us, then giving us the chance to add to it as much as we want.**

    **Paths have lots of methods for creating shapes with squares, circles, arcs, and lines. For our triangle we need to move to a stating position, then add three lines** like this:

    ```swift
    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: 200, y: 100))
            path.addLine(to: CGPoint(x: 100, y: 300))
            path.addLine(to: CGPoint(x: 300, y: 300))
            path.addLine(to: CGPoint(x: 200, y: 100))
        }
    }
    ```

    We haven’t used **`CGPoint`** before, but I did sneak in a quick reference to **`CGSize`** back in project 6. “CG” is short for Core Graphics, which provides a selection of basic types that lets us reference X/Y coordinates (**`CGPoint`**), widths and heights (**`CGSize`**), rectangular frames (**`CGRect`**), and even numbers (**`CGFloat`**).

    When our triangle code runs, you’ll see a large black triangle. ***Where* you see it relative to your screen depends on what simulator you are using, which is part of the problem of these raw paths: we need to use exact coordinates, so if you want to use a path by itself you either need to accept that sizing across all devices or use something like `GeometryReader` to scale them relative to their container.**

    We’ll look at a better option shortly, but first let’s look at coloring our path. One option is to use the **`fill()`** modifier, like this:

    ```swift
    Path { path in
        path.move(to: CGPoint(x: 200, y: 100))
        path.addLine(to: CGPoint(x: 100, y: 300))
        path.addLine(to: CGPoint(x: 300, y: 300))
        path.addLine(to: CGPoint(x: 200, y: 100))
    }
    .fill(Color.blue)
    ```

    **We can also use the `stroke()` modifier to draw around the path rather than filling it in:**

    ```swift
    .stroke(Color.blue, lineWidth: 10)
    ```

    That doesn’t look quite right, though – **the bottom corners of our triangle are nice and sharp, but the top corner is broken.** 

    **This happens because SwiftUI makes sure lines connect up neatly with what comes before and after rather than just being a series of individual lines, but our last line has nothing after it so there’s no way to make a connection.**

    **One way to fix this is just to draw the first line again**, **which means the last line has a connecting line to match up with:**

    ```swift
    Path { path in
        path.move(to: CGPoint(x: 200, y: 100))
        path.addLine(to: CGPoint(x: 100, y: 300))
        path.addLine(to: CGPoint(x: 300, y: 300))
        path.addLine(to: CGPoint(x: 200, y: 100))
        path.addLine(to: CGPoint(x: 100, y: 300))
    }
    .stroke(Color.blue, lineWidth: 10)
    ```

    That works great, as you can see. And it even works great with transparency: if use a transparent stroke color such as **`Color.blue.opacity(0.25)`** then you’ll see the whole stroke gets faded uniformly, without seeing any sort of double stroke along the first line.

    **An alternative is to use SwiftUI’s dedicated `ShapeStyle` struct, which gives us control over how every line should be connected to the line after it (line join) and how every line should be drawn when it ends without a connection after it (line cap)**. 

    This is particularly useful because one of the options for join and cap is **`.round`**, which creates gently rounded shapes:

    ```swift
    .stroke(Color.blue, style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
    ```

    With that in place you can remove the extra line from our path, because it’s no longer needed.

    Using rounded corners solves the problem of our rough edges, but it doesn’t solve the problem of fixed coordinates. For that we need to move on from paths and look at something more complex: *shapes*.

- **Path vs shapes in SwiftUI**

    **SwiftUI enables custom drawing with two subtly different types: paths and shapes.** 

    - A **path** is a **series of drawing instructions** such as “start here, draw a line to here, then add a circle there”, **all using absolute coordinates**.
    - a **shape** **has no idea where it will be used or how big it will be used, but instead will be asked to draw itself inside a given rectangle.**

    Helpfully, **shapes are built using paths**, so once you understand paths shapes are easy. 

    Also, just like paths, colors, and gradients, **shapes are views, which means we can use them alongside text views, images, and so on.**

    **SwiftUI implements `Shape` as a protocol with a single required method: given the following rectangle, what path do you want to draw?** 

    This will still create and return a path just like using a raw path directly, but **because we’re handed the size the shape will be used at we know exactly how big to draw our path – we no longer need to rely on fixed coordinates.**

    For example, previously we created a triangle using a **`Path`**, but we could wrap that in a shape to make sure it automatically takes up all the space available like this:

    ```swift
    struct Triangle: Shape {
        func path(in rect: CGRect) -> Path {
            var path = Path()

            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))

            return path
        }
    }
    ```

    **That job is made much easier by `CGRect`, which provides helpful properties such as** **`minX`** (the smallest X value in the rectangle), **`maxX`** (the largest X value in the rectangle), **and** **`midX`** (the mid-point between **`minX`** and **`maxX`**).

    We could then create a red triangle at a precise size like this:

    ```swift
    Triangle()
        .fill(Color.red)
        .frame(width: 300, height: 300)
    ```

    Shapes also support the same **`StrokeStyle`** parameter for creating more advanced strokes:

    ```swift
    Triangle()
        .stroke(Color.red, style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
        .frame(width: 300, height: 300)
    ```

    **The key to understanding the difference between `Path` and `Shape` is reusability**: 

    **paths are designed to do one specific thing**, whereas **shapes have the flexibility of drawing space and can also accept parameters to let us customize them further.**

    To demonstrate this, we could **create an `Arc` shape that accepts three parameters: start angle, end angle, and whether to draw the arc clockwise or not.** This might seem simple enough, particularly because **`Path`** has an **`addArc()`** method, but as you’ll see it has a couple of interesting quirks.

    Let’s start with the simplest version of an arc shape:

    ```swift
    struct Arc: Shape {
        var startAngle: Angle
        var endAngle: Angle
        var clockwise: Bool

        func path(in rect: CGRect) -> Path {
            var path = Path()
            path.addArc(center: CGPoint(x: rect.midX, y: rect.midY), radius: rect.width / 2, startAngle: startAngle, endAngle: endAngle, clockwise: clockwise)

            return path
        }
    }
    ```

    We can now create an arc like this:

    ```swift
    Arc(startAngle: .degrees(0), endAngle: .degrees(110), clockwise: true)
        .stroke(Color.blue, lineWidth: 10)
        .frame(width: 300, height: 300)
    ```

    If you look at the preview of our arc, chances are it looks nothing like you expect. 

    **We asked for an arc from 0 degrees to 110 degrees with a clockwise rotation, but we appear to have been given an arc from 90 degrees to 200 degrees with a counterclockwise rotation.**

    **What’s happening here is two-fold**:

    1. **In the eyes of SwiftUI 0 degrees is not straight upwards**, **but instead directly to the right.**
    2. **Shapes measure their coordinates from the bottom-left corner** r**ather than the top-left corner**, **which means SwiftUI goes the other way around from one angle to the other**. This is, in my not very humble opinion, extremely alien.

    **We can fix both of those problems with a new `path(in:)` method that subtracts 90 degrees** **from the start and end angles, and also flips the direction** so SwiftUI behaves the way nature intended:

    ```swift
    func path(in rect: CGRect) -> Path {
        let rotationAdjustment = Angle.degrees(90)
        let modifiedStart = startAngle - rotationAdjustment
        let modifiedEnd = endAngle - rotationAdjustment

        var path = Path()
        path.addArc(center: CGPoint(x: rect.midX, y: rect.midY), radius: rect.width / 2, startAngle: modifiedStart, endAngle: modifiedEnd, clockwise: !clockwise)

        return path
    }
    ```

    Run that code and see what you think – to me it produces a much more natural way of working, and neatly isolates SwiftUI’s quirky drawing behavior.

- **Adding strokeBorder() support with InsettableShape**

    **If you create a shape without a specific size, it will automatically expand to occupy all available space**. 

    For example, this will create a circle that fills our view, giving it a 40-point blue border:

    ```swift
    struct ContentView: View {
        var body: some View {
            Circle()
                .stroke(Color.blue, lineWidth: 40)
        }
    }
    ```

    Take a close look at the left and right edges of the border – do you notice how they are cut off?

    What you’re seeing here is a side effect of the way SwiftUI draws borders around shapes. 

    **If you handed someone a pencil outline of a circle and asked them to draw over that circle with a thick pen, they would trace the exact line of the circle – about half the pen would be inside the line, and half outside.** 

    This is what SwiftUI is doing for us, **but where our shapes go to the edge of the screen it means the outside part of the border ends up beyond our screen edges.**

    Now try using this circle instead:

    ```swift
    Circle()
        .strokeBorder(Color.blue, lineWidth: 40)
    ```

    **That changes `stroke()` to `strokeBorder()` and now we get a better result: all our border is visible, because Swift strokes the inside of the circle rather than centering on the line.**

    Previously we built an **`Arc`** shape like this:

    ```swift
    struct Arc: Shape {
        var startAngle: Angle
        var endAngle: Angle
        var clockwise: Bool

        func path(in rect: CGRect) -> Path {
            let rotationAdjustment = Angle.degrees(90)
            let modifiedStart = startAngle - rotationAdjustment
            let modifiedEnd = endAngle - rotationAdjustment

            var path = Path()
            path.addArc(center: CGPoint(x: rect.midX, y: rect.midY), radius: rect.width / 2, startAngle: modifiedStart, endAngle: modifiedEnd, clockwise: !clockwise)

            return path
        }
    }
    ```

    Just like **`Circle`**, that automatically takes up all available space. However, **this kind of code won’t work:**

    ```swift
    Arc(startAngle: .degrees(-90), endAngle: .degrees(90), clockwise: true)
        .strokeBorder(Color.blue, lineWidth: 40)
    ```

    **If you open Xcode’s error message you’ll see it says “Value of type 'Arc' has no member 'strokeBorder’” – that is, the `strokeBorder()` modifier just doesn’t exist on `Arc`.**

    **There is a small but important difference between SwiftUI’s `Circle` and our `Arc`: both conform to the `Shape` protocol, but `Circle` *also* conforms to a second protocol called `InsettableShape`.** 

    **This is a shape that can be inset** – **reduced inwards** – by a certain amount to produce another shape. 

    **The inset shape it produces can be any other kind of insettable shape, but realistically it should be the same shape just in a smaller rectangle.**

    **To make `Arc` conform to `InsettableShape` we need to add one extra method to it: `inset(by:)`.** 

    **This will be given the inset amount (half the line width of our stroke), and should return a new kind of insettable shape** – in our instance that means we should create an inset arc. **The problem is, we don’t *know* the arc’s actual size, because `path(in:)` hasn’t been called yet.**

    It turns out the solution is pretty simple: **if we give our `Arc` shape a new `insetAmount` property that defaults to 0, we can just add to that whenever `inset(by:)` is called. Adding to the inset allows us to call `inset(by:)` multiple times if needed, for example if we wanted to call it once by hand then use `strokeBorder()`.**

    First, add this new property to **`Arc`**:

    ```swift
    var insetAmount: CGFloat = 0
    ```

    Now give it this **`inset(by:)`** method:

    ```swift
    func inset(by amount: CGFloat) -> some InsettableShape {
        var arc = self
        arc.insetAmount += amount
        return arc
    }
    ```

    **The `amount` parameter being passed in should be applied to all edges, which in the case of arcs means we should use it to reduce our draw radius**. So, change the **`addArc()`** call inside **`path(in:)`** to be this:

    ```swift
    path.addArc(center: CGPoint(x: rect.midX, y: rect.midY), radius: rect.width / 2 - insetAmount, startAngle: modifiedStart, endAngle: modifiedEnd, clockwise: !clockwise)
    ```

    **With that change we can now make `Arc` conform to `InsettableShape` like this:**

    ```swift
    struct Arc: InsettableShape {
    ```

    **Note:** **`InsettableShape`** actually builds upon **`Shape`**, so there’s no need to add both there.