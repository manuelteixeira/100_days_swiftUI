# Day 32 - Project 6, part 1

- **Creating implicit animations**

    In SwiftUI, the simplest type of animation is an *implicit* one: we tell our views ahead of time “if someone wants to animate you, here’s how you should respond”, and nothing more. SwiftUI will then take care of making sure any changes that *do* occur follow the animation you requested. In practice this makes animation trivial – it literally could not be any easier.

    Let’s start with an example. **This code shows a simple red button with no action, using 50 points of padding and a circular clip shape**:

    ```swift
    Button("Tap Me") {
        // do nothing
    }
    .padding(50)
    .background(Color.red)
    .foregroundColor(.white)
    .clipShape(Circle())
    ```

    What **we want is for that button to get bigger every time it’s tapped, and we can do that with a new modifier called** **`scaleEffect()`**. 

    **You provide this with a value from 0 up, and it will be drawn at that size – a value of 1.0 is equivalent to 100%**, i.e. the button’s normal size.

    **Because we want to change the scale effect value every time the button is tapped, we need to use an `@State` property**, but there’s a catch here: for historical reasons mostly around interacting with Apple’s older APIs, we need to use a specific data type called **`CGFloat`**.

    **`CGFloat`** is, for all intents and purposes, a **`Double`** under a different name, but on older hardware it uses a smaller type of number storage called **`Float`**. Back when this choice mattered, **`CGFloat`** allowed Apple not to care about which type of hardware we were building for, but nowadays almost everything uses **`Double`** so it’s just a piece of legacy staring at us with disgust.

    Anyway, all this matters because if we make the property **`var animationAmount = 1`** we get an integer, and if we use **`var animationAmount = 1.0`** then we get a **`Double`**, but there is no built-in way to get a **`CGFloat`** automatically – we need to use a type annotation.

    So, please add this property to your view now:

    ```swift
    @State private var animationAmount: CGFloat = 1
    ```

    Now we can make the button use that for its scale effect, by adding this modifier:

    ```swift
    .scaleEffect(animationAmount)
    ```

    Finally, **when the button is tapped we want to increase the animation amount by 1**, so use this for the button’s action:

    ```swift
    self.animationAmount += 1
    ```

    If you run that code you’ll see that you can tap the button repeatedly to have it scale up and up. **It won’t get redrawn at increasingly high resolutions, so as the button gets bigger you’ll see it gets a bit blurry**, but that’s OK.

    Now, the human eye is highly sensitive to movement – we’re extremely good at detecting when things move or change their appearance, which is what makes animation both so important and so pleasing. **So, we can ask SwiftUI to create an implicit animation for our changes so that all the scaling happens smoothly by adding an `animation()` modifier to the button:**

    ```swift
    .animation(.default)
    ```

    **That asks SwiftUI for a default animation, and immediately you’ll see that tapping the button now causes it to scale up with an animation**.

    **That implicit animation takes effect on all properties of the view that change**, **meaning that if we attach more animating modifiers to the view then they will all change together**. For example, we could add a second new modifier to the button, **`.blur()`**, which lets us add a Gaussian blur with a special radius:

    ```swift
    .blur(radius: (animationAmount - 1) * 3)
    ```

    A radius of **`(animationAmount - 1) * 3`** **means the blur radius will start at 0 (no blur), but then move to 3 points, 6 points, 9 points, and beyond as you tap the button.**

    If you run the app again you’ll see that it now scales and blurs smoothly.

    The point is that nowhere have we said what each frame of the animation should look like, and we haven’t even said when SwiftUI should start and finish the animation. Instead, our animation becomes a function of our state just like the views themselves.

- **Customizing animations in SwiftUI**

    **When we attach the modifier `.animation(.default)` to a view, SwiftUI will automatically animate any changes that happen to that view using whatever is the default system animation**. 

    In practice, **that is an “ease in, ease out” animation**, which means **iOS will start the animation slow, make it pick up speed, then slow down as it approaches its end.**

    **We can control the type of animation used by passing in different values to the modifier.** 

    For example, we could use **`.easeOut`** **to make the animation start fast then slow down to a smooth stop**:

    ```swift
    .animation(.easeOut)
    ```

    **There are even spring animations, that cause the movement to overshoot then return to settle at its target**. **You can control the initial stiffness of the spring** (which sets its initial velocity when the animation starts), **and also how fast the animation should be “damped”** – **lower values cause the spring to bounce back and forth for longer.**

    For example, this makes our button scale up quickly then bounce:

    ```swift
    .animation(.interpolatingSpring(stiffness: 50, damping: 1))
    ```

    For more precise control, **we can customize the animation with a duration specified as a number of seconds**. So, we could get an ease-in-out animation that lasts for two seconds like this:

    ```swift
    struct ContentView: View {
        @State private var animationAmount: CGFloat = 1

        var body: some View {
            Button("Tap Me") {
                self.animationAmount += 1
            }
            .padding(50)
            .background(Color.red)
            .foregroundColor(.white)
            .clipShape(Circle())
            .scaleEffect(animationAmount)
            .animation(.easeInOut(duration: 2))
        }
    }
    ```

    When we say **`.easeInOut(duration: 2)`** **we’re actually creating an instance of an `Animation` struct that has its own set of modifiers**. **So, we can attach modifiers directly to the animation to add a delay** like this:

    ```swift
    .animation(
        Animation.easeInOut(duration: 2)
            .delay(1)
    )
    ```

    **You’ll notice that we explicitly have to say `Animation.easeInOut()` now, because otherwise Swift isn’t quite sure what we mean.** 

    Regardless, tapping the button will now wait for a second before executing a two-second animation.

    **We can also ask the animation to repeat a certain number of times, and even make it bounce back and forward by setting `autoreverses` to true**. 

    This creates a one-second animation that will bounce up and down before reaching its final size:

    ```swift
    .animation(
        Animation.easeInOut(duration: 1)
            .repeatCount(3, autoreverses: true)
    )
    ```

    **If we had set repeat count to 2 then the button would scale up then down again, then jump immediately back up to its larger scale**. 

    **This is because ultimately the button must match the state of our program, regardless of what animations we apply** – **when the animation finishes the button must have whatever value is set in `animationAmount`.**

    **For continuous animations, there is a `repeatForever()` modifier** that can be used like this:

    ```swift
    .animation(
        Animation.easeInOut(duration: 1)
            .repeatForever(autoreverses: true)
    )
    ```

    **We can use these `repeatForever()` animations in combination with `onAppear()` to make animations that start immediately and continue animating for the life of the view**.

    To demonstrate this, **we’re going to remove the animation from the button itself and instead apply it an overlay to make a sort of pulsating circle around the button.**

    So, first add this **`overlay()`** modifier to the button:

    ```swift
    .overlay(
        Circle()
            .stroke(Color.red)
            .scaleEffect(animationAmount)
            .opacity(Double(2 - animationAmount))
    )
    ```

    **That makes a stroked red circle over our button, using an opacity value of `2 - animationAmount` so that when `animationAmount` is 1 the opacity is 1 (it’s opaque) and when `animationAmount` is 2 the opacity is 0 (it’s transparent).**

    Next, remove the **`scaleEffect()`** modifier from the button and comment out the **`animationAmount += 1`** action part too, because we don’t want that to change any more, and move its animation modifier up to the circle inside the overlay:

    ```swift
    .overlay(
        Circle()
            .stroke(Color.red)
            .scaleEffect()
            .opacity(Double(2 - animationAmount))
            .animation(
                Animation.easeOut(duration: 1)
                    .repeatForever(autoreverses: false)
            )
    )
    ```

    I’ve switched **`autoreverses`** to false, but otherwise it’s the same animation.

    Finally, add an **`onAppear()`** modifier to the button, which will set **`animationAmount`** to 2:

    ```swift
    .onAppear {
        self.animationAmount = 2
    }
    ```

    **Because the overlay circle uses that for a “repeat forever” animation without autoreversing, you’ll see the overlay circle scale up and fade out continuously.**

    Your finished code should look like this:

    ```swift
    Button("Tap Me") {
        // self.animationAmount += 1
    }
    .padding(40)
    .background(Color.red)
    .foregroundColor(.white)
    .clipShape(Circle())
    .overlay(
        Circle()
            .stroke(Color.red)
            .scaleEffect(animationAmount)
            .opacity(Double(2 - animationAmount))
            .animation(
                Animation.easeOut(duration: 1)
                    .repeatForever(autoreverses: false)
            )
    )
    .onAppear {
        self.animationAmount = 2
    }
    ```

    Given how little work that involves, it creates a remarkably attractive effect!

- **Animating bindings**

    The **`animation()`** **modifier can be applied to any SwiftUI binding, which causes the value to animate between its current and new value**. 

    **This even works if the data in question isn’t really something that sounds like it can be animated, such as a Boolean** – you can mentally imagine animating from 1.0 to 2.0 because we could do 1.05, 1.1, 1.15, and so on, but going from “false” to “true” sounds like there’s no room for in between values.

    This is best explained with some working code to look at, so here’s a view with a **`VStack`**, a **`Stepper`**, and a **`Button`**:

    ```swift
    struct ContentView: View {
        @State private var animationAmount: CGFloat = 1

        var body: some View {
            VStack {
                Stepper("Scale amount", value: $animationAmount.animation(), in: 1...10)

                Spacer()

                Button("Tap Me") {
                    self.animationAmount += 1
                }
                .padding(40)
                .background(Color.red)
                .foregroundColor(.white)
                .clipShape(Circle())
                .scaleEffect(animationAmount)
            }
        }
    }
    ```

    **Tip:** That uses a simplified **`Stepper`** initializer that works great if you only want a text title, much the same way as **`Button`** has a simplified text initializer too.

    As you can see, **the stepper can move `animationAmount` up and down, and tapping the button will add 1 to it – they are both tied to the same data, which in turn causes the size of the button to change**. 

    **However, tapping the button changes `animationCount` immediately, so the button will just jump up to its larger size**. 

    In contrast, t**he stepper is bound to `$animationAmount.animation()`, which means SwiftUI will automatically animate its changes**.

    Now, as an experiment I’d like you to change the start of the **`body`** to this:

    ```swift
    var body: some View {
        print(animationAmount)

        return VStack {
    ```

    **Because we have some non-view code in there, we need to add `return` before the `VStack` so Swift understands which part is the view that is being sent back**. 

    But adding **`print(animationAmount)`** is important, and to see why I’d like you to **run the program again and try manipulating the stepper.**

    **What you should see is that it prints out 2.0, 3.0, 4.0, and so on.** 

    **At the same time, the button is scaling up or down smoothly** – **it doesn’t just jump straight to scale 2, 3, and 4.** 

    **What’s *actually* happening here is that SwiftUI is examining the state of our view before the binding changes, examining the target state of our views *after* the binding changes, then applying an animation to get from point A to point B.**

    **This is why we can animate a Boolean changing**: **Swift isn’t somehow inventing new values between false and true, but just animating the view changes that occur as a result of the change.**

    These binding animations use the same **`animation()`** modifier that we use on views, so you can go to town with animation modifiers if you want to:

    ```swift
    Stepper("Scale amount", value: $animationAmount.animation(
        Animation.easeInOut(duration: 1)
            .repeatCount(3, autoreverses: true)
    ), in: 1...10)
    ```

    These binding animations effectively turn the tables on implicit animations: rather than setting the animation on a view and implicitly animating it with a state change, we now set nothing on the view and explicitly animate it with a state change. In the former, the state change has no idea it will trigger an animation, and in the latter the view has no idea it will be animated – both work and both are important.

- **Creating explicit animations**

    **You’ve seen how SwiftUI lets us create implicit animations by attaching the `animation()` modifier to a view**, 

    **and how it also lets us create animated binding changes by adding the `animation()` modifier to a binding**, 

    but **there’s a third useful way we can create animations: explicitly asking SwiftUI to animate changes occurring as the result of a state change**.

    This still doesn’t mean we create each frame of the animation by hand – that remains SwiftUI’s job, and it continues to figure out the animation by looking at the state of our views before and after the state change was applied.

    Now, though, **we’re being explicit that we want an animation to occur when some arbitrary state change occurs: it’s not attached to a binding, and it’s not attached to a view, it’s just us explicitly asking for a particular animation to occur because of a state change.**

    To demonstrate this, let’s return to a simple button example again:

    ```swift
    struct ContentView: View {   
        var body: some View {
            Button("Tap Me") {
                // do nothing
            }
            .padding(50)
            .background(Color.red)
            .foregroundColor(.white)
            .clipShape(Circle())
        }
    }
    ```

    **When that button is tapped, we’re going to make it spin around with a 3D effect.** 

    This requires another new modifier, **`rotation3DEffect()`**, **which can be given a rotation amount in degrees as well as an axis that determines how the view rotates**. Think of this axis like a skewer through your view:

    - **If we skewer the view through the X axis (horizontally) then it will be able to spin forwards and backwards.**
    - **If we skewer the view through the Y axis (vertically) then it will be able to spin left and right.**
    - **If we skewer the view through the Z axis (depth) then it will be able to rotate left and right.**

    **Making this work requires some state we can modify, and rotation degrees are specified as a `Double`**. So, please add this property now:

    ```swift
    @State private var animationAmount = 0.0
    ```

    Next, **we’re going to ask the button to rotate by `animationAmount` degrees along its Y axis, which means it will spin left and right.** Add this modifier to the button now:

    ```swift
    .rotation3DEffect(.degrees(animationAmount), axis: (x: 0, y: 1, z: 0))
    ```

    Now for the important part: **we’re going to add some code to the button’s action so that it adds 360 to `animationAmount` every time it’s tapped.**

    If we just write **`self.animationAmount += 360`** **then the change will happen immediately, because there is no animation modifier attached to the button**. 

    This is where explicit animations come in: **if we use a `withAnimation()` closure then SwiftUI will ensure any changes resulting from the new state will automatically be animated.**

    So, put this in the button’s action now:

    ```swift
    withAnimation {
        self.animationAmount += 360
    }
    ```

    Run that code now and I think you’ll be impressed by how good it looks – every time you tap the button it spins around in 3D space, and it was so easy to write. If you have time, experiment a little with the axes so you can really understand how they work. In case you were curious, you can use more than one axis at once.

    **`withAnimation()`** **can be given an animation parameter, using all the same animations you can use elsewhere in SwiftUI.** For example, we could make our rotation effect use a spring animation using a **`withAnimation()`** call like this:

    ```swift
    withAnimation(.interpolatingSpring(stiffness: 5, damping: 1)) {
        self.animationAmount += 360
    }
    ```