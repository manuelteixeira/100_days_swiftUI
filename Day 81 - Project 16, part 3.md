# Day 81 - Project 16, part 3

- **Creating context menus**

    When the user taps a button or a navigation link, it’s pretty clear that SwiftUI should trigger the default action for those views. 

    But what if they press and hold on something? On older iPhones users could trigger a 3D Touch by pressing hard on something, but the principle is the same: the user wants more options for whatever they are interacting with.

    **SwiftUI lets us attach context menus to objects to provide this extra functionality, all done using the `contextMenu()` modifier**. 

    **You can pass this a selection of buttons and they’ll be shown in order**, so we could build a simple context menu to control a view’s background color like this:

    ```swift
    struct ContentView: View {
        @State private var backgroundColor = Color.red

        var body: some View {
            VStack {
                Text("Hello, World!")
                    .padding()
                    .background(backgroundColor)

                Text("Change Color")
                    .padding()
                    .contextMenu {
                        Button(action: {
                            self.backgroundColor = .red
                        }) {
                            Text("Red")
                        }

                        Button(action: {
                            self.backgroundColor = .green
                        }) {
                            Text("Green")
                        }

                        Button(action: {
                            self.backgroundColor = .blue
                        }) {
                            Text("Blue")
                        }
                    }
            }
        }
    }
    ```

    Just like **`TabView`**, **each item in a context menu can have text and an image attached to it**, and again **it doesn’t matter what order you provide them in or if you try to provide more than one image – it will always be the text first then an image.**

    Now, there is a catch here: **to keep user interfaces looking somewhat uniform across apps, iOS renders each image as a solid color where the opacity is preserved**. 

    This makes many pictures useless: if you had three photos of three different dogs, all three would be rendered as a plain black square because all the color got removed.

    Instead, **you should aim for line art icons such as Apple’s SF Symbols**, like this:

    ```swift
    Button(action: {
        self.backgroundColor = .red
    }) {
        Text("Red")
        Image(systemName: "checkmark.circle.fill")
            .foregroundColor(.red)
    }
    ```

    I have a few **tips for you when working with context menus**, to help ensure you give your users the best experience:

    1. **If you’re going to use them, use them in lots of places – it can be frustrating to press and hold on something only to find nothing happens.**
    2. **Keep your list of options as short as you can** – aim for **three or less.**
    3. **Don’t repeat options the user can already see elsewhere in your UI.**

    Remember, context menus are by their nature hidden, so please **think twice before hiding important actions in a context menu.**

- **Scheduling local notifications**

    iOS has a **framework called UserNotifications**, that does pretty much exactly what you expect: **lets us create notifications to the user that can be shown on the lock screen**. 

    **We have two types of notifications** to work with, and they differ depending on where they were created: **local notifications** are ones **we schedule locally**, and **remote notifications** (commonly called *push* notifications) are **sent from a server somewhere.**

    **Remote notifications require a server to work, because you send your message to Apple’s push notification service (APNS), which then forwards it to users**. 

    But local notifications are nice and easy in comparison, because we can send any message at any time as long as the user allows it.

    To try this out, start by adding an extra import near the top of ContentView.swift:

    ```swift
    import UserNotifications
    ```

    Next we’re going to put in some basic structure that we’ll fill in with local notifications code. **Using local notifications requires asking the user for permission, then actually registering the notification we want to show.** 

    We’ll place each of those actions into separate buttons inside a **`VStack`**, so please put this inside your **`ContentView`** struct now:

    ```swift
    VStack {
        Button("Request Permission") {
            // first
        }

        Button("Schedule Notification") {
            // second
        }
    }
    ```

    OK, that’s our set up complete so let’s turn our focus to the first of two important pieces of work: requesting authorization to show alerts. 

    **Notifications can take a variety of forms, but the most common thing to do is ask for permission to show alerts, badges, and sounds** – that doesn’t mean we need to use all of them at the same time, but by asking permission up front means we can be selective later on.

    **When we tell iOS what kinds of notifications we want, it will show a prompt to the user so they have the final say on what our app can do**. 

    When they make their choice, a closure we provide will get called and tell us whether the request was successful or not.

    So, replace the **`// first`** comment with this:

    ```swift
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
    		if success {
            print("All set!")
        } else if let error = error {
            print(error.localizedDescription)
        }
    }
    ```

    If the user grants permission, then we’re all clear to start scheduling notifications. 

    Even though **notifications** might seem simple, **Apple breaks them down into three parts** to give it maximum flexibility:

    - **The content is what should be shown**, and can be a title, subtitle, sound, image, and so on.
    - **The trigger determines when the notification should be shown**, and can be a number of seconds from now, a date and time in the future, or a location.
    - **The request combines the content and trigger, but also adds a unique identifier so you can edit or remove specific alerts later on**. If you don’t want to edit or remove stuff, use **`UUID().uuidString`** to get a random identifier.

    When you’re just learning notifications the easiest trigger type to use is **`UNTimeIntervalNotificationTrigger`**, which **lets us request a notification to be shown in a certain number of seconds from now**. So, replace the **`// second`** comment with this:

    ```swift
    let content = UNMutableNotificationContent()
    content.title = "Feed the cat"
    content.subtitle = "It looks hungry"
    content.sound = UNNotificationSound.default// show this notification five seconds from now
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

    // choose a random identifier
    let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

    // add our notification request
    UNUserNotificationCenter.current().add(request)
    ```

    If you run your app now, press the first button to request notification permission, then press the second to add an actual notification.

    Now for the important part: once your notification has been added press Cmd+L in the simulator to lock the screen. After a few seconds have passed the device should wake up with a sound, and show our message – nice!

- **Adding Swift package dependencies in Xcode**

    Everything we’ve been coding so far is stuff we’ve built from scratch, so you can see exactly how it works and apply those skills to your own projects. Sometimes, though, writing something from scratch is risky: perhaps the code is complex, perhaps it’s easy to get wrong, perhaps it changes often, or any other myriad of reasons, which is why ***dependencies* exist – the ability to fetch third-party code and use it in our projects.**

    **Xcode comes with a dependency manager built in, called Swift Package Manager (SPM)**. 

    **You can tell Xcode the URL of some code that’s stored online, and it will download it for you.**

    **You can even tell it what version to download**, which means if the remote code changes sometime in the future you can be sure it won’t break your existing code.

    To try this out, I created a simple Swift package that you can import into any project. This adds a small extension to Swift’s **`Sequence`** type (which **`Array`**, **`Set`**, **`Dictionary`**, and even ranges all conform to) that pulls out a number of random items at the same time.

    Anyway, the first step is to add the package to our project: go to the File menu and choose Swift Packages > Add Package Dependency. For the URL enter [https://github.com/twostraws/SamplePackage](https://github.com/twostraws/SamplePackage), which is where the code for my example package is stored. Xcode will fetch the package, read its configuration, and show you a new screen asking you which version you want to use. 

    The default will be “Version – Up to Next Major”, which is the most common one to use and means if the author of the package updates it in the future then as long as they don’t introduce breaking changes Xcode will update the package to use the new versions.

    The reason this is possible is because most developers have agreed a system of *semantic versioning* (SemVer) for their code. If you look at a version like 1.5.3, then the 1 is considered the major number, the 5 is considered the minor number, and the 3 is considered the patch number. If developers follow SemVer correctly, then they should:

    - Change the patch number when fixing a bug as long as it doesn’t break any APIs or add features.
    - Change the minor number when they added features that don’t break any APIs.
    - Change the *major* number when they *do* break APIs.

    This is why **`“Up to Next Major”`** works so well, because **it should mean you get new bug fixes and features over time, but won’t accidentally switch to a version that breaks your code.**

    Anyway, we’re done with our package, so click Finish to make Xcode add it to the project. You should see it appear in the project navigator, under “Swift Package Dependencies”.

    To try it out, open ContentView.swift and add this import to the top:

    ```swift
    import SamplePackage
    ```

    Yes, **that external dependency is now a module we can import anywhere we need it**.

    And now we can try it in our view. For example, we could simulate a simple lottery by making a range of numbers from 1 through 60, picking 7 of them, converting them to strings, then joining them into a single string. To be concise, this will need some code you haven’t seen before so I’m going to break it down.

    First, replace your current **`ContentView`** with this:

    ```swift
    struct ContentView: View {        
        var body: some View {
            Text(results)
        }
    }
    ```

    Yes, that won’t work because it’s missing **`results`**, but we’re going to fill that in now.

    First, creating a range of numbers from 1 through 60 can be done by adding this property to **`ContentView`**:

    ```swift
    let possibleNumbers = Array(1...60)
    ```

    Second, we’re going to create a computed property called **`results`** that picks seven numbers from there and makes them into a single string, so add this property too:

    ```swift
    var results: String {
        // more code to come
    }
    ```

    Inside there **we’re going to select seven random numbers from our range, which can be done using the extension you got from my SamplePackage framework**. 

    This provides a **`random()`** method that accepts an integer and will return up to that number of random elements from your sequence, in a random order. 

    Lottery numbers are usually arranged from smallest to largest, so we’re going to sort them.

    So, add this line of code in place of **`// more code to come`**:

    ```swift
    let selected = possibleNumbers.random(7).sorted()
    ```

    Next, **we need to convert that array of integers into strings**. This only takes one line of code in Swift, because **sequences have a `map()` method that lets us convert an array of one type into an array of another type by applying a function to each element**. 

    In our case, we want to initialize a new string from each integer, so we can use **`String.init`** as the function we want to call.

    So, add this line after the previous one:

    ```swift
    let strings = selected.map(String.init)
    ```

    At this point **`strings`** is an array of strings containing the seven random numbers from our range, so the last step is to join them all together with commas in between. Add this final line to the property now:

    ```swift
    return strings.joined(separator: ", ")
    ```

    And that completes our code: the text view will show the value inside **`results`**, which will go ahead and pick random numbers, sort them, stringify them, then join them with commas.

    PS: You can read the source code for my simple extension right inside Xcode – just open the Sources > SamplePackage group and look for SamplePackage.swift. You’ll see it doesn’t do much!

    That finishes our final technique required for this project, so please reset your code to its original state.