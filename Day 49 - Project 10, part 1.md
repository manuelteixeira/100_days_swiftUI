# Day 49 - Project 10, part 1

- **Adding Codable conformance for @Published properties**

    If all the properties of a type already conform to **`Codable`**, then the type itself can conform to **`Codable`** with no extra work 

    – Swift will synthesize the code required to archive and unarchive your type as needed. 

    However, **this *doesn’t* work when we use property wrappers such as `@Published`**, which means conforming to **`Codable`** requires some extra work on our behalf.

    To fix this, we need to implement **`Codable`** conformance ourself. 

    This will fix the **`@Published`** encoding problem, but is also a valuable skill to have elsewhere too because it lets us control exactly what data is saved and how it happens.

    First let’s create a simple type that recreates the problem. Add this class to ContentView.swift:

    ```swift
    class User: ObservableObject, Codable {
        var name = "Paul Hudson"
    }
    ```

    **That will compile just fine, because `String` conforms to `Codable` out of the box**. However, **if we make it `@Published` then the code no longer compiles:**

    ```swift
    class User: ObservableObject, Codable {
        @Published var name = "Paul Hudson"
    }
    ```

    The **`@Published`** property wrapper isn’t magic – **the name *property wrapper* comes from the fact that our `name` property is automatically wrapped inside another type that adds some additional functionality**. 

    **In the case of `@Published` that’s a struct called `Published` that can store any kind of value.**

    Previously we looked at how we can write generic methods that work with any kind of value, and the **`Published`** struct takes that a step further: **the whole type itself is generic, meaning that you can’t make an instance of `Published` all by itself, but instead make an instance of `Published<String>` – a publishable object that contains a string.**

    If that sounds confusing, back up: it’s actually a fairly fundamental principle of Swift, and one you’ve been working with for some time. 

    Think about it – **we can’t say `var names: Set`, can we? Swift doesn’t allow it; Swift wants to know what’s *in* the set.** 

    **This is because `Set` is also a generic type**: you must make an instance of **`Set<String>`**. 

    The same is also true of arrays and dictionaries: we always make them have something specific inside.

    Swift already has rules in place that say if an array contains **`Codable`** types then the whole array is **`Codable`**, and the same for dictionaries and sets. However, **SwiftUI *doesn’t* provide the same functionality for its `Published` struct – it has no rule saying “if the published object is `Codable`, then the published struct itself is also `Codable`.”**

    As a result, **we need to make the type conform ourselves**: we need to tell Swift which properties should be loaded and saved, and how to do both of those actions.

    None of those steps are terribly hard, so let’s just dive in with **the first one: telling Swift which properties should be loaded and saved. This is done using an enum that conforms to a special protocol called `CodingKey`, which means that every case in our enum is the name of a property we want to load and save.** 

    **This enum is conventionally called `CodingKeys`**, with an S on the end, but you can call it something else if you want.

    So, our **first step is to create a `CodingKeys` enum that conforms to `CodingKey`, listing all the properties we want to archive and unarchive**. 

    Add this inside the **`User`** class now:

    ```swift
    enum CodingKeys: CodingKey {
        case name
    }
    ```

    **The next task is to create a custom initializer that will be given some sort of container, and use that to read values for all our properties.** 

    This will involve learning a few new things, but let’s look at the code first – add this initializer to **`User`** now:

    ```swift
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
    }
    ```

    Even though that isn’t much code, there are at least four new things in there.

    **First**, **this initializer is handed an instance of a new type called `Decoder`. This contains all our data, but it’s down to us to figure out how to read it.**

    **Second**, **anyone who subclasses our `User` class must override this initializer with a custom implementation to make sure they add their own values**. 

    **We mark this using the `required` keyword**: **`required init`**. 

    **An alternative is to mark this class as `final` so that subclassing isn’t allowed**, in which case we’d write **`final class User`** and drop the **`required`** keyword entirely.

    **Third**, **inside the method we ask our `Decoder` instance for a container matching all the coding keys we already set in our `CodingKey` struct by writing `decoder.container(keyedBy: CodingKeys.self)`**. 

    This means “this data should have a container where the keys match whatever cases we have in our **`CodingKeys`** enum. This is a throwing call, because it’s possible those keys don’t exist.

    **Finally**, **we can read values directly from that container by referencing cases in our enum** – **`container.decode(String.self, forKey: .name)`**. 

    **This provides really strong safety in two ways**: 

    - **we’re making it clear we expect to read a string**, so if **`name`** gets changed to an integer the code will stop compiling;
    - and **we’re also using a case in our `CodingKeys` enum rather than a string**, so there’s no chance of typos.

    There’s one more task we need to complete before the **`User`** class conforms to **`Codable`**: we’ve made an initializer so that Swift can *decode* data into this type, but now we need to tell Swift how to *encode* this type – how to archive it ready to write to JSON.

    This step is pretty much the reverse of the initializer we just wrote: 

    **we get handed an `Encoder` instance to write to, ask it to make a container using our `CodingKeys` enum for keys, then write our values attached to each key.**

    Add this method to the **`User`** class now:

    ```swift
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
    }
    ```

    And now our code compiles: Swift knows what data we want to write, knows how to convert some encoded data into our object’s properties, and knows how to convert our object’s properties into some encoded data.

    I hope you’re able to see some real advantages here compared to the stringly typed API of **`UserDefaults`** – it’s much harder to make a mistake with **`Codable`** because we don’t use strings, and it automatically checks our data types are correct.

- **Sending and receiving Codable data with URLSession and SwiftUI**

    iOS gives us built-in tools for sending and receiving data from the internet, and if we combine it with **`Codable`** support then it’s possible to convert Swift objects to JSON for sending, then receive back JSON to be converted back to Swift objects. Even better, when the request completes we can immediately assign its data to properties in SwiftUI views, causing our user interface to update.

    To demonstrate this we can load some example music JSON data from Apple’s iTunes API, and show it all in a SwiftUI **`List`**. 

    Apple’s data includes lots of information, but we’re going to whittle it down to just two types: a **`Result`** will store a track ID, its name, and the album it belongs to, and a **`Response`** will store an array of results.

    So, start with this code:

    ```swift
    struct Response: Codable {
        var results: [Result]
    }

    struct Result: Codable {
        var trackId: Int
        var trackName: String
        var collectionName: String
    }
    ```

    We can now write a simple **`ContentView`** that shows an array of results:

    ```swift
    struct ContentView: View {
        @State private var results = [Result]()

        var body: some View {
            List(results, id: \.trackId) { item inVStack(alignment: .leading) {
                    Text(item.trackName)
                        .font(.headline)
                    Text(item.collectionName)
                }
            }
        }
    }
    ```

    That won’t show anything at first, because the **`results`** array is empty. 

    This is where our networking call comes in: **we’re going to ask the iTunes API to send us a list of all the songs by Taylor Swift, then use `JSONDecoder` to convert those results into an array of `Result` instances.**

    To make this easier to understand, let’s write it in a few stages. First, here’s the basic method stub – please add this to the **`ContentView`** struct:

    ```swift
    func loadData() {

    }
    ```

    **We want that to be run as soon as our `List` is shown**, so you should add this modifier to the **`List`**:

    ```swift
    .onAppear(perform: loadData)
    ```

    *Inside* **`loadData()`** **we have four steps we need to complete**:

    1. **Creating the URL we want to read**.
    2. **Wrapping that in a `URLRequest`**, which allows us to configure *how* the URL should be accessed.
    3. **Create and start a networking task from that URL request**.
    4. **Handle the result of that networking task**.

    We’ll add those step by step, **starting with the URL.** 

    **This needs to have a precise format**: “itunes.apple.com” followed by a series of parameters – you can find the full set of parameters if you do a web search for “iTunes Search API”. In our case we’ll be using the search term “Taylor Swift” and the entity “song”, so add this to **`loadData()`** now:

    ```swift
    guard let url = URL(string: "https://itunes.apple.com/search?term=taylor+swift&entity=song") else {
        print("Invalid URL")
        return}
    ```

    **Next we need to wrap that `URL` into a `URLRequest`**. 

    Again, **this is where we would add different customizations to control the way the URL was loaded, but here we don’t need anything so this is just a single line of code** – add this to **`loadData()`** next:

    ```swift
    let request = URLRequest(url: url)
    ```

    **Step 3 is to create and start a networking task with the `URLRequest` we just made**. 

    This can feel like a fairly odd approach when you first see it, and it has a particularly common “gotcha” – a mistake you’ll make again and again, and probably still will make in a few years.

    I’ll show you the code first, then explain what it does – add this to **`loadData()`**:

    ```swift
    URLSession.shared.dataTask(with: request) { data, response, error in// step 4
    }.resume()
    ```

    **`URLSession`** **is the iOS class responsible for managing network requests.** 

    **You can make your own session if you want to, but it’s very common to use the `shared` session that iOS creates for us to use** – **unless you need some specific behavior, using the shared session is fine.**

    **Our code then calls `dataTask(with:)` on that shared session, which creates a networking task from a `URLRequest` and a closure that should be run when the task completes**. 

    **In our code that’s provided using trailing closure synta**x, and as you can see **it accepts three parameters:**

    - **`data`** is **whatever data was returned from the request**.
    - **`response`** is a **description of the data**, **which might include what type of data it is, how much was sent, whether there was a status code, and more.**
    - **`error`** is **the error that occurred.**

    Now, cunningly **some of those properties are mutually exclusive**, by which I mean that **if an error occurred then `data` won’t be set**, **and** i**f `data` was sent back then `error` won’t be set**. 

    This strange state of affairs exists because the **`URLSession`** API was made before Swift came along, so there was no nicer way of representing this either-or state.

    **Notice the way we call `resume()` on the task straight away?** That’s the gotcha – that’s the thing you’ll forget time and time again. **Without it the request does nothing and you’ll be staring at a blank screen.** But ***with* it the request starts immediately, and control gets handed over to the system** – **it will automatically run in the background, and won’t be destroyed even after our method ends.**

    **When the request finishes, successfully or not, step 4 kicks in – that’s the closure inside the data task**, and is responsible for doing something with the data or error. 

    **In our case we’re going to check whether the data was set, and if it was try to decode it into an instance of our `Response` struct** because that’s what the iTunes API sends back. **We don’t actually want the whole response, just the results array inside it so that our `List` will show them all.**

    However, there’s **another catch** here: **`URLSession`** **automatically runs in the background, which means its completion closure will also be run in the background**. 

    By “background” I mean what’s technically known as a *background thread* – an independent piece of code that’s running at the same time as the rest of our program. 

    This **means the network request can be running, and even take a few seconds, without stopping our UI from being interactive.**

    **iOS likes to have all its user interface work done on what’s called the *main thread***, which is the one where the program was started. 

    This stops two pieces of code trying to manipulate the user interface simultaneously, because if all UI-related work takes place on the main thread then it can’t clash.

    We want to change the **`results`** property of our view to be whatever was downloaded through the iTunes API, which in turn will update our user interface. 

    That might work great on a background thread because SwiftUI is super smart, but honestly it’s just not worth the risk – **it’s a much better idea to fetch your data in the background, decode it from JSON in the background, then actually update the property on the main thread to avoid any potential for problems.**

    **iOS gives us a very particular way of sending work to the main thread: `DispatchQueue.main.async()`.** 

    This **takes a closure of work to perform, and sends it off to the main thread for execution**. 

    As you can see from its name, what’s actually happening is that it’s added to a *queue* – a big line of work that’s waiting for execution. The “async” part is short for “asynchronous”, which means our own background work won’t wait for the closure to be run; we just add it to the queue and carry on working in the background.

    So, put this final code in place of the **`// step 4`** comment:

    ```swift
    if let data = data {
        if let decodedResponse = try? JSONDecoder().decode(Response.self, from: data) {
            // we have good data – go back to the main thread
            DispatchQueue.main.async {
                // update our UI
                self.results = decodedResponse.results
            }

            // everything is good, so we can exit
            return}
    }

    // if we're still here it means there was a problem
    print("Fetch failed: \(error?.localizedDescription ?? "Unknown error")")
    ```

    **That last `print()` line uses optional chaining and the nil coalescing operator to make sure an error is printed if it exists, otherwise give a generic error.**

    If you run the code now you should see a list of Taylor Swift songs appear after a short pause – it really isn’t a lot of code given how well the end result works.

    Later on in this project we’re going to look at how to customize **`URLRequest`** so you can *send* **`Codable`** data, but that’s enough for now – please put ContentView.swift back to its original state so we can begin work.

- **Validating and disabling forms**

    SwiftUI’s **`Form`** **view lets us store user input in a really fast and convenient way**, but sometimes it’s important to go a step further – **to *check* that input to make sure it’s valid before we proceed.**

    Well, **we have a modifier just for that purpose: `disabled()`**. 

    This **takes a condition to check, and if the condition is true then whatever it’s attached to won’t respond to user input** – buttons can’t be tapped, sliders can’t be dragged, and so on. 

    **You can use simple properties here, but any condition will do: reading a computed property, calling a method, and so on,**

    To demonstrate this, here’s a form that accepts a username and email address:

    ```swift
    struct ContentView: View {
        @State private var username = ""
        @State private var email = ""

        var body: some View {
            Form {
                Section {
                    TextField("Username", text: $username)
                    TextField("Email", text: $email)
                }

                Section {
                    Button("Create account") {
                        print("Creating account…")
                    }
                }

            }
        }
    }
    ```

    In this example, **we don’t want users to create an account unless both fields have been filled in**, so we can disable the form section containing the Create Account button by adding the **`disabled()`** modifier like this:

    ```swift
    Section {
        Button("Create account") {
            print("Creating account…")
        }
    }
    .disabled(username.isEmpty || email.isEmpty)
    ```

    **That means “this section is disabled if username is empty or email is empty,” which is exactly what we want.**

    **You might find that it’s worth spinning out your conditions into a separate computed property**, such as this:

    ```swift
    var disableForm: Bool {
        username.count < 5 || email.count < 5
    }
    ```

    Now **you can just reference that in your modifier**:

    ```swift
    .disabled(disableForm)
    ```

    Regardless of how you do it, I hope you try running the app and seeing how SwiftUI handles a disabled button – **when our test fails the button’s text goes gray, but as soon as the test passes the button lights up blue.**