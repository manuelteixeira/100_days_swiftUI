# Day 69 - Project 14, part 2

- **Integrating MapKit with SwiftUI**

    **Maps** have been a core feature of iPhone since the very first device shipped way back in 2007, and the underlying **framework** has been available to developers for almost as long. It’s **called MapKit**, and like UIKit it’s available for us to use in SwiftUI if we don’t mind putting in some additional work – and yes, that does mean coordinators.

    Let’s start off with something simple and work our way up. Make a new SwiftUI view called “MapView”, then add an import for MapKit at the top. This time **we’re *not* going to use the protocol `UIViewControllerRepresentable`, because MapKit doesn’t use view controllers**.

    A classic way of building software is called “MVC”, which splits our code into three types of object Model (our data), View (our layouts), and Controller (glue code that connects Model and View). Apple uses MVC in UIKit and its other frameworks, including MapKit, but adds a fun twist: *view controllers*. Are they views, controllers, both, or neither? Apple doesn’t really answer that for us, which is why you’ll see a hundred variations of MVC in iOS app development.

    When I teach UIKit, I start by explaining to folks that a ***view* is one piece of layout, such as some text, a button, or an image**, and **a *view controller* is one screen of content**. 

    **As you progress through your UIKit knowledge you learn that really you can have many view controllers on one screen, but it’s a helpful mental model while you’re learning.**

    All this matters because **when we used `UIImagePickerController` it was designed to work as one full screen of information** – **we didn’t try to add functionality to it, because it was designed to work as one self-contained unit**. 

    In contrast, **MapKit gives us `MKMapView`, and as you can tell from the name this is a *view* not a *controller***, which means it just shows content we provide to it.

    This is why we don’t use **`UIViewControllerRepresentable`** when working with MapKit: `**MKMapView` uses a view, and so we need to use `UIViewRepresentable` instead**. 

    Helpfully **this works almost identically: we need to write methods called `makeUIView()` and `updateUIView()`, that handle instantiating a map view and updating it as our SwiftUI state changes.** 

    However, that *update* method is much more important for views than view controllers, because there’s a lot more cross-talk between SwiftUI code and **`UIView`** objects – whereas we left that method empty for view controllers, you’ll be using it a lot for views.

    We’ll come back to updating soon, but for now we’ll use another empty method. As for the *make* method, this will make a new **`MKMapView`** and send it back – we’ll be adding more to this soon, but you’ve had enough chat now and I’m sure you’re keen to get moving!

    Replace your current **`MapView`** struct with this:

    ```swift
    struct MapView: UIViewRepresentable {
        func makeUIView(context: UIViewRepresentableContext<MapView>) -> MKMapView {
            let mapView = MKMapView()
            return mapView
        }

        func updateUIView(_ view: MKMapView, context: UIViewRepresentableContext<MapView>) {
        }
    }
    ```

    Before we move on, I want to show you a teensy bit of Swift magic. Back in project 13 when I introduced you to the **`UIViewControllerRepresentable`** protocol, we used **`typealias`** just briefly. **This is Swift’s way of letting us create new names for existing types, which is usually done to make them easier to remember.**

    Well, **both `UIViewControllerRepresentable` and `UIViewRepresentable` both include type aliases built into them**. If you right-click on **`UIViewRepresentable`** and choose Jump To Definition you’ll see the generated interface for SwiftUI, and it should also show you this line inside the **`UIViewRepresentable`** protocol:

    ```swift
    typealias Context = UIViewRepresentableContext<Self>
    ```

    **That creates a new typealias – a type name – called “Context”, and wherever Swift sees `Context` in code it will consider it the same as `UIViewRepresentableContext<Self>`, where `Self` is whatever type we’re working with**. 

    In practical terms, **this means we can just write `Context` rather than `UIViewRepresentableContext<MapView>`**, and they mean *exactly* the same thing.

    Anyway, we’ve built the first version of our map view, so we can go ahead and use it. Go back to ContentView.swift and replace the text view with this:

    ```swift
    MapView()
        .edgesIgnoringSafeArea(.all)
    ```

    Xcode doesn’t do a great job of previewing map views right now, so I suggest you run the app in the simulator to see how it looks. You should find you can tap and drag the map around, but if you hold down the Option key you’ll see a second virtual finger appear so you and pinch and rotate freely. Not bad for only a handful of lines of code!

    Of course, what you *really* want to do is bring the map to life with some place marks, so we’ll tackle that next…

- **Communicating with a MapKit coordinator**

    It’s trivial to embed an empty **`MKMapView`** into SwiftUI, but **if you want to do anything *useful* with the map then you need to introduce a coordinator** – **a class that can act as the delegate for your map view, passing data to and from SwiftUI.**

    Just like working with **`UIImagePickerController`**, **this means creating a nested class that inherits from `NSObject`, making it conform to whatever delegate protocol our view or view controller works with**, and **giving it a reference to the parent struct** so it can pass data back up to SwiftUI.

    For map views, the protocol we care about is **`MKMapViewDelegate`**, so we can start writing a coordinator class immediately. Add this as a nested class inside **`MapView`**:

    ```swift
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView

        init(_ parent: MapView) {
            self.parent = parent
        }
    }
    ```

    With that class in place our code will stop compiling, because SwiftUI can see we’ve got a coordinator class and wants to know how it should be created.

    Just as with the **`UIViewControllerRepresentable`** protocol, that means **adding a method called `makeCoordinator()` that sends back a configured instance of our `Coordinator`**. 

    This should be added to the **`MapView`** struct, and **it will send itself to the coordinator so it can report back what’s happening**.

    So, add this method to **`MapView`** now:

    ```swift
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    ```

    We can now **connect that to our `MKMapView`** by adding this line of code to the **`makeUIView()`** method:

    ```swift
    mapView.delegate = context.coordinator
    ```

    That completes our configuration, which means **we can now start adding methods that make our coordinator respond to activity in the map view**. 

    Remember, our coordinator is the delegate of the map view, which means when something interesting happens it gets notified – when the map moves, when it starts and finishes loading, when the user was located on the map, when a map pin was touched, and so on.

    **MapKit automatically examines our coordinator class to see which one of those notifications we want to be told about.** 

    It **does this using function signatures**: if it finds a method with a precise name and parameter list, it will call that.

    To demonstrate this, we’re going to add a method called **`mapViewDidChangeVisibleRegion()`** that takes a single **`MKMapView`** parameter. Yes, this method name *is* very long, but trust me there are many longer out there in UIKit – my personal favorite got deprecated way back in iOS 5.0, and was called **`willAnimateSecondHalfOfRotationFromInterfaceOrientation()`**!

    Anyway, add this method to the **`Coordinator`** class now:

    ```swift
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        print(mapView.centerCoordinate)
    }
    ```

    **That will be called whenever the map view changes its visible region, which means when it moves, zooms, or rotates**. 

    All we’ve made it do is print the new center coordinate, so when you run the app back in the simulator you should see lots of coordinates being printed in the Xcode output window.

    Map view coordinators are also responsible for providing more information when the map view needs it. For example, **we can add annotations to a map, which act as points of interest that we want users to interact with**. 

    This is *model* data, meaning that it’s just a title and some coordinates as opposed to a visual representation of that data, and so when the map view wants to *render* our annotations it will ask the coordinator what should be shown.

    To demonstrate this, we’re going to modify the **`makeUIView()`** method so that we send in an annotation for the city of London, like this:

    ```swift
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator

        let annotation = MKPointAnnotation()
        annotation.title = "London"
        annotation.subtitle = "Capital of England"
        annotation.coordinate = CLLocationCoordinate2D(latitude: 51.5, longitude: 0.13)
        mapView.addAnnotation(annotation)

        return mapView
    }
    ```

    **`MKPointAnnotation`** **is a class that conforms to the `MKAnnotation` protocol, which is what MapKit uses to display annotations**. 

    **You can create your own annotation types** if you want, but **`MKPointAnnotation`** is good enough here because it lets us provide a title, subtitle, and coordinate. If you were curious, the name **`CLLocationCoordinate2D`** starts with “CL” because it comes from another Apple framework called Core Location.

    Anyway, that adds an annotation to our map, and with no further work you should be able to run the app again, then scroll around until you find London – you should see a marker there that can be tapped to reveal our subtitle.

    **If you want to customize the way that marker looks, we need to bring our coordinator back into play.** **The map view will look in our coordinator for a particular method called `mapView(_:viewFor:)`, and it will be called if it exists**. 

    **This can create a custom annotation view,** but again **Apple gives us a neat alternative in the form of `MKPinAnnotationView`**.

    Add this code to the **`Coordinator`** class:

    ```swift
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: nil)
        view.canShowCallout = true
        return view
    }
    ```

    As you can see, **that method gets handed a map view and an annotation, and must return the correct view to use to display that annotation**. 

    In our code, **we use that to create an instance of `MKPinAnnotationView`, passing it the annotation it should work with, we then set `canShowCallout` to true so that tapping the pin shows information, then send it back.**

    Before we finish up with maps for now, I want to briefly mention that **`reuseIdentifier`** property. 

    **Creating views is *expensive***, which is why SwiftUI has things like the `**Identifiable**` protocol – **if it can identify its views uniquely** then it can tell which ones have changed and which haven’t, which means it minimizes the amount of work it needs to do.

    **Frameworks such as UIKit and MapKit has a simpler version of the same concept, called *reuse identifiers*.** 

    These **are strings that can be anything we want, and allow the framework to keep a big array of views ready to be reused**. 

    **We can ask for one with a specific ID** – “give me a pin with the identifier Placemark” – **and get one back from the array ready to be used, which means we don’t need to create it again.**

    **We specified `nil` as the reuse identifier above, which means we don’t want to reuse views.** 

    This is fine when you’re just learning – and realistically at any time when you’re only going to use a handful of pins – but later on I’ll be showing you the more efficient route here, which means reusing views.

- **Using Touch ID and Face ID with SwiftUI**

    **The vast majority of Apple’s devices come with biometric authentication as standard, which means they use fingerprint and facial recognition to unlock**. 

    This functionality is available to us too, which means we can make sure that sensitive data can only be read when unlocked by a valid user.

    **This is another Objective-C API**, but it’s only a *little* bit unpleasant to use with SwiftUI, which is better than we’ve had with some other frameworks we’ve looked at so far.

    Before we write any code, **you need to add a new key to your Info.plist file**, **explaining to the user why you want access to Face ID**. 

    **For reasons known only to Apple, we pass the Touch ID request reason in code, and the Face ID request reason in Info.plist.**

    Open Info.plist now, right-click on some space, then choose Add Row. Scroll through the list of keys until you find “Privacy - Face ID Usage Description” and give it the value “We need to unlock your data.”

    Now head back to ContentView.swift, and add this import near the top of the file:

    ```swift
    import LocalAuthentication
    ```

    OK, we’re all set to use biometrics. I mentioned earlier this was “only a *little* bit unpleasant”, and here’s where it comes in: **Swift developers use the `Error` protocol for representing errors that occur at runtime, but Objective-C uses a special class called `NSError`**. 

    Because this is an Objective-C API **we need to use `NSError` to handle problems, and pass it using `&` like a regular `inout` parameter**.

    We’re going to **write an `authenticate()` method that isolates all the biometric functionality in a single place**. To make that happen requires four steps:

    1. **Create instance of** **`LAContext`**, which **allows us to query biometric status** **and perform the authentication check.**
    2. **Ask that context whether it’s capable of performing biometric authentication** – this is important because iPod touch has neither Touch ID nor Face ID.
    3. **If biometrics are possible, then we kick off the actual request for authentication**, passing in a closure to run when authentication completes.
    4. **When the user has either been authenticated or not, our completion closure will be called and tell us whether it worked or not**, and if not what the error was. **This closure will get called away from the main thread, so we need to push any UI-related work back to the main thread.**

    Please go ahead and add this method to **`ContentView`**:

    ```swift
    func authenticate() {
        let context = LAContext()
        var error: NSError?

        // check whether biometric authentication is possible
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            // it's possible, so go ahead and use it
            let reason = "We need to unlock your data."

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in// authentication has now completed
                DispatchQueue.main.async {
                    if success {
                        // authenticated successfully
                    } else {
                        // there was a problem
                    }
                }
            }
        } else {
            // no biometrics
        }
    }
    ```

    That method by itself won’t do anything, because it’s not connected to SwiftUI at all. To fix that **we need to do add some state we can adjust when authentication is successful, and also an `onAppear()` modifier to trigger authentication.**

    So, first add this property to **`ContentView`**:

    ```swift
    @State private var isUnlocked = false
    ```

    That simple Boolean will store whether the app is showing its protected data or not, so we’ll flip that to true when authentication succeeds. Replace the **`// authenticated successfully`** comment with this:

    ```swift
    self.isUnlocked = true
    ```

    Finally, we can show the current authentication state and begin the authentication process inside the **`body`** property, like this:

    ```swift
    VStack {
        if self.isUnlocked {
            Text("Unlocked")
        } else {
            Text("Locked")
        }
    }
    .onAppear(perform: authenticate)
    ```

    If you run the app there’s a good chance you just see “Locked” and nothing else. This is because the simulator isn’t opted in to biometrics by default, and we didn’t provide any error messages, so it fails silently.

    To take Face ID for a test drive, go to the Hardware menu and choose Face ID > Enrolled, then launch the app again. This time you should see the Face ID prompt appear, and you can trigger successful or failed authentication by going back to the Hardware menu and choosing Face ID > Matching Face or Non-matching Face.

    All being well you should see the Face ID prompt go away, and underneath it will be the “Unlocked” text view – our app has detected the authentication, and is now open to use.