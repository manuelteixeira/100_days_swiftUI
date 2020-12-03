# Day 55 - Project 11, part 3

- **Showing book details**

    When the user taps a book in **`ContentView`** **we’re going to present a detail view with some more information** – the **genre of the book, their brief review, and more**. 

    **We’re also going to reuse our new `RatingView`**, and even customize it so you can see just how flexible SwiftUI is.

    To make this screen more interesting, we’re going to add some artwork that represents each category in our app. I’ve picked out some artwork already from Unsplash, and placed it into the project11-files folder for this book – if you haven’t downloaded them, please do so now and then drag them into your asset catalog.

    Unsplash has a license that allows us to use pictures commercially or non-commercially, with or without attribution, although attribution is appreciated. The pictures I’ve added are by Ryan Wallace, Eugene Triguba, Jamie Street, Alvaro Serrano, Joao Silas, David Dilbert, and Casey Horner – you can get the originals from [https://unsplash.com](https://unsplash.com/) if you want.

    Next, **create a new SwiftUI view called “DetailView”.** This only needs one property, which is the book it should show, so please add that now:

    ```swift
    let book: Book
    ```

    **Even just having that property is enough to break the preview code at the bottom of DetailView.swift**. 

    Previously this was easy to fix because we just sent in an example object, but **with Core Data involved things are messier: creating a new book also means having a managed object context to create it inside.**

    **To fix this, we can update our preview code to create a temporary managed object context, then use *that* to create our book.** 

    **Once that’s done we can pass in some example data to make our preview look good**, then use the test book to create a detail view preview.

    **Creating a managed object context means we need to start by importing Core Data**. Add this line near the top of DetailView.swift, next to the existing **`import`**:

    ```swift
    import CoreData
    ```

    As for the previews code itself, replace whatever you have now with this:

    ```swift
    struct DetailView_Previews: PreviewProvider {
        static let moc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)

        static var previews: some View {
            let book = Book(context: moc)
            book.title = "Test book"
            book.author = "Test author"
            book.genre = "Fantasy"
            book.rating = 4
            book.review = "This was a great book; I really enjoyed it."

            return NavigationView {
                DetailView(book: book)
            }
        }
    }
    ```

    As you can see, **creating a managed object context involves telling the system what concurrency type we want to use**. 

    **This is another way of saying “which thread do you plan to access your data using?”** For our example, using the main queue – that’s the one the app was launched using – is perfectly fine.

    With that done we can turn our attention to more interesting problems, namely designing the view itself. 

    To start with, **we’re going to place the category image and genre inside a `ZStack`, so we can put one on top of the other nicely**. 

    **This in turn means going inside a `GeometryReader`, so we can make sure the image doesn’t take up too much space**. I’ve picked out some styling that I think looks good, but you’re welcome to experiment with the styling all you want.

    Replace the current **`body`** property with this:

    ```swift
    GeometryReader { geometry inVStack {
            ZStack(alignment: .bottomTrailing) {
                Image(self.book.genre ?? "Fantasy")
                    .frame(maxWidth: geometry.size.width)

                Text(self.book.genre?.uppercased() ?? "FANTASY")
                    .font(.caption)
                    .fontWeight(.black)
                    .padding(8)
                    .foregroundColor(.white)
                    .background(Color.black.opacity(0.75))
                    .clipShape(Capsule())
                    .offset(x: -5, y: -5)
            }
        }
    }
    .navigationBarTitle(Text(book.title ?? "Unknown Book"), displayMode: .inline)
    ```

    **That places the genre name in the bottom-right corner of the `ZStack`, with a background color, bold font, and a little padding to help it stand out.**

    **Below that `Stack` we’re going to add the author, review, and rating, plus a spacer so that everything gets pushed to the top of the view.** 

    **We don’t want users to be able to adjust the rating here, so instead we can use another constant binding to turn this into a simple read-only view**. 

    Even better, **because we used SF Symbols to create the rating image, we can scale them up seamlessly with a simple `font()` modifier**, to make better use of all the space we have.

    So, add these views directly below the previous **`ZStack`**:

    ```swift
    Text(self.book.author ?? "Unknown author")
        .font(.title)
        .foregroundColor(.secondary)

    Text(self.book.review ?? "No review")
        .padding()

    RatingView(rating: .constant(Int(self.book.rating)))
        .font(.largeTitle)

    Spacer()
    ```

    That completes **`DetailView`**, so we can head back to ContentView.swift to **change the navigation link so it points to the correct thing:**

    ```swift
    NavigationLink(destination: DetailView(book: book)) {
    ```

    Now run the app again, because you should be able to tap any of the books you’ve entered to show them in our new detail view.

- **Sorting fetch requests with NSSortDescriptor**

    **When you use SwiftUI’s `@FetchRequest` property wrapper to pull objects out of Core Data, you get to specify how you want the data to be sorted** – should it alphabetically by one of the fields? Or numerically with the highest numbers first? 

    We specified an empty array, which might work OK for a handful of items but after 20 or so will just annoy the user.

    In this project **we have various fields that might be useful for sorting purposes: the title of the book, the author, or the rating are all sensible and would be good choices, but I suspect title is probably the most common so let’s use that.**

    **Fetch request sorting is performed using a new class called `NSSortDescriptor`, and we can create them from two values**: **the attribute we want to sort on**, **and whether it should be ascending or not**. 

    For example, we can alphabetically sort on the title attribute like this:

    ```swift
    @FetchRequest(entity: Book.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Book.title, ascending: true)]) var books: FetchedResults<Book>
    ```

    **You can specify more than one sort descriptor, and they will be applied in the order you provide them**. 

    For example, **if the user added the book “Forever” by Pete Hamill, then added “Forever” by Judy Blume – an entirely different book that just happens to have the same title – then specifying a second sort field is helpful.**

    So, we might ask for book title to be sorted ascending first, followed by book author ascending second, like this:

    ```swift
    @FetchRequest(entity: Book.entity(), sortDescriptors: [
        NSSortDescriptor(keyPath: \Book.title, ascending: true),
        NSSortDescriptor(keyPath: \Book.author, ascending: true)
    ]) var books: FetchedResults<Book>
    ```

    **Having a second or even third sort field has little to no performance impact unless you have lots of data with similar values**. 

    With our books data, for example, almost every book will have a unique title, so having a secondary sort field is more or less irrelevant in terms of performance.

- **Deleting from a Core Data fetch request**

    We already used **`@FetchRequest`** to place Core Data objects into a SwiftUI **`List`**, and **with only a little more work we can enable both swipe to delete and a dedicated Edit/Done button.**

    Just as with regular arrays of data, **most of the work is done by attaching an `onDelete(perform:)` modifier to `ForEach`**, but **rather than just removing items from an array we instead need to find the requested object in our fetch request then use it to call `delete()` on our managed object context**. 

    **Once all the objects are deleted we can trigger another save of the context**; **without that the changes won’t actually be written out to disk.**

    So, start by adding this method to **`ContentView`**:

    ```swift
    func deleteBooks(at offsets: IndexSet) {
        for offset in offsets {
            // find this book in our fetch request
            let book = books[offset]

            // delete it from the context
            moc.delete(book)
        }

        // save the context
        try? moc.save()
    }
    ```

    **We can trigger that by adding an `onDelete(perform:)` modifier to the `ForEach` of `ContentView`, but remember: it needs to go on the `ForEach` and *not* the `List`.**

    Add this modifier now:

    ```swift
    .onDelete(perform: deleteBooks)
    ```

    **That gets us swipe to delete**, and **we can go one better by adding an Edit/Done button too**. Find the **`navigationBarItems()`** modifier in **`ContentView`**, and change its first line to this:

    ```swift
    .navigationBarItems(leading: EditButton(), trailing: Button(action: {
    ```

    That completes **`ContentView`**, so try running the app – you should be able to add and delete books freely now, and can delete by using swipe to delete or using the edit button.

- **Using an alert to pop a NavigationLink programmatically**

    You’ve already seen how **`NavigationLink`** lets us push to a detail screen, which might be a custom view or one of SwiftUI’s built-in types such as **`Text`** or **`Image`**. 

    Because we’re inside a **`NavigationView`**, iOS automatically provides a “Back” button to let users get back to the previous screen, and they can also swipe from the left edge to go back. However, sometimes it’s useful to programmatically go back – i.e., to move back to the previous screen when we want rather than when the user swipes.

    To demonstrate this, **we’re going to add one last feature to our app that deletes whatever book the user is currently looking at**. 

    To do this **we need to show an alert asking the user if they really want to delete the book, then delete the book from the current managed object context if that’s what they want.** **Once that’s done, there’s no point staying on the current screen because its associated book doesn’t exist any more, so we’re going to pop the current view** – **remove it from the top of the `NavigationView` stack, so we move back to the previous screen.**

    First, **we need three new properties in our `DetailView` struct: one to hold our Core Data managed object context (so we can delete stuff), one to hold our presentation mode (so we can pop the view off the navigation stack), and one to control whether we’re showing the delete confirmation alert or not**.

    So, start by adding these three new properties to **`DetailView`**:

    ```swift
    @Environment(\.managedObjectContext) var moc
    @Environment(\.presentationMode) var presentationMode
    @State private var showingDeleteAlert = false
    ```

    **The second step is writing a method that deletes the current book from our managed object context, and dismisses the current view**. 

    **It doesn’t matter that this view is being shown using a navigation link rather than a sheet** – we still use the same **`presentationMode.wrappedValue.dismiss()`** code.

    Add this method to **`DetailView`** now:

    ```swift
    func deleteBook() {
        moc.delete(book)

        // uncomment this line if you want to make the deletion permanent
        // try? self.moc.save()
        presentationMode.wrappedValue.dismiss()
    }
    ```

    **The third step is to add an `alert()` modifier that watches `showingDeleteAlert`, along with an `Alert` view inside it asking the user to confirm the action**. 

    So far we’ve been using simple alerts with a dismiss button, **but here we need two buttons: one button to delete the book, and another to cancel**.

    **SwiftUI gives us two specific button types for this purpose: `.destructive` takes a title and action closure and is shown in red to warn users it will destroy data**, **and `.cancel()` will just cause the alert to be dismissed**. 

    Apple provides very clear guidance on how we should label alert text, but it comes down to this: if it’s a simple “I understand” acceptance then “OK” is good, but if you want users to make a choice then you should avoid titles like “Yes” and “No” and instead use verbs such as “Ignore”, “Reply”, and “Confirm”.

    In this instance, we’re going to use “Delete” for the destructive button, then provide a **`.cancel()`** button next to it so users can back out of deleting if they want. So, add this modifier to the **`GeometryReader`** in **`DetailView`**:

    ```swift
    .alert(isPresented: $showingDeleteAlert) {
        Alert(title: Text("Delete book"), message: Text("Are you sure?"), primaryButton: .destructive(Text("Delete")) {
                self.deleteBook()
            }, secondaryButton: .cancel()
        )
    }
    ```

    **The final step is to add a navigation bar item that starts the deletion process – this just need to flip the `showingDeleteAlert` Boolean, because our `alert()` modifier is already watching it**. So, add this one last modifier to the **`GeometryReader`** in **`DetailView`**:

    ```swift
    .navigationBarItems(trailing: Button(action: {
        self.showingDeleteAlert = true
    }) {
        Image(systemName: "trash")
    })
    ```

    You can now delete books in **`ContentView`** using swipe to delete or the edit button, or navigate into **`DetailView`** then tap the dedicated delete button in there – it should delete the book, update the list in **`ContentView`**, then automatically dismiss the detail view.

    That’s another app complete – good job!