# Day 72 - Project 14, part 5

- **Making someone else's class conform to Codable**

    Any app that asks the user to enter data usually works better when it *stores* the data it was given, but this is easier said than done when working with Apple’s frameworks.

    In our app **we’re using `MKPointAnnotation` to store interesting places the user wants to visit, and we’d like to use the iOS storage to save it permanently**. Create a new Swift file called MKPointAnnotation-Codable.swift, add an import for MapKit, then give it this code:

    ```swift
    extension MKPointAnnotation: Codable {
        public required init(from decoder: Decoder) throws {

        }

        public func encode(to encoder: Encoder) throws {

        }
    }
    ```

    That’s a custom conformance to **`Codable`**, but it doesn’t do anything. However, it already doesn’t work: **if you try building you’ll see the error “'required' initializer must be declared directly in class 'MKPointAnnotation' (not in an extension)”.**

    Let me get right to the point: there is no way of making this work in Swift.

    It’s not *required* that you understand why this is impossible, but I do think it sheds some light on how Swift works.

    **`MKPointAnnotation`** **isn’t a final class, which means other classes can inherit from it**. 

    **We might be able to implement `Codable` conformance for this one class, but in doing so we’re also saying that all subclasses should also be `Codable` and that’s not a promise we can keep.**

    There are a few **solutions** to this:

    - **`MKPointAnnotation`** **is a class that implements the `MKAnnotation` protocol, so we could just create our own class that conforms to the same protocol**.
    - **We could create a subclass of `MKPointAnnotation` and implement `Codable` there**, effectively shielding the **`MKPointAnnotation`** from any knowledge that **`Codable`** is being used. This is now *our* class so we *can* force subclasses to conform to **`Codable`**.
    - **We could create a wrapper struct around the class, making the struct conform to `Codable` and store an `MKPointAnnotation` internally**.

    **All three of those are good options**, and you can easily make a case that any of them are the *right* option here. However, the ***easiest* option is the subclass, because we can implement it in a single file, then change only two instances of `MKPointAnnotation` to make it work with the rest of our code.**

    First, the code. We’re going to **create a new class called `CodableMKPointAnnotation` that inherits from `MKPointAnnotation` and conforms to `Codable`**. 

    We do need to provide a custom **`Codable`** implementation so that all our data gets saved, and that’s mostly straightforward – the only wrinkle is that **`CLLocationCoordinate2D`** **doesn’t already conform to `Codable`, so we’ll save it as latitude and longitude.**

    Other than that there’s nothing special here, so replace whatever you have in MKPointAnnotation-Codable.swift with this:

    ```swift
    class CodableMKPointAnnotation: MKPointAnnotation, Codable {
        enum CodingKeys: CodingKey {
            case title, subtitle, latitude, longitude
        }

        override init() {
            super.init()
        }

        public required init(from decoder: Decoder) throws {
            super.init()

            let container = try decoder.container(keyedBy: CodingKeys.self)
            title = try container.decode(String.self, forKey: .title)
            subtitle = try container.decode(String.self, forKey: .subtitle)

            let latitude = try container.decode(CLLocationDegrees.self, forKey: .latitude)
            let longitude = try container.decode(CLLocationDegrees.self, forKey: .longitude)
            coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(title, forKey: .title)
            try container.encode(subtitle, forKey: .subtitle)
            try container.encode(coordinate.latitude, forKey: .latitude)
            try container.encode(coordinate.longitude, forKey: .longitude)
        }
    }
    ```

    The **`MKPointAnnotation`** class is used in several places around our project, but we only need to change it in two places. First, change the **`locations`** property in **`ContentView`** to this:

    ```swift
    @State private var locations = [CodableMKPointAnnotation]()
    ```

    And now change the action of the + button in **`ContentView`** so that **`newLocation`** also uses our new subclass:

    ```swift
    let newLocation = CodableMKPointAnnotation()
    ```

    **We don’t need to change the other places because `CodableMKPointAnnotation` is a subclass of `MKPointAnnotation`, which means any place we use an `MKPointAnnotation` we can send in a `CodableMKPointAnnotation`**. 

    This is technically **known as *behavioral subtyping***, but you’ll more commonly hear it called the ***Liskov Substitution Principle*** after its creator, Barbara Liskov. If you’ve ever heard the term “SOLID”, this is the “L”!

    Anyway, where things get interesting is **how we load and save the data, because this time we’re not going to use `UserDefaults`**. Instead, **we’re going to write our JSON to the iOS filesystem, so we can write as much data as we need**.

    Previously I showed you how to find our app’s documents directory, so start by adding this method to **`ContentView`**:

    ```swift
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    ```

    With that in place, we can now using **`getDocumentsDirectory().appendingPathComponent()`** **to create new URLs that point to a specific file in the documents directory**. 

    Once we have that, it’s as **simple as using `Data(contentsOf:)` and `JSONDecoder()` to load our data** – both things we’ve used before.

    So, add this **`loadData()`** method to **`ContentView`**:

    ```swift
    func loadData() {
        let filename = getDocumentsDirectory().appendingPathComponent("SavedPlaces")

        do {
            let data = try Data(contentsOf: filename)
            locations = try JSONDecoder().decode([CodableMKPointAnnotation].self, from: data)
        } catch {
            print("Unable to load saved data.")
        }
    }
    ```

    Using this approach we can write any amount of data in any number of files – it’s much more flexible than **`UserDefaults`**, and if we need **it also allows us to load and save data as needed rather than immediately when the app launches as with `UserDefaults`**.

    However, **another benefit of this approach is the way we *write* stuff**. Sure, we’re going to use the same **`getDocumentsDirectory()`** and **`JSONEncoder`** dance to get our data ready, but this time **we’re going to use the `write(to:)` method to save the data to disk, writing to a particular URL.**

    Previously I showed you this method with strings, but the **`Data`** version is even better because it lets us do something quite amazing in just one line of code: **we can ask iOS to ensure the file is written with encryption so that it can only be read once the user has unlocked their device.** This is in *addition* to requesting atomic writes – iOS does almost all the work for us.

    Add this method to **`ContentView`** now:

    ```swift
    func saveData() {
        do {
            let filename = getDocumentsDirectory().appendingPathComponent("SavedPlaces")
            let data = try JSONEncoder().encode(self.locations)
            try data.write(to: filename, options: [.atomicWrite, .completeFileProtection])
        } catch {
            print("Unable to save data.")
        }
    }
    ```

    Yes, all it takes to ensure that the file is stored with strong encryption is to add **`.completeFileProtection`** to the data writing options.

    After all that work, the last thing we need to do is actually connect those methods up to SwiftUI, so that everything gets automatically loaded and saved.

    For loading data, we just need to add an **`onAppear()`** modifier to the **`ZStack`** in **`ContentView`**:

    ```swift
    .onAppear(perform: loadData)
    ```

    For *saving*, **we can use the same `onDismiss` parameter for `sheet()`** that was introduced back in project 13. This means **we save the data every time `EditView` is dismissed**, which means we save new items as well as edited items.

    So, change the **`sheet()`** modifier in **`ContentView`** to this:

    ```swift
    .sheet(isPresented: $showingEditScreen, onDismiss: saveData) {
    ```

    Go ahead and run the app now, and you should find that you can add items freely, then relaunch the app to see them restored just as they were.

    That took quite a bit of code in total, but the end result is that we have loading and saving done really well:

    - The **`Codable`** conformance is all isolated in one file, so SwiftUI doesn’t have to care about it.
    - When we write data we’re making iOS encrypt it so the file can’t be read or written until the user unlocks their device.
    - The load and save process is almost transparent – we added one modifier and changed another, and that’s all it took.

    Of course, our app isn’t truly secure yet: we’ve ensured our data file is saved out using encryption so that it can only be read once the device has been unlocked, but there’s nothing stopping someone else from reading the data afterwards.

- **Locking our UI behind Face ID**

    To finish off our app, we’re going to make one last important change: we’re going to r**equire the user to authenticate themselves using either Touch ID or Face ID in order to see all the places they have marked on the app**. After all, this is their private data and we should be respectful of that, and of course it gives me a chance to let you use an important skill in a practical context!

    First **we need some new state in `ContentView` that tracks whether the app is unlocked** or not. So, start by adding this new property:

    ```swift
    @State private var isUnlocked = false
    ```

    Second, we need to **add the “Privacy - Face ID Usage Description” key to Info.plist**, explaining to the user why we want to use Face ID. You can enter what you like, but “Please authenticate yourself to unlock your places” seems like a good choice.

    Third, we need to **add `import LocalAuthentication`** to the top of ContentView.swift, **so we have access to Apple’s authentication framework.**

    And now for the hard part. If you recall, the code for biometric authentication was a teensy bit unpleasant because of its Objective-C roots, so it’s always a good idea to get it far away from the neatness of SwiftUI. So, **we’re going to write a dedicated `authenticate()` method that handles all the biometric work**:

    1. **Creating an `LAContext` so we have something that can check and perform biometric authentication.**
    2. **Ask it whether the current device is capable of biometric authentication**.
    3. If it is, **start the request and provide a closure to run when it completes**.
    4. **When the request finishes, push our work back to the main thread** and check the result.
    5. If it was successful, we’ll **set `isUnlocked` to true** so we can run our app as normal.

    Add this method to **`ContentView`** now:

    ```swift
    func authenticate() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Please authenticate yourself to unlock your places."

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError inDispatchQueue.main.async {
                    if success {
                        self.isUnlocked = true
                    } else {
                        // error
                    }
                }
            }
        } else {
            // no biometrics
        }
    }
    ```

    Remember, the **string in our code is used for Touch ID**, whereas the **string in Info.plist is used for Face ID.**

    And now we need to make an adjustment that is in reality very small, but can be hard to visualize if you’re reading this rather than watching the video. **Everything inside the `ZStack` needs to be indented in by one level, and have this placed before it**:

    ```swift
    if isUnlocked {
    ```

    Just before the end of the **`ZStack`** add this:

    ```swift
    } else {
        // button here
    }
    ```

    So, it should look something like this:

    ```swift
    ZStack {
        if isUnlocked {
            MapView…
            Circle…
            VStack…
        } else {
            // button here
        }
    }
    .alert(isPresented: $showingPlaceDetails) {
    ```

    So now we all we need to do is fill in the **`// button here`** comment with an actual **button that triggers the `authenticate()` method**. You can design whatever you want, but something like this ought to be enough:

    ```swift
    Button("Unlock Places") {
        self.authenticate()
    }
    .padding()
    .background(Color.blue)
    .foregroundColor(.white)
    .clipShape(Capsule())
    ```

    You can now go ahead and run the app again, because our code is done. If this is the first time you’ve used Face ID in the simulator you’ll need to go to the Hardware menu and choose Face ID > Enrolled, but once you relaunch the app you can authenticate using Hardware > Face ID > Matching Face.

    That’s another app done – good job!