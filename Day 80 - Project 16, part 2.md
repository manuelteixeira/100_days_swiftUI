# Day 80 - Project 16, part 2

- **Understanding Swift's Result type**

    **It is common to want a function to return some data if it was successful, or return an error if it was unsuccessful**. 

    **We usually model this using throwing functions**, because if the function call succeeds we get data back, but if an error is thrown then our **`catch`** block is run, so we can handle both independently. 

    **But what if the function call *doesn’t* return immediately?**

    We looked at networking code previously, using **`URLSession`**. Let’s look at another example now, adding to the default SwiftUI template code:

    ```swift
    Text("Hello, World!")
        .onAppear {
            let url = URL(string: "https://www.apple.com")!
            URLSession.shared.dataTask(with: url) { data, response, error in
    						if data != nil {
                    print("We got data!")
                } else if let error = error {
                    print(error.localizedDescription)
                }
            }.resume()
        }
    ```

    As soon as the text view loads the network request will start, fetch some data from apple.com, and print one of two messages depending on whether the network request worked or not.

    If you recall, I said **the completion closure will either have `data` or `error` set to a value – it can’t be both, and it can’t be neither, because both those situations don’t make sense.** 

    **However, because `URLSession` doesn’t enforce this constraint for us we need to write code to handle the impossible cases, just to make sure all bases are covered.**

    **Swift has a solution for this confusion, and it’s a special data type called `Result`**. 

    This **gives us the *either/or* behavior we want, while also working great with non-blocking functions** – functions that perform their work asynchronously so they don’t block the main code from running. 

    As a bonus, **it also lets us return specific types of errors**, which makes it easier to know what went wrong.

    The syntax is a little odd at first, which is why I’m warming you up slowly – this stuff is *really* useful, but if you jump in at the deep end it can feel like a step backward.

    What we’re going to do is create a wrapper for our above networking code so that it uses Swift’s **`Result`** type, meaning that you can clearly see the before and after.

    **First we need to define what errors can be thrown.** 

    You can define as many as you want, but here we’ll say that the URL is bad, the request failed, or an unknown error occurred. Put this enum outside the **`ContentView`** struct:

    ```swift
    enum NetworkError: Error {
        case badURL, requestFailed, unknown
    }
    ```

    Next, we’re going to write a method that sends back a **`Result`**. 

    Remember, **`Result`** **is designed to represent some sort of success or failure**, and in this instance we’re going to say that the success case will contain the string of whatever came back from the network, and the error will be some sort of **`NetworkError`**.

    We’re going to write this same method four times in increasing complexity, so you can see how things build up. To start with, we’re just going to send back a **`badURL`** error immediately, which means adding this method to **`ContentView`**:

    ```swift
    func fetchData(from urlString: String) -> Result<String, NetworkError> {
        .failure(.badURL)
    }
    ```

    As you can see, **that method’s return type is `Result<String, NetworkError>`, which is what says it will either be a string on success or a `NetworkError` value on failure**. 

    **This is still a blocking function call**, albeit a very fast one.

    What **we *really* want is a non-blocking call**, which **means we can’t send back our `Result` as a return value**. 

    Instead, **we need to make our method accept two parameters: one for the URL to fetch, and one that is a completion closure that will be called with a value**. 

    **This means the method itself returns nothing; its data is passed back using the completion closure, which is called at some point in the future.**

    Again, we’re just going to make this return a **`.badURL`** failure to keep things simple. Here’s how it looks:

    ```swift
    func fetchData(from urlString: String, completion: (Result<String, NetworkError>) -> Void) {
        completion(.failure(.badURL))
    }
    ```

    Now, **the reason we have a completion closure is that we can now make this method non-blocking: we can kick off some asynchronous work, make the method return so the rest of the code can continue, then call the completion closure at any point later on**.

    There is one small complexity here, and although I’ve mentioned it briefly before now it becomes important. 

    **When we pass a closure into a function, Swift needs to know whether it will be used immediately or whether it might be used later on**. 

    **If it’s used immediately – the default – then Swift is happy to just run the closure. But if it’s used later on, then it’s possible whatever created the closure has been destroyed and no longer exists in memory, in which case the closure would also be destroyed and can no longer be run.**

    To fix this, **Swift lets us mark closure parameters as `@escaping`, which means “this closure might be used outside of the current run of this method, so please keep its memory alive until we’re done.”**

    **In the case of our method, we’re going to run some asynchronous work then call the closure when we’re done. That might happen immediately or it might take a few minutes; we don’t really care**. 

    **The point is that the closure still needs to be around after the method has returned, which means we need to mark it `@escaping`**. 

    If you’re worried about forgetting this, don’t be: Swift will always refuse to build your code unless you add the **`@escaping`** attribute.

    Here’s the third version of our function, which uses **`@escaping`** for the closure so we can call it asynchronously:

    ```swift
    func fetchData(from urlString: String, completion: @escaping (Result<String, NetworkError>) -> Void) {
        DispatchQueue.main.async {
            completion(.failure(.badURL))
        }
    }
    ```

    **Remember, that completion closure can be called at any point in the future and it will still work just as well.**

    And now for our fourth version of the method we’re going to blend our **`Result`** code with the **`URLSession`** code from earlier. This will have the exact same function signature – accepts a string and a closure, and returns nothing – but **now we’re going to call the completion closure in different ways:**

    1. If the URL is bad we’ll call **`completion(.failure(.badURL))`**.
    2. If we get valid data back from our request we’ll convert it to a string then call **`completion(.success(stringData))`**.
    3. If we get an error back from our request we’ll call **`completion(.failure(.requestFailed))`**.
    4. If we somehow don’t get data or an error back then we’ll call **`completion(.failure(.unknown))`**.

    The only new thing there is how to convert a **`Data`** instance to a string. If you recall, you can go the other way using **`let data = Data(someString.utf8)`**, and when converting from **`Data`** to **`String`** the code is somewhat similar:

    ```swift
    let stringData = String(decoding: data, as: UTF8.self)
    ```

    OK, it’s time for the fourth pass of our method:

    ```swift
    func fetchData(from urlString: String, completion: @escaping (Result<String, NetworkError>) -> Void) {
        // check the URL is OK, otherwise return with a failure
        guard let url = URL(string: urlString) else {
            completion(.failure(.badURL))
            return}

        URLSession.shared.dataTask(with: url) { data, response, error in// the task has completed – push our work back to the main thread
            DispatchQueue.main.async {
                if let data = data {
                    // success: convert the data to a string and send it back
                    let stringData = String(decoding: data, as: UTF8.self)
                    completion(.success(stringData))
                } else if error != nil {
                    // any sort of network failure
                    completion(.failure(.requestFailed))
                } else {
                    // this ought not to be possible, yet here we are
                    completion(.failure(.unknown))
                }
            }
        }.resume()
    }
    ```

    I know it took quite a bit of work, but I wanted to explain it step by step because there’s a lot to take in. **What it gives us is a much cleaner API because we can now always be sure that we either get a string or an error – it’s impossible to get both of them or neither of them, because that’s not how `Result` works**. 

    Even better, if we *do* get an error then it must be one of the cases specified in **`NetworkError`**, which makes error handling much easier.

    All we’ve done so far is to write functions that use **`Result`**; we haven’t written anything that *handles* the **`Result`** that got sent back. Remember, regardless of what happens the **`Result`** always carries two pieces of information: the type of result (success or failure), and something inside there. For us, that’s either a string or a **`NetworkError`**.

    Behind the scenes, **`Result`** is actually an enum with an associated value, and Swift has very particular syntax for dealing with these: we can **`switch`** on the **`Result`**, and write cases such as **`case .success(let str)`** to mean “if this was successful, pull out the string inside into a new constant called **`str`**.

    It’s easier to see this all in action, so let’s attach our new method to our **`onAppear`** closure, and handle all possible cases:

    ```swift
    Text("Hello, World!")
        .onAppear {
            self.fetchData(from: "https://www.apple.com") { result in
    						switch result {
                case .success(let str):
                    print(str)
                case .failure(let error):
                    switch error {
                    case .badURL:
                        print("Bad URL")
                    case .requestFailed:
                        print("Network problems")
                    case .unknown:
                        print("Unknown error")
                    }
                }
            }
        }
    ```

    Hopefully now you can see the benefit: not only have we eliminated the uncertainty of checking what was sent back, but we also eliminated optionality entirely. There isn’t even a need for a **`default`** case for the error handling, because all possible cases of **`NetworkError`** are specifically covered.

- **Manually publishing ObservableObject changes**

    **Classes that conform to the `ObservableObject` protocol can use SwiftUI’s `@Published` property wrapper to automatically announce changes to properties, so that any views using the object get their `body` property reinvoked and stay in sync with their data**. 

    That works really well a lot of the time, **but sometimes you want a little more control and SwiftUI’s solution is called `objectWillChange`.**

    **Every class that conforms to `ObservableObject` automatically gains a property called `objectWillChange`**. 

    This **is a *publisher*, which means it does the same job as the `@Published` property wrapper: it notifies any views that are observing that object that something important has changed.** 

    As its name implies, **this publisher should be triggered immediately before we make our change, which allows SwiftUI to examine the state of our UI and prepare for animation changes.**

    To demonstrate this we’re going to build an **`ObservableObject`** class that updates itself 10 times. You already met **`DispatchQueue.main.async()`** as a way of pushing work to the main thread, but here we’re going to use a similar method called **`DispatchQueue.main.asyncAfter()`**. **This lets us specify when the attached closure should be run, which means we can say “do this work after 1 second” rather than “do this work now.”**

    In this test case, we’re going to use **`asyncAfter()`** inside a loop from 1 through 10, so we increment an integer 10 values. 

    That integer will be wrapped using **`@Published`** so change announcements are sent out to any views that are watching it.

    Add this class somewhere in your code:

    ```swift
    class DelayedUpdater: ObservableObject {
        @Published var value = 0

        init() {
            for i in 1...10 {
                DispatchQueue.main.asyncAfter(deadline: .now() + Double(i)) {
                    self.value += 1
                }
            }
        }
    }
    ```

    To use that, we just need to add an **`@ObservedObject`** property in **`ContentView`**, then show the value in our body, like this:

    ```swift
    struct ContentView: View {
        @ObservedObject var updater = DelayedUpdater()

        var body: some View {
            Text("Value is: \(updater.value)")
        }
    }
    ```

    When you run that code you’ll see the value counts upwards until it reaches 10, which is exactly what you’d expect.

    Now, **if you remove the `@Published` property wrapper you’ll see the UI no longer changes.** 

    **Behind the scenes all the `asyncAfter()` work is still happening, but it doesn’t cause the UI to refresh** any more **because no change notifications are being sent out.**

    **We can fix this by sending the change notifications manually using the `objectWillChange` property** I mentioned earlier. 

    **This lets us send the change notification whenever we want, rather than relying on `@Published` to do it automatically**.

    Try changing the **`value`** property to this:

    ```swift
    var value = 0 {
        willSet {
            objectWillChange.send()
        }
    }
    ```

    **Now you’ll get the old behavior back again** – the UI will count to 10 as before. 

    **Except this time we have the opportunity to add extra functionality inside that `willSet` observer**. Perhaps you want to log something, perhaps you want to call another method, or perhaps you want to clamp the integer inside **`value`** so it never goes outside of a range – it’s all under our control now.

- **Controlling image interpolation in SwiftUI**

    **What happens if you make a SwiftUI `Image` view that stretches its content to be larger than its original size?** 

    **By default, we get *image interpolation*, which is where iOS blends the pixels so smoothly you might not even realize they have been stretched at all**. 

    There’s a performance cost to this of course, but most of the time it’s not worth worrying about.

    However, **there is *one* place where image interpolation causes a problem, and that’s when you’re dealing with precise pixels**. 

    As an example, the files for this project on GitHub contain a little cartoon alien image called example@3x.png – it’s taken from the Kenney Platform Art Deluxe bundle at [https://kenney.nl/assets/platformer-art-deluxe](https://kenney.nl/assets/platformer-art-deluxe) and is available under the public domain.

    Go ahead and add that graphic to your asset catalog, then change your **`ContentView`** struct to this:

    ```swift
    Image("example")
        .resizable()
        .scaledToFit()
        .frame(maxHeight: .infinity)
        .background(Color.black)
        .edgesIgnoringSafeArea(.all)
    ```

    **That renders the alien character against a black background to make it easier to see, and because it’s resizable SwiftUI will stretch it up to fill all available space.**

    Take a close **look at the edges of the colors: they look jagged, but also blurry.** 

    The **jagged part comes from the original image because it’s only 66x92 pixels in size, but the *blurry* part is where SwiftUI is trying to blend the pixels as they are stretched to make the stretching less obvious.**

    **Often this blending works great**, but **it struggles here because the source picture is small** (and therefore needs a *lot* of blending to be shown at the size we want), **and also because the image has lots of solid colors so the blended pixels stand out quite obviously.**

    **For situations just like this one, SwiftUI gives us the `interpolation()` modifier that lets us control how pixel blending is applied**. 

    There are multiple levels to this, but realistically we only care about one: **`.none`**. 

    **This turns off image interpolation entirely, so rather than blending pixels they just get scaled up with sharp edges.**

    So, modify your image to this:

    ```swift
    Image("example")
        .interpolation(.none)    
        .resizable()
        .scaledToFit()
        .frame(maxHeight: .infinity)
        .background(Color.black)
        .edgesIgnoringSafeArea(.all)
    ```

    Now you’ll see the alien character **retains its pixellated look**, **which not only is particularly popular in retro games but is also important for line art that would look wrong when blurred.**