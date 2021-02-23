# Day 89 - Project 17, part 4

- **Coloring views as we swipe**

    **Users can swipe our cards left or right to mark them as being guessed correctly or not, but there’s no visual distinction between the two directions**. Borrowing controls from dating apps like Tinder, **we’ll make swiping *right* good** (they guessed the answer correctly), **and swiping *left* bad** (they were wrong).

    We’ll solve this problem in two ways: **for a phone with default settings we’ll make the cards become colored green or red before fading away, but if the user enabled the Differentiate Without Color setting we’ll leave the cards as white and instead show some extra UI over our background.**

    Let’s start with a first pass on the cards themselves. Right now our card view is created with this background:

    ```swift
    RoundedRectangle(cornerRadius: 25, style: .continuous)
        .fill(Color.white)
        .shadow(radius: 10)
    ```

    We’re going to replace that with some more advanced code: **we’ll give it a background of the same rounded rectangle except in green or red depending on the gesture movement**, **then we’ll make the white fill from above fade out as the drag movement gets larger**.

    First, the background. Add this directly before the **`shadow()`** modifier:

    ```swift
    .background(
        RoundedRectangle(cornerRadius: 25, style: .continuous)
            .fill(offset.width > 0 ? Color.green : Color.red)
    )
    ```

    As for the white fill opacity, this is going to be similar to the **`opacity()`** modifier we added previously except **we’ll use 1 minus 1/50th of the gesture width rather than 2 minus the gesture width**. This creates a really nice effect: we used 2 minus earlier because it meant the card would have to move at least 50 points before fading away, but for the card fill **we’re going to use 1 minus so that it starts becoming colored straight away.**

    Replace the existing **`fill()`** modifier with this:

    ```swift
    .fill(
        Color.white
            .opacity(1 - Double(abs(offset.width / 50)))
    )
    ```

    If you run the app now you’ll see that the cards blend from white to either red or green, *then* start to fade out. Awesome!

    However, as nice as our code is **it won’t work well for folks with red/green color blindness** – they will see the brightness of the cards change, but it won’t be clear which side is which.

    To fix this **we’re going to add an environment property to track whether we should be using color for this purpose or not, then disable the red/green effect when that property is true**.

    Start by adding this new property to **`CardView`**, before the existing properties:

    ```swift
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
    ```

    Now **we can use that for both the fill and background for our `RoundedRectangle` to make sure we fade out the white smoothly**. It’s important we use it for both, because as the card fades out the background color will start to bleed through the fill.

    So, replace your current **`RoundedRectangle`** code with this:

    ```swift
    RoundedRectangle(cornerRadius: 25, style: .continuous)
        .fill(
            differentiateWithoutColor
                ? Color.white
                : Color.white
                    .opacity(1 - Double(abs(offset.width / 50)))

        )
        .background(
            differentiateWithoutColor
                ? nil
                : RoundedRectangle(cornerRadius: 25, style: .continuous)
                    .fill(offset.width > 0 ? Color.green : Color.red)
        )
        .shadow(radius: 10)
    ```

    So, when in a default configuration our cards will fade to green or red, but when Differentiate Without Color is enabled that won’t be used. Instead **we need to provide some extra UI in `ContentView` to make it clear which side is positive and which is negative.**

    Earlier we made a very particular structure of stacks in **`ContentView`**: we had a **`ZStack`**, then a **`VStack`**, then another **`ZStack`**. **That first `ZStack`, the outermost one, allows us to have our background and card stack overlapping, and we’re also going to put some buttons in that stack so users can see which side is “good”.**

    First, add this property to **`ContentView`**:

    ```swift
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
    ```

    Now add these new views directly after the **`VStack`**:

    ```swift
    if differentiateWithoutColor {
        VStack {
            Spacer()

            HStack {
                Image(systemName: "xmark.circle")
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .clipShape(Circle())
                Spacer()
                Image(systemName: "checkmark.circle")
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .clipShape(Circle())
            }
            .foregroundColor(.white)
            .font(.largeTitle)
            .padding()
        }
    }
    ```

    **That creates another `VStack`, this time starting with a spacer so that the images inside the stacks are pushed to the bottom of the screen**. And with that condition around them all, **they’ll only appear when Differentiate Without Color is enabled**, so most of the time our UI stays clear.

    All this extra work *matters*: it makes sure users get a great experience regardless of their accessibility needs, and that’s what we should always be aiming for.

- **Counting down with a Timer**

    If we combine Foundation, SwiftUI, and Combine, we can add a timer to our app to add a little bit of pressure to the user. A simple implementation of this doesn’t take much work, but it also has a bug that requires some extra work to fix.

    For our first pass of the timer, **we’re going to create two new properties: the timer itself, which will fire once a second, and a `timeRemaining` property, from which we’ll subtract 1 every time the timer fires**. 

    This will **allow us to show how many seconds remain in the current app run**, which should give the user a gentle incentive to speed up.

    So, start by adding these two new properties to **`ContentView`**:

    ```swift
    @State private var timeRemaining = 100
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    ```

    That gives the user 100 seconds to start with, then creates and starts a timer that fires once a second on the main thread.

    Whenever that timer fires, we want to subtract 1 from **`timeRemaining`** so that it counts down. We could try and do some date mathematics here by storing a start date and showing the difference between that and the current date, but there really is no need as you’ll see!

    **Add this `onReceive()` modifier to the outermost `ZStack` in `ContentView`:**

    ```swift
    .onReceive(timer) { time in
    		if self.timeRemaining > 0 {
            self.timeRemaining -= 1
        }
    }
    ```

    **Tip:** That adds a trivial condition to make sure we never stray into negative numbers.

    That code starts our timer at 100 and makes it count down to 0, but we need to actually display it. This is as simple as **adding another text view to our layout, this time with a dark background color to make sure it’s clearly visible.**

    Put this inside the **`VStack`** that contains the **`ZStack`** for our cards:

    ```swift
    Text("Time: \(timeRemaining)")
        .font(.largeTitle)
        .foregroundColor(.white)
        .padding(.horizontal, 20)
        .padding(.vertical, 5)
        .background(
            Capsule()
                .fill(Color.black)
                .opacity(0.75)
        )
    ```

    If you’ve placed it correctly, your layout code should look like this:

    ```swift
    ZStack {
        Image("background")
            .resizable()
            .scaledToFill()
            .edgesIgnoringSafeArea(.all)

        VStack {
            Text("Time: \(timeRemaining)")
                .font(.largeTitle)
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 5)
                .background(
                    Capsule()
                        .fill(Color.black)
                        .opacity(0.75)
                )

            ZStack {
    ```

    You should be able to run the app now and give it a try – it works well enough, right? Well, there’s a **small problem**:

    1. **Take a look at the current value in the timer.**
    2. **Press Cmd+H to go back to the home screen.**
    3. **Wait about ten seconds.**
    4. **Now tap your app’s icon to go back to the app.**
    5. **What time is shown in the timer?**

    What I find is that **the timer shows a value about three seconds lower than we had when we were in the app previously** – **the timer runs for a few seconds in the background, then pauses until the app comes back.**

    We can do better than this: **we can detect when our app moves to the background or foreground, then pause and restart our timer appropriately**.

    First, add this property to store whether the app is currently active:

    ```swift
    @State private var isActive = true
    ```

    Next, **we need to add two more `onReceive()` modifiers below the previous one, to manipulate `isActive` as the apps moves to and from the background.** For these, we can catch the **`UIApplication.willResignActiveNotification`** and **`UIApplication.willEnterForegroundNotification`** notifications, like this:

    ```swift
    .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
    		self.isActive = false
    }
    .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
    		self.isActive = true
    }
    ```

    Finally, modify the **`onReceive(timer)`** function so **it exits immediately is `isActive` is false, like this:**

    ```swift
    .onReceive(timer) { time in
    		guard self.isActive else { return }
        if self.timeRemaining > 0 {
            self.timeRemaining -= 1
        }
    }
    ```

    And with that small change the timer will automatically pause when the app moves to the background – we no longer lose any mystery seconds.

- **Ending the app with allowsHitTesting()**

    **SwiftUI lets us disable interactivity for a view by setting `allowsHitTesting()` to false**, so in our project **we can use it to disable swiping on any card when the time runs out** by checking the value of **`timeRemaining`**.

    Start by adding this modifier to the innermost **`ZStack`** – the one that shows our card stack:

    ```swift
    .allowsHitTesting(timeRemaining > 0)
    ```

    That enables hit testing when **`timeRemaining`** is 1 or greater, but sets it to false otherwise because the user is out of time.

    The *other* outcome is that the user flies through all the cards correctly, and ends with none left. **When the final card goes away, right now our timer slides down to the center of the screen, and carries on ticking**. 

    What **we *want* to happen is for the timer to stop so users can see how fast they were**, **and also to show a button allowing them to reset their cards and try again.**

    This takes a little thinking, because just setting **`isActive`** to false isn’t enough – if the app moves to the background and returns **`isActive`** will be re-enabled even though there are no cards left.

    Let’s tackle it piece by piece. First, we need a method to run to reset the app so the user can try again, so add this to **`ContentView`**:

    ```swift
    func resetCards() {
        cards = [Card](repeating: Card.example, count: 10)
        timeRemaining = 100
        isActive = true
    }
    ```

    Second, **we need a button to trigger that**, shown only when all cards have been removed. Put this after the innermost **`ZStack`**, just below the **`allowsHitTesting()`** modifier:

    ```swift
    if cards.isEmpty {
        Button("Start Again", action: resetCards)
            .padding()
            .background(Color.white)
            .foregroundColor(.black)
            .clipShape(Capsule())
    }
    ```

    Now we have code to restart the timer when resetting the cards, but now **we need to *stop* the timer when the final card is removed** – **and make sure it *stays* stopped when coming back to the foreground.**

    We can solve the first problem by adding this to the end of the **`removeCard(at:)`** method:

    ```swift
    if cards.isEmpty {
        isActive = false
    }
    ```

    As for the second problem – making sure **`isActive`** *stays* false when returning from the background – we should just update our function attached to **`willEnterForegroundNotification`** so that it explicitly checks for cards:

    ```swift
    .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
    		if self.cards.isEmpty == false {
            self.isActive = true
        }
    }
    ```

    Done!