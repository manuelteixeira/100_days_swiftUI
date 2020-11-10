# Day 44 - Project 9, part 2

- **Transforming shapes using CGAffineTransform and even-odd fills**

    When you move beyond simple shapes and paths, two useful features of SwiftUI come together to create some beautiful effects with remarkably little work. 

    The first is **`CGAffineTransform`**, which **describes how a path or view should be rotated, scaled, or sheared**; 

    and the second is **even-odd fills, which allow us to control how overlapping shapes should be rendered.**

    To demonstrate both of these, **we’re going to create a flower shape out of several rotated ellipse petals, with each ellipse positioned around a circle.** 

    The mathematics behind this is relatively straightforward, with one catch: **`CGAffineTransform`** **measures angles in radians rather than degrees.** 

    If it’s been a while since you were at school, the least you need to know is this: **3.141 radians is equal to 180 degrees**, **so 3.141 radians multiplied by 2 is equal to 360 degrees.** And the 3.141 isn’t a coincidence: the actual value is the mathematical constant pi.

    So, **what we’re going to do is as follows:**

    - **Create a new empty path.**
    - **Count from 0 up to pi multiplied by 2** (**360 degrees** in radians), **counting in one eighth of pi each time** – this **will give us 16 petals.**
    - **Create a rotation transform equal to the current number.**
    - **Add to that rotation a movement equal to half the width and height of our draw space**, **so each petal is centered in our shape.**
    - **Create a *new* path for a petal, equal to an ellipse of a specific size.**
    - **Apply our transform to that ellipse so it’s moved into position.**
    - **Add that petal’s path to our main path.**

    This will make more sense once you see the code running, but first I want to add three more small things:

    1. **Rotating something then moving it does not produce the same result as moving then rotating**, because when you rotate it first the direction it moves will be different from if it were not rotated.
    2. **To really help you understand what’s going on, we’ll be making our petal ellipses use a couple of properties we can pass in externally.**
    3. **Ranges such as `1...5` are great if you want to count through numbers one a time, but if you want to count in 2s, or in our case count in “pi/8”s, you should use `stride(from:to:by:)` instead.**

    Alright, enough talk – add this shape to your project now:

    ```swift
    struct Flower: Shape {
        // How much to move this petal away from the center
        var petalOffset: Double = -20

        // How wide to make each petal
        var petalWidth: Double = 100

        func path(in rect: CGRect) -> Path {
            // The path that will hold all petals
            var path = Path()

            // Count from 0 up to pi * 2, moving up pi / 8 each time
            for number in stride(from: 0, to: CGFloat.pi * 2, by: CGFloat.pi / 8) {
                // rotate the petal by the current value of our loop
                let rotation = CGAffineTransform(rotationAngle: number)

                // move the petal to be at the center of our view 
                let position = rotation.concatenating(CGAffineTransform(translationX: rect.width / 2, y: rect.height / 2))

                // create a path for this petal using our properties plus a fixed Y and height
                let originalPetal = Path(ellipseIn: CGRect(x: CGFloat(petalOffset), y: 0, width: CGFloat(petalWidth), height: rect.width / 2))

                // apply our rotation/position transformation to the petal
                let rotatedPetal = originalPetal.applying(position)

                // add it to our main path
                path.addPath(rotatedPetal)
            }

            // now send the main path back
            return path
        }
    }
    ```

    I realize that’s quite a lot of code, but hopefully it will become clearer when you try it out. Modify your **`ContentView`** to this:

    ```swift
    struct ContentView: View {
        @State private var petalOffset = -20.0
        @State private var petalWidth = 100.0

        var body: some View {
            VStack {
                Flower(petalOffset: petalOffset, petalWidth: petalWidth)
                    .stroke(Color.red, lineWidth: 1)

                Text("Offset")
                Slider(value: $petalOffset, in: -40...40)
                    .padding([.horizontal, .bottom])

                Text("Width")
                Slider(value: $petalWidth, in: 0...100)
                    .padding(.horizontal)
            }
        }
    }
    ```

    Now try that out. You should be able to see exactly how the code works once you start dragging the offset and width sliders around – it’s just a series of rotated ellipses, placed in a circular formation.

    That in itself is interesting, but with one small change we can go from *interesting* to *sublime*. **If you look at the way our ellipses are being drawn, they overlap frequently – sometimes one ellipse is drawn over another, and sometimes over several others.**

    **If we fill our path using a solid color, we get a fairly unimpressive result.** Try it like this:

    ```swift
    Flower(petalOffset: petalOffset, petalWidth: petalWidth)
        .fill(Color.red)
    ```

    But **as an alternative, we can fill the shape using the even-odd rule, which decides whether part of a path should be colored depending on the overlaps it contains**. It works like this:

    - **If a path has no overlaps it will be filled.**
    - **If another path overlaps it, the overlapping part won’t be filled**.
    - **If a third path overlaps the previous two, then it *will* be filled.**
    - …and so on.

    **Only the parts that actually overlap are affected by this rule**, and it creates some remarkably beautiful results. Even better, Swift UI makes it trivial to use, because whenever we call **`fill()`** on a shape we can pass a **`FillStyle`** struct that asks for the even-odd rule to be enabled.

    Try it out with this:

    ```swift
    Flower(petalOffset: petalOffset, petalWidth: petalWidth)
        .fill(Color.red, style: FillStyle(eoFill: true))
    ```

    Now run the program and play – honestly, given how little work we’ve done the results are quite entrancing!

- **Creative borders and fills using imagePaint**

    SwiftUI relies heavily on protocols, which can be a bit confusing when working with drawing. For example, **we can use `Color` as a view, but it also conforms to `ShapeStyle`** – a different protocol used for fills, strokes, and borders.

    In practice, **this means we can modify the default text view so that it has a red background**:

    ```swift
    Text("Hello World")
        .frame(width: 300, height: 300)
        .background(Color.red)
    ```

    **Or a red border:**

    ```swift
    Text("Hello World")
        .frame(width: 300, height: 300)
        .border(Color.red, width: 30)
    ```

    **In contrast, we can use an image for the background**:

    ```swift
    Text("Hello World")
        .frame(width: 300, height: 300)
        .background(Image("Example"))
    ```

    **But using the same image as a border won’t work**:

    ```swift
    Text("Hello World")
        .frame(width: 300, height: 300)
        .border(Image("Example"), width: 30)
    ```

    **This makes sense if you think about it – unless the image is the exact right size, you have very little control over how it should look.**

    **To resolve this, SwiftUI gives us a dedicated type that wraps images in a way that we have complete control over how they should be rendered**, which in turn means we can use them for borders and fills without problem.

    **The type is called `ImagePaint`**, and it’s created using one to three parameters. 

    At the very least **you need to give it an `Image` to work with** as its first parameter, but **you can also provide a rectangle within that image to use as the source of your drawing** **specified in the range of 0 to 1** (the second parameter), **and a scale for that image** (the third parameter). 

    **Those second and third parameters have sensible default values of “the whole image” and “100% scale”**, **so you can sometimes ignore them.**

    As an example, we could render an example image using a scale of 0.2, which means it’s shown at 1/5th the normal size:

    ```swift
    Text("Hello World")
        .frame(width: 300, height: 300)
        .border(ImagePaint(image: Image("Example"), scale: 0.2), width: 30)
    ```

    **If you want to try using the `sourceRect` parameter, make sure you pass in a `CGRect` of relative sizes and positions: 0 means “start” and 1 means “end”.** For example, **this will show the entire width of our example image, but only the middle half**:

    ```swift
    Text("Hello World")
        .frame(width: 300, height: 300)
        .border(ImagePaint(image: Image("Example"), sourceRect: CGRect(x: 0, y: 0.25, width: 1, height: 0.5), scale: 0.1), width: 30)
    ```

    **It’s worth adding that `ImagePaint` can be used for view backgrounds and also shape strokes.** For example, **we could create a capsule with our example image tiled as its stroke**:

    ```swift
    Capsule()
        .strokeBorder(ImagePaint(image: Image("Example"), scale: 0.1), lineWidth: 20)
        .frame(width: 300, height: 200)
    ```

    **`ImagePaint`** **will automatically keep tiling its image until it has filled its area** – it can work with backgrounds, strokes, borders, and fills of any size.

- **Enabling high-performance Metal rendering with drawingGroup()**

    **SwiftUI uses Core Animation for its rendering by default**, which offers great performance out of the box. 

    **However, for complex rendering you might find your code starts to slow down** – anything below 60 frames per second (FPS) is a problem, but really you ought to aim higher because many iOS devices now render at 120fps.

    To demonstrate this, let’s look at some example code. W**e’re going to create a color-cycling view that renders concentric circles in a range of colors.** 

    **The result will look like a radial gradient, but we’re going to add two properties to make it more customizable: one to control how many circles should be drawn, and one to control the color cycle** – it will be able to move the gradient start and end colors around.

    We can get a color cycling effect by using the **`Color(hue:saturation:brightness:)`** initializer: **hue is a value from 0 to 1 controlling the kind of color we see** – **red is both 0 and 1, with all other hues in between.** **To figure out the hue for a particular circle we can take our circle number (e.g. 25), divide that by how many circles there are (e.g. 100), then add our color cycle amount (e.g. 0.5).** 

    So, **if we were circle 25 of 100 with a cycle amount of 0.5, our hue would be 0.75.**

    **One small complexity here is that hues don’t automatically wrap after we reach 1.0**, which means a hue of 1.0 is equal to a hue of 0.0, but a hue of 1.2 is *not* equal to a hue of 0.2. As a result, we’re going to wrap the hue by hand: **if it’s over 1.0 we’ll subtract 1.0, to make sure it always lies in the range of 0.0 to 1.0.**

    Here’s the code:

    ```swift
    struct ColorCyclingCircle: View {
        var amount = 0.0
        var steps = 100

        var body: some View {
            ZStack {
                ForEach(0..<steps) { value inCircle()
                        .inset(by: CGFloat(value))
                        .strokeBorder(self.color(for: value, brightness: 1), lineWidth: 2)
                }
            }
        }

        func color(for value: Int, brightness: Double) -> Color {
            var targetHue = Double(value) / Double(self.steps) + self.amount

            if targetHue > 1 {
                targetHue -= 1
            }

            return Color(hue: targetHue, saturation: 1, brightness: brightness)
        }
    }
    ```

    We can now use that in a layout, binding its color cycle to a local property controlled by a slider:

    ```swift
    struct ContentView: View {
        @State private var colorCycle = 0.0

        var body: some View {
            VStack {
                ColorCyclingCircle(amount: self.colorCycle)
                    .frame(width: 300, height: 300)

                Slider(value: $colorCycle)
            }
        }
    }
    ```

    If you run the app you’ll see we have a neat color wave effect controlled entirely by dragging around the slider, and it works really smoothly.

    **What you’re seeing right now is powered by Core Animation, which means it will turn our 100 circles into 100 individual views being drawn onto the screen**. **This is computationally expensive, but as you can see it works well enough – we get smooth performance.**

    However, **if we increase the complexity a little we’ll find things aren’t quite so rosy.** Replace the existing **`strokeBorder()`** modifier with this one:

    ```swift
    .strokeBorder(LinearGradient(gradient: Gradient(colors: [
        self.color(for: value, brightness: 1),
        self.color(for: value, brightness: 0.5)
    ]), startPoint: .top, endPoint: .bottom), lineWidth: 2)
    ```

    **That now renders a gentle gradient, showing bright colors at the top of the circle down to darker colors at the bottom**. And *now* when you run the app you’ll find it runs much slower – **SwiftUI is struggling to render 100 gradients as part of 100 separate views**.

    **We can fix this by applying one new modifier, called `drawingGroup()`**. 

    **This tells SwiftUI it should render the contents of the view into an off-screen image before putting it back onto the screen as a single rendered output**, **which is signficantly faster**. 

    **Behind the scenes this is powered by Metal, which is Apple’s framework for working directly with the GPU for extremely fast graphics.**

    So, modify the **`ColorCyclingCircle`** body to this:

    ```swift
    var body: some View {
        ZStack {
            // existing code…
        }
        .drawingGroup()
    }
    ```

    Now run it again – with that one tiny addition you’ll now find we get everything rendered correctly and we’re also back at full speed even with the gradients.

    **Important:** The **`drawingGroup()`** modifier is helpful to know about and to keep in your arsenal as a way to solve performance problems when you hit them, but you should *not* use it that often. Adding the off-screen render pass might slow down SwiftUI for simple drawing, so you should wait until you have an actual performance problem before trying to bring in **`drawingGroup()`**.