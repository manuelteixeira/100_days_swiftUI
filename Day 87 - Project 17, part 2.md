# Day 87 - Project 17, part 2

- **Triggering events repeatedly using a timer**

    iOS comes with a built-in **`Timer`** class **that lets us run code on a regular basis**. 

    This **uses a system of *publishers* that comes from an Apple framework called Combine**. We’ve actually been using parts of Combine for many apps in this series, although it’s unlikely you noticed it. For example, both the **`@Published`** property wrapper and **`ObservableObject`** protocols both come from Combine, but we didn’t need to know that because when you import SwiftUI we also implicitly import parts of Combine.

    Apple’s core system library is called Foundation, and it gives us things like **`Data`**, **`Date`**, **`NSSortDescriptor`**, **`UserDefaults`**, and much more. It also gives us the **`Timer`** class, which **is designed to run a function after a certain number of seconds, but it can also run code repeatedly**. 

    **Combine adds an extension to this so that timers can become *publishers*, which are things that announce when their value changes**. 

    This is where the **`@Published`** property wrapper gets its name from, and timer publishers work the same way: **when your time interval is reached, Combine will send an announcement out containing the current date and time.**

    The code to create a timer publisher looks like this:

    ```swift
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    ```

    That does several things all at once:

    1. It **asks the timer to fire every 1 second.**
    2. It **says the timer should run on the main thread**.
    3. It **says the timer should run on the common run loop**, which is the one you’ll want to use most of the time. (Run loops lets iOS handle running code while the user is actively doing something, such as scrolling in a list.)
    4. It **connects the timer immediately, which means it will start counting time**.
    5. It **assigns the whole thing to the `timer` constant so that it stays alive**.

    If you remember, back in project 7 I said “**`@Published`** is more or less half of **`@State`**” – it sends change announcements that something else can monitor. 

    **In the case of regular publishers like this one, we need to catch the announcements by hand using a new modifier called `onReceive()`**. 

    This **accepts a publisher as its first parameter and a function to run as its second**, and **it will make sure that function is called whenever the publisher sends its change notification.**

    For our timer example, we could receive its notifications like this:

    ```swift
    Text("Hello, World!")
        .onReceive(timer) { time in
    				print("The time is now \(time)")
        }
    ```

    That will print the time every second until the timer is finally stopped.

    Speaking of stopping the timer, it takes a little digging to stop the one we created. 

    You see, **the `timer` property we made is an autoconnected publisher, so we need to go to its *upstream publisher* to find the timer itself**.

    **From there we can connect to the timer publisher, and ask it to cancel itself.** 

    Honestly, if it were’t for code completion this would be rather hard to find, but here’s how it looks in code:

    ```
    self.timer.upstream.connect().cancel()
    ```

    For example, **we could update our existing example so that it fires the timer only five times**, like this:

    ```swift
    struct ContentView: View {
        let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
        @State private var counter = 0

        var body: some View {
            Text("Hello, World!")
                .onReceive(timer) { time inif self.counter == 5 {
                        self.timer.upstream.connect().cancel()
                    } else {
                        print("The time is now \(time)")
                    }

                    self.counter += 1
                }
        }
    }
    ```

    Before we’re done, there’s one more important timer concept I want to show you: **if you’re OK with your timer having a little float, you can specify some *tolerance*. This allows iOS to perform important energy optimization**, because it can fire the timer at any point between its scheduled fire time and its scheduled fire time plus the tolerance you specify. 

    In practice this **means the system can perform *timer coalescing*: it can push back your timer just a little so that it fires at the same time as one or more other timers, which means it can keep the CPU idling more and save battery power**.

    As an example, this adds half a second of tolerance to our timer:

    ```swift
    let timer = Timer.publish(every: 1, tolerance: 0.5, on: .main, in: .common).autoconnect()
    ```

    If you need to keep time strictly then leaving off the **`tolerance`** parameter will make your timer as accurate as possible, but please note that even without any tolerance the **`Timer`** class is still “best effort” – the system makes no guarantee it will execute precisely.

- **How to be notified when your SwiftUI app moves to the background**

    **SwiftUI can detect when your app moves to the background** (i.e., when the user returns to the home screen), **when it comes back to the foreground, when the user takes a screenshot, and much more**. 

    This is all **powered by Notification Center**, which is the name for Apple’s internal message system – **API that lets the system notify us when events happen, but also lets us post messages between different parts of our code.**

    Notification Center is another thing that comes from Apple’s Foundation framework, and in SwiftUI **we can monitor its events using Combine**, so really this is three of Apple’s frameworks working together to give us some great functionality.

    For example, **Notification Center posts a message called `UIApplication.willResignActiveNotification` when your app starts to move to the background, which gives us the chance to pause any work that isn’t critical, save our data, and more**. 

    To use it, **we need to ask Notification Center to create a publisher for that notification, then attach whatever work we want**. 

    **We’ll be given the actual message that occurred as a parameter to our closure, but most of the time you can ignore this.**

    So, try this to have a message printed out when the user leaves your app:

    ```swift
    Text("Hello, World!")
        .onReceive(
    				NotificationCenter.default.publisher(
    						for: UIApplication.willResignActiveNotification)
    		) { _ in
    				print("Moving to the background!")
        }
    ```

    **There are lots of these notifications that we can listen for, and they all work in exactly the same way**. For example, the opposite of **`willResignActiveNotification`** is **`willEnterForegroundNotification`**, which is called when the user has re-activated your app and is your chance to continue any important work:

    ```swift
    Text("Hello, World!")
        .onReceive(
    				NotificationCenter.default.publisher(
    						for: UIApplication.willEnterForegroundNotification)
    		) { _ in
    				print("Moving back to the foreground!")
        }
    ```

    You can even **detect when the user took a screenshot**, using **`userDidTakeScreenshotNotification`**:

    ```
    Text("Hello, World!")
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.userDidTakeScreenshotNotification)) { _ inprint("User took a screenshot!")
        }
    ```

    There are so many of these that I can’t realistically list them all here, so instead here are two more to try out:

    - **`UIApplication.significantTimeChangeNotification`** is called when the user changes their clock or when daylight savings time changes.
    - **`UIResponder.keyboardDidShowNotification`** is called when the keyboard is shown.

    Each of these notifications works in exactly the same way: use **`onReceive()`** to catch notifications from the publisher, then take whatever action you want.

- **Supporting specific accessibility needs with SwiftUI**

    **SwiftUI gives us a number of environment properties that describe the user’s custom accessibility settings**, and it’s worth taking the time to read and respect those settings.

    Back in project 15 we looked at accessibility labels and hints, traits, groups, and more, but these settings are different because they are provided through the environment. This means SwiftUI automatically monitors them for changes and will reinvoke our **`body`** property whenever one of them changes.

    For example, **one of the accessibility options is “Differentiate without color”, which is helpful for the 1 in 12 men who have color blindness**. 

    **When this setting is enabled, apps should try to make their UI clearer using shapes, icons, and textures rather than colors.**

    To use this, just add an environment property like this one:

    ```swift
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
    ```

    That will be either true or false, and you can adapt your UI accordingly. For example, in the code below **we use a simple green background for the regular layout, but when Differentiate Without Color is enabled we use a black background and add a checkmark instead**:

    ```swift
    struct ContentView: View {
        @Environment(\.accessibilityDifferentiateWithoutColor) var differentiateWithoutColor
        var body: some View {
            HStack {
                if differentiateWithoutColor {
                    Image(systemName: "checkmark.circle")
                }

                Text("Success")
            }
            .padding()
            .background(differentiateWithoutColor ? Color.black : Color.green)
            .foregroundColor(Color.white)
            .clipShape(Capsule())
        }
    }
    ```

    You can test that in the simulator by going to the Settings app and choosing Accessibility > Display & Text Size > Differentiate Without Color.

    **Another common option is Reduce Motion**, which again is available in the simulator under Accessibility > Motion > Reduce Motion. **When this is enabled, apps should should limit the amount of animation that causes movement on screen**. 

    For example, the iOS app switcher makes views fade in and out rather than scale up and down.

    With SwiftUI, **this means we should restrict the use of `withAnimation()` when it involves movement**, like this:

    ```swift
    struct ContentView: View {
        @Environment(\.accessibilityReduceMotion) var reduceMotion
        @State private var scale: CGFloat = 1

        var body: some View {
            Text("Hello, World!")
                .scaleEffect(scale)
                .onTapGesture {
                    if self.reduceMotion {
                        self.scale *= 1.5
                    } else {
                        withAnimation {
                            self.scale *= 1.5
                        }
                    }
                }
        }
    }
    ```

    I don’t know about you, but I find that rather annoying to use. Fortunately **we can add a little wrapper function around `withAnimation()` that uses UIKit’s `UIAccessibility` data directly, allowing us to bypass animation automatically**:

    ```swift
    func withOptionalAnimation<Result>(_ animation: Animation? = .default, _ body: () throws -> Result) rethrows -> Result {
        if UIAccessibility.isReduceMotionEnabled {
            return try body()
        } else {
            return try withAnimation(animation, body)
        }
    }
    ```

    So, **when Reduce Motion Enabled is true the closure code that’s passed in is executed immediately, otherwise it’s passed along using** **`withAnimation()`**. 

    The whole **`throws`**/**`rethrows`** thing is more advanced Swift, but it’s a direct copy of the function signature for **`withAnimation()`** so that the two can be used interchangeably.

    Use it like this:

    ```swift
    struct ContentView: View {
        @State private var scale: CGFloat = 1

        var body: some View {
            Text("Hello, World!")
                .scaleEffect(scale)
                .onTapGesture {
                    withOptionalAnimation {
                        self.scale *= 1.5
                    }
                }
        }
    }
    ```

    Using this approach you don’t need to repeat your animation code every time.

    One last option you should consider supporting is **Reduce Transparency, and when that’s enabled apps should reduce the amount of blur and translucency used in their designs to make doubly sure everything is clear.**

    For example, this code uses a solid black background when Reduce Transparency is enabled, otherwise using 50% transparency:

    ```swift
    struct ContentView: View {
        @Environment(\.accessibilityReduceTransparency) var reduceTransparency
        var body: some View {
            Text("Hello, World!")
                .padding()
                .background(reduceTransparency ? Color.black : Color.black.opacity(0.5))
                .foregroundColor(Color.white)
                .clipShape(Capsule())
        }
    }
    ```

    That’s the final technique I want you to learn ahead of building the real project, so please reset your project back to its original state so we have a clean slate to start on.