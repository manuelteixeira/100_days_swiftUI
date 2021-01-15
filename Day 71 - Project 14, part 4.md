# Day 71 - Project 14, part 4

- **Extending existing types to support ObservableObject**

    **Users can now drop pins on our `MapView`, but they can’t do anything with them – they can’t attach their own title and subtitle**. 

    Fixing this requires a little bit of thinking, because `**MKPointAnnotation` uses *optional* strings for title and subtitle, and SwiftUI doesn’t let us bind optionals to text fields.**

    There are a couple of ways of fixing this, but the **easiest one by far is writing an extension to `MKPointAnnotation` that adds computed properties around `title` and `subtitle`, which means we can then make the class conform to `ObservableObject` without any further work**. 

    You can call these computed properties whatever you want – **`name`**, **`info`**, **`details`**, etc – but you’ll probably find that marking them as simple wrappers works out easier to remember in the long term, which is why I’m going to use the names **`wrappedTitle`** and **`wrappedSubtitle`**.

    Create a new Swift file called MKPointAnnotation-ObservableObject.swift, change its Foundation import for MapKit, then give it this code:

    ```swift
    extension MKPointAnnotation: ObservableObject {
        public var wrappedTitle: String {
            get {
                self.title ?? "Unknown value"
            }

            set {
                title = newValue
            }
        }

        public var wrappedSubtitle: String {
            get {
                self.subtitle ?? "Unknown value"
            }

            set {
                subtitle = newValue
            }
        }
    }
    ```

    Notice how I haven’t marked those computed properties as **`@Published`**? This is OK here because **we won’t actually be reading the properties as they are being changed, so there’s no need to keep refreshing the view as the user types.**

    With that new extension in place, we have two properties on **`MKPointAnnotation`** that *aren’t* optional, which means **we can now bind some UI controls to them in a SwiftUI view** – we can create a UI for editing place marks.

    As always we’re going to start small and work our way up, so please create a new SwiftUI view called “EditView”, add an import for MapKit, then give it this code:

    ```swift
    struct EditView: View {
        @Environment(\.presentationMode) var presentationMode
        @ObservedObject var placemark: MKPointAnnotation

        var body: some View {
            NavigationView {
                Form {
                    Section {
                        TextField("Place name", text: $placemark.wrappedTitle)
                        TextField("Description", text: $placemark.wrappedSubtitle)
                    }
                }
                .navigationBarTitle("Edit place")
                .navigationBarItems(trailing: Button("Done") {
                    self.presentationMode.wrappedValue.dismiss()
                })
            }
        }
    }
    ```

    Make you update the preview code so that it passes in our example **`MKPointAnnotation`**, like this:

    ```swift
    struct EditView_Previews: PreviewProvider {
        static var previews: some View {
            EditView(placemark: MKPointAnnotation.example)
        }
    }
    ```

    **We want to display that in two places, both in `ContentView`: when the user adds a place we want them to immediately edit it, and when they press the Edit button in our pin alert.**

    Both of these will be triggered by a Boolean condition, so start by adding this **`@State`** property to **`ContentView`**:

    ```swift
    @State private var showingEditScreen = false
    ```

    **That should be set to true when the user taps Edit in our alert**, which means replacing the **`// edit this place`** comment with this:

    ```swift
    self.showingEditScreen = true
    ```

    **And it also means setting it to true when they just added a new place to the map**, but **we also need to set the `selectedPlace` property so our code knows which place should be edited**. So, put this below the **`self.locations.append(newLocation)`** line:

    ```swift
    self.selectedPlace = newLocation
    self.showingEditScreen = true
    ```

    And finally, **we need to bind `showingEditScreen` to a sheet, so our `EditView` struct gets presented with a place mark at the right time**. 

    Remember, **we can’t use `if let` here to unwrap the `selectedPlace` optional**, so we’ll do a simple check then force unwrap – it’s just as safe.

    Please attach this **`sheet()`** modifier to **`ContentView`**, after the existing alert:

    ```swift
    .sheet(isPresented: $showingEditScreen) {
        if self.selectedPlace != nil {
            EditView(placemark: self.selectedPlace!)
        }
    }
    ```

    That’s the next step of our app done, and it’s now almost useful – you can browse the map, tap to drop pins, then give them a meaningful title and subtitle.

- **Downloading data from Wikipedia**

    To make this whole app more useful, **we’re going to modify our `EditView` screen so that it shows interesting places**. After all, if visiting London is on your bucket list, you’d probably want some suggestions for things to see nearby. This might sound hard to do, but actually **we can query Wikipedia using GPS coordinates, and it will send back a list of places that are nearby.**

    **Wikipedia’s API sends back JSON data in a precise format**, so we need to do a little work to define **`Codable`** structs capable of storing it all. The structure is this:

    - The **main result contains the result of our query in a key called “query”.**
    - **Inside the query is a “pages” dictionary**, with page IDs as the key and the Wikipedia pages themselves as values.
    - **Each page has a lot of information, including its coordinates, title, terms, and more**.

    We can represent that using three linked structs, so create a new Swift file called Result.swift and give it this content:

    ```swift
    struct Result: Codable {
        let query: Query
    }

    struct Query: Codable {
        let pages: [Int: Page]
    }

    struct Page: Codable {
        let pageid: Int
        let title: String
        let terms: [String: [String]]?
    }
    ```

    We’re going to use that to store data we fetch from Wikipedia, then show it immediately in our UI. However, **we need something to show while the fetch is happening** – a text view saying “Loading” or similar ought to do the trick.

    **This means conditionally showing different UI depending on the current load state**, and **that means defining an enum that actually *stores* the current load state** otherwise we don’t know what to show.

    Start by adding this nested enum to **`EditView`**:

    ```swift
    enum LoadingState {
        case loading, loaded, failed
    }
    ```

    Those cover are all the states we need to represent our network request.

    Next we’re going to **add two properties to** **`EditView`**: **one to represent the loading state**, and **one to store an array of Wikipedia pages** once the fetch has completed. So, add these two now:

    ```swift
    @State private var loadingState = LoadingState.loading
    @State private var pages = [Page]()
    ```

    Before we tackle the network request itself, we have one last easy job to do: **adding to our `Form` a new section to show pages if they have loaded, or status text views otherwise.** 

    We can put these **`if/else if`** conditions right into the **`Section`** and SwiftUI will figure it out.

    So, put this section below the existing one:

    ```swift
    Section(header: Text("Nearby…")) {
        if loadingState == .loaded {
            List(pages, id: \.pageid) { page inText(page.title)
                    .font(.headline)
                + Text(": ") +
                Text("Page description here")
                    .italic()
            }
        } else if loadingState == .loading {
            Text("Loading…")
        } else {
            Text("Please try again later.")
        }
    }
    ```

    **Tip:** Notice how **we can use `+` to add text views together**? This **lets us create larger text views that mix and match different kinds of formatting**. 

    That “Page description here” is just temporary – we’ll replace it soon.

    Now for the part that really brings all this together: **we need to fetch some data from Wikipedia, decode it into a `Result`, assign its pages to our `pages` property, then set `loadingState` to `.loaded`**. 

    **If the fetch fails, we’ll set `loadingState` to `.failed`**, and SwiftUI will load the appropriate UI.

    **Warning:** The Wikipedia URL we need to load is really long, so rather than try to type it in you might want to copy and paste from the text or from my GitHub gist: [http://bit.ly/swiftwiki](http://bit.ly/swiftwiki).

    Add this method to **`EditView`**:

    ```swift
    func fetchNearbyPlaces() {
        let urlString = "https://en.wikipedia.org/w/api.php?ggscoord=\(placemark.coordinate.latitude)%7C\(placemark.coordinate.longitude)&action=query&prop=coordinates%7Cpageimages%7Cpageterms&colimit=50&piprop=thumbnail&pithumbsize=500&pilimit=50&wbptterms=description&generator=geosearch&ggsradius=10000&ggslimit=50&format=json"

        guard let url = URL(string: urlString) else {
            print("Bad URL: \(urlString)")
            return}

        URLSession.shared.dataTask(with: url) { data, response, error inif let data = data {
                // we got some data back!
                let decoder = JSONDecoder()

                if let items = try? decoder.decode(Result.self, from: data) {
                    // success – convert the array values to our pages array
                    self.pages = Array(items.query.pages.values)
                    self.loadingState = .loaded
                    return}
            }

            // if we're still here it means the request failed somehow
            self.loadingState = .failed
        }.resume()
    }
    ```

    **That request should begin as soon as the view appears, so add this** **`onAppear()`** modifier after the existing **`navigationBarItems()`** modifier:

    ```swift
    .onAppear(perform: fetchNearbyPlaces)
    ```

    Now go ahead and run the app again – you’ll find that as you drop a pin our **`EditView`** screen will slide up and show you all the places nearby. Nice!

- **Sorting Wikipedia results**

    **Wikipedia’s results come back** to us in an order that probably seems random, but it’s actually **sorted according to their internal page ID**. That doesn’t help *us* though, because users will just look at the results and think they are random.

    **To fix this we’re going to sort the results**, and rather than just provide an inline closure to **`sorted()`** **we are instead going to make our `Page` struct conform to `Comparable`**. 

    This is actually pretty easy to do, because we already have a **`title`** string that would be a great candidate for sorting.

    So, start by modifying the definition of the **`Page`** struct to this:

    ```swift
    struct Page: Codable, Comparable {
    ```

    If you recall, **conforming to `Comparable` has only a single requirement: we must implement a `<` function** that accepts two parameters of the type of our struct, and returns true if the first should be sorted before the second. 

    In this case **we can just pass the test directly onto the `title` strings**, so add this method to the **`Page`** struct now:

    ```swift
    static func < (lhs: Page, rhs: Page) -> Bool {
        lhs.title < rhs.title
    }
    ```

    **Now that Swift understands how to sort pages, it will automatically gives us a parameter-less `sorted()` method on page arrays**. 

    This means when we set **`self.pages`** in **`fetchNearbyPlaces()`** **we can now add `sorted()` to the end**, like this:

    ```swift
    self.pages = Array(items.query.pages.values).sorted()
    ```

    If you run the app now, you’ll see that places near a map pin are now sorted alphabetically by their name – much better!

    Before we’re done with this screen, **we need to replace the `Text("Page description here")` view with something real**. 

    **Wikipedia’s JSON data does contain a description, but it’s buried: the `terms` dictionary might not be there, and if it is there it might not have a `description` key, and if it *has* a `description` key it might be an empty array rather than an array with some text inside**.

    We don’t want this mess to plague our SwiftUI code, so again the **best thing to do is make a computed property that returns the description if it exists, or a fixed string otherwise**. Add this to the **`Page`** struct to finish it off:

    ```swift
    var description: String {
        terms?["description"]?.first ?? "No further information"
    }
    ```

    With that done you can replace **`Text("Page description here")`** with this:

    ```swift
    Text(page.description)
    ```

    That completes **`EditView`** – it lets us edit the two properties of our annotation views, it downloads and sorts data from Wikipedia, it shows different UI depending on how the network request is going, and it even carefully looks through the Wikipedia content to decide what can be shown.