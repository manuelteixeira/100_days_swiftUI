# Day 54 - Project 11, part 2

- **Creating books with Core Data**

    Our **first task in this project will be to design a Core Data model for our books**, **then creating a new view to add books to the database.**

    First, the model: open Bookworm.xcdatamodeld and **add a new entity called “Book”** – we’ll create one new object in there for each book the user has read. **In terms of *what* constitutes a book**, I’d like you to add the following attributes:

    - **id, UUID** – a guaranteed unique identifier we can use to distinguish between books
    - **title, String** – the title of the book
    - **author, String** – the name of whoever wrote the book
    - **genre, String** – one of several strings from the genres in our app
    - **review, String** – a brief overview of what the user thought of the book
    - **rating, Integer 16** – the user’s rating for this book

    Most of those should make sense, but the last one is an odd one: “integer 16”. What is the 16? And how come there are also Integer 32 and Integer 64? **Well, just like `Float` and `Double` the difference is how much data they can store: Integer 16 uses 16 binary digits (“bits”) to store numbers, so it can hold values from -32,768 up to 32,767**, whereas Integer 32 uses 32 bits to store numbers, so it hold values from -2,147,483,648 up to 2,147,483,647. As for Integer 64… well, that’s a really large number – about 9 quintillion.

    The point is that **these values aren’t interchangeable: you can’t take the value from a 64-bit number and try to store it in a 16-bit number, because you’d probably lose data.** 

    On the other hand, it’s a waste of space to use 64-bit integers for values we know will always be small. As a result, Core Data gives us the option to choose just how much storage we want.

    Our **next step is to write a form that can create new entries.** This will combine so many of the skills you’ve learned so far: **`Form`**, **`@State`**, **`@Environment`**, **`TextField`**, **`Picker`**, **`sheet()`**, and more, plus all your new Core Data knowledge.

    Start by creating a new SwiftUI view called “AddBookView”. In terms of properties, we need an environment property to store our managed object context:

    ```swift
    @Environment(\.managedObjectContext) var moc
    ```

    **As this form is going to store all the data required to make up a book, we need `@State` properties for each of the book’s values except `id`, which we can generate dynamically.** 

    So, add these properties next:

    ```swift
    @State private var title = ""
    @State private var author = ""
    @State private var rating = 3
    @State private var genre = ""
    @State private var review = ""
    ```

    Finally, we need one more property to store all possible genre options, so we can make a picker using **`ForEach`**. Add this last property to **`AddBookView`** now:

    ```swift
    let genres = ["Fantasy", "Horror", "Kids", "Mystery", "Poetry", "Romance", "Thriller"]
    ```

    We can now take a first pass at the form itself – we’ll improve it soon, but this is enough for now. Replace the current **`body`** with this:

    ```swift
    NavigationView {
        Form {
            Section {
                TextField("Name of book", text: $title)
                TextField("Author's name", text: $author)

                Picker("Genre", selection: $genre) {
                    ForEach(genres, id: \.self) {
                        Text($0)
                    }
                }
            }

            Section {
                Picker("Rating", selection: $rating) {
                    ForEach(0..<6) {
                        Text("\($0)")
                    }
                }

                TextField("Write a review", text: $review)
            }

            Section {
                Button("Save") {
                    // add the book
                }
            }
        }
        .navigationBarTitle("Add Book")
    }
    ```

    **When it comes to filling in the button’s action, we’re going to create an instance of the `Book` class using our managed object context, copy in all the values from our form** (converting **`rating`** to an **`Int16`** to match Core Data), **then save the managed object context.**

    Most of this work is just copying one value into another, with the only vaguely interesting thing being how we convert from an **`Int`** to an **`Int16`** for the rating. Even that is pretty guessable: **`Int16(someInt)`** does it all.

    Add this code in place of the **`// add the book`** comment:

    ```swift
    let newBook = Book(context: self.moc)
    newBook.title = self.title
    newBook.author = self.author
    newBook.rating = Int16(self.rating)
    newBook.genre = self.genre
    newBook.review = self.review

    try? self.moc.save()
    ```

    That completes the form for now, but **we still need a way to show and hide it when books are being added.**

    Showing **`AddBookView`** involves returning to ContentView.swift and **following the usual steps for a sheet:**

    1. **Adding an `@State` property to track whether the sheet is showing.**
    2. **Add some sort of button** – a navigation bar item, in this case – to toggle that property.
    3. **A `sheet()` modifier that shows `AddBookView` when the property becomes true.**

    **However, this time there’s a small piece of bonus work and it stems from the way SwiftUI’s environment works**. 

    You see, **when we place an object into the environment for a view, it becomes accessible to that view and any views that can call it an ancestor**. 

    So, **if we have View A that contains inside it a View B, anything in the environment for View A will also be in the environment for View B.** 

    Taking this a step further, **if View A happens to be a `NavigationView`, any views that are pushed onto the navigation stack have that `NavigationView` as their ancestor so they share the same environment.**

    **Now think about sheets – those are full-screen pop up windows on iOS. Yes, one screen might have caused them to appear, but does that mean the presented view can call the original its ancestor? SwiftUI has an answer, and it’s “no”**, which **means that when we present a new view as a sheet we need to explicitly pass in a managed object context for it to use**. 

    **As the new `AddBookView` will be shown as a sheet from `ContentView`, we need to add a managed object context property to `ContentView` so it can be passed in.**

    Enough talk – let’s start writing some more code. Please start by adding these three properties to **`ContentView`**:

    ```swift
    @Environment(\.managedObjectContext) var moc
    @FetchRequest(entity: Book.entity(), sortDescriptors: []) var books: FetchedResults<Book>

    @State private var showingAddScreen = false
    ```

    **That gives us a managed object context we can pass into `AddBookView`, a fetch request reading all the books we have** (so we can test everything worked), **and a Boolean that tracks whether the add screen is showing or not.**

    For the **`ContentView`** body, **we’re going to use a navigation view so we can add a title plus a button in its top-right corner**, but otherwise it will just hold some text showing how many items we have in the **`books`** array – just so we can be sure everything is working. Remember, **this is where we need to add our `sheet()` modifier to show an `AddBookView`, passing in the managed object context so it can write its data.**

    **You’ve already seen how we use the `@Environment` property wrapper to read values from the environment, but here we need to *write* values in the environment**. 

    **This is done using a modifier of the same name, `environment()`, which takes two parameters: a key to write to, and the value you want to send in.** 

    For the key we can just send in the one we’ve been using all along, **`\.managedObjectContext`**, and for the value we can pass in our own **`moc`** property – we’re effectively just forwarding it on.

    Replace the existing **`body`** property of **`ContentView`** with this:

    ```swift
     NavigationView {
        Text("Count: \(books.count)")
            .navigationBarTitle("Bookworm")
            .navigationBarItems(trailing: Button(action: {
                self.showingAddScreen.toggle()
            }) {
                Image(systemName: "plus")
            })
            .sheet(isPresented: $showingAddScreen) {
                AddBookView().environment(\.managedObjectContext, self.moc)
            }
    }
    ```

    Bear with me – we’re almost done! We’ve now designed our Core Data model, created a form to add data, then updated **`ContentView`** so that it can present the form and pass in its managed object context. **The final step is to to make the form dismiss itself when the user adds a book.**

    We’ve done this before, so hopefully you know the drill. We need to start by adding another environment property to **`AddBookView`** to track the current presentation mode:

    ```swift
    @Environment(\.presentationMode) var presentationMode
    ```

    Finally, we need to add a call to **`dismiss()`** to the end of our button’s action closure, like this:

    ```swift
    self.presentationMode.wrappedValue.dismiss()
    ```

    You should be able to run the app now and add an example book just fine. When **`AddBookView`** slides away the count label should update itself to 1.

    **Tip:** Two SwiftUI glitches might affect you while following along, depending on which Xcode version you’re using. The first is that you might find the + button really hard to tap, because whereas UIKit extends the tappable area to make it easier to interact with SwiftUI does not, so you need to tap exactly on the +. The second is that you might find tapping the button only works once. This is *definitely* a SwiftUI bug because if we toggle the Boolean using an **`onTapGesture()`** on the text view then everything works – it only has a hard time when it’s using a navigation bar item. Hopefully this will get resolved soon – perhaps even by the time you follow this!

- **Adding a custom star rating component**

    SwiftUI makes it really easy to create custom UI components, because they are effectively just views that have some sort of **`@Binding`** exposed for us to read.

    To demonstrate this, **we’re going to build a star rating view that lets the user enter scores between 1 and 5 by tapping images**. 

    Although we could just make this view simple enough to work for our exact use case, it’s often better to add some flexibility where appropriate so it can be used elsewhere too. Here, that means **we’re going to make six customizable properties**:

    - **What label should be placed before the rating** (default: an empty string)
    - **The maximum integer rating** (default: 5)
    - **The off and on images**, **which dictate the images to use when the star is highlighted or not** (default: **`nil`** for the off image, and a filled star for the on image; if we find **`nil`** in the off image we’ll use the on image there too)
    - **The off and on colors**, which **dictate the colors to use when the star is highlighted or not** (default: gray for off, yellow for on)

    **We also need one extra property to store an `@Binding` integer, so we can report back the user’s selection to whatever is using the star rating.**

    So, create a new SwiftUI view called “RatingView”, and start by giving it these properties:

    ```swift
    @Binding var rating: Int

    var label = ""

    var maximumRating = 5

    var offImage: Image?
    var onImage = Image(systemName: "star.fill")

    var offColor = Color.gray
    var onColor = Color.yellow
    ```

    **Before we fill in the `body` property, please try building the code – you should find that it fails, because our the `RatingView_Previews` struct doesn’t pass in a binding to use for `rating`.**

    **SwiftUI has a specific and simple solution for this called *constant bindings*. These are bindings that have fixed values, which on the one hand means they can’t be changed in the UI, but also means we can create them trivially** – they are perfect for previews.

    So, replace the existing **`previews`** property with this:

    ```swift
    static var previews: some View {
        RatingView(rating: .constant(4))
    }
    ```

    Now let’s turn to the **`body`** property. **This is going to be a `HStack` containing any label that was provided, plus as many stars as have been requested** – although, of course, they can choose any image they want, so it might not be a star at all.

    **The logic for choosing which image to show** is pretty simple, but it’s perfect for carving off into its own method to reduce the complexity of our code. The logic is this:

    - **If the number that was passed in is greater than the current rating, return the off image if it was set, otherwise return the on image.**
    - **If the number that was passed in is equal to or less than the current rating, return the on image**.

    We can encapsulate that in a single method, so add this to **`RatingView`** now:

    ```swift
    func image(for number: Int) -> Image {
        if number > rating {
            return offImage ?? onImage
        } else {
            return onImage
        }
    }
    ```

    And now implementing the **`body`** property is surprisingly easy: **if the label has any text use it, then use `ForEach` to count from 1 to the maximum rating plus 1 and call `image(for:)` repeatedly.** 

    **We’ll also apply a foreground color depending on the rating, and add a tap gesture that adjusts the rating.**

    Replace your existing **`body`** property with this:

    ```swift
    HStack {
        if label.isEmpty == false {
            Text(label)
        }

        ForEach(1..<maximumRating + 1) { number inself.image(for: number)
                .foregroundColor(number > self.rating ? self.offColor : self.onColor)
                .onTapGesture {
                    self.rating = number
                }
        }
    }
    ```

    That completes our rating view already, so to put it into action go back to **`AddBookView`** and replace the second section with this:

    ```swift
    Section {
        RatingView(rating: $rating)
        TextField("Write a review", text: $review)
    }
    ```

    That’s all it takes – our default values are sensible, so it looks great out of the box. And the result is much nicer to use: there’s no need to tap into a detail view with a picker here, because star ratings are more natural and more common.

- **Building a list with @FetchRequest**

    Right now our **`ContentView`** has a fetch request property like this:

    ```swift
    @FetchRequest(entity: Book.entity(), sortDescriptors: []) var books: FetchedResults<Book>
    ```

    And we’re using it in **`body`** with this simple text view:

    ```swift
    Text("Count: \(books.count)")
    ```

    To bring this screen to life, **we’re going to replace that text view with a `List` showing all the books that have been added, along with their rating and author.**

    We *could* just use the same star rating view here that we made earlier, but it’s much more fun to try something else. Whereas the **`RatingView`** control can be used in any kind of project, **we can make a new `EmojiRatingView` that displays a rating specific to this project.** 

    **All it will do is show one of five different emoji depending on the rating**, and it’s a great example of how straightforward view composition is in SwiftUI – it’s so easy to just pull out a small part of your views in this way.

    So, make a new SwiftUI view called “EmojiRatingView”, and give it the following code:

    ```swift
    struct EmojiRatingView: View {
        let rating: Int16

        var body: some View {
            switch rating {
            case 1:
                return Text("1")
            case 2:
                return Text("2")
            case 3:
                return Text("3")
            case 4:
                return Text("4")
            default:
                return Text("5")
            }
        }
    }

    struct EmojiRatingView_Previews: PreviewProvider {
        static var previews: some View {
            EmojiRatingView(rating: 3)
        }
    }
    ```

    **Tip:** I used numbers in my text because emoji can cause havoc with e-readers, but you should replace those with whatever emoji you think represent the various ratings.

    **Notice how that specifically uses `Int16`, which makes interfacing with Core Data easier**. And that’s the entire view done – it really is that simple.

    Now we can return to **`ContentView`** and do a first pass of its UI. **This will replace the existing text view with a list and a `ForEach` over `books`**. 

    **For the `ForEach` identifier we can actually use `\.self` so that it uses the whole object as the identifier**, but things are trickier when it comes to creating views inside the **`ForEach`**.

    You see, **all the properties of our Core Data entity are optional, which means we need to make heavy use of nil coalescing in order to make our code work**. We’ll look at an alternative to this soon, but for now we’ll just be scattering **`??`** around.

    Inside the list **we’re going to have a `NavigationLink` that will eventually point to a detail view, and inside *that* we’ll have our new `EmojiRatingView`, plus the book’s title and author**. So, replace the existing text view with this:

    ```swift
    List {
        ForEach(books, id: \.self) { book inNavigationLink(destination: Text(book.title ?? "Unknown Title")) {
                EmojiRatingView(rating: book.rating)
                    .font(.largeTitle)

                VStack(alignment: .leading) {
                    Text(book.title ?? "Unknown Title")
                        .font(.headline)
                    Text(book.author ?? "Unknown Author")
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    ```

    We’ll come back to this screen soon enough, but first let’s build the detail view…