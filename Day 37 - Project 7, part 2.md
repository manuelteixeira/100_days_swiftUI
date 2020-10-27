# Day 37 - Project 7, part 2

- **Building a list we can delete from**

    In this project we want a list that can show some expenses, and previously we would have done this using an **`@State`** array of objects. Here, though, we’re going to take a different approach: **we’re going to create an `Expenses` class that will be attached to our list using `@ObservedObject`.**

    **This might sound like we’re over-complicating things a little, but it actually makes things much easier because we can make the `Expenses` class load and save itself seamlessly** – it will be almost invisible, as you’ll see.

    First, **we need to decide what an expense *is*** – what do we want it to store? In this instance **it will be three things: the name of the item, whether it’s business or personal, and its cost as an integer.**

    We’ll add more to this later, but for now **we can represent all that using a single `ExpenseItem` struct.** You can put this into a new Swift file called ExpenseItem.swift, but you don’t need to – you can just put this into ContentView.swift if you like, as long as you don’t put it *inside* the **`ContentView`** struct itself.

    Regardless of where you put it, this is the code to use:

    ```swift
    struct ExpenseItem {
        let name: String
        let type: String
        let amount: Int
    }
    ```

    Now that we have something that represents a single expense, the next step is to create something to store an array of those expense items inside a single object. **This needs to conform to the `ObservableObject` protocol, and we’re also going to use `@Published` to make sure change announcements get sent whenever the `items` array gets modified.**

    As with the **`ExpenseItem`** struct, this will start off simple and we’ll add to it later, so add this new class now:

    ```swift
    class Expenses: ObservableObject {
        @Published var items = [ExpenseItem]()
    }
    ```

    That finishes all the data required for our main view: **we have a struct to represent a single item of expense, and a class to store an array of all those items.**

    Let’s now put that into *action* with our SwiftUI view, so we can actually see our data on the screen. **Most of our view will just be a `List` showing the items in our expenses, but because we want users to delete items they no longer want we can’t just use a simple `List` – we need to use a `ForEach` *inside* the list, so we get access to the `onDelete()` modifier.**

    First, **we need to add an `@ObservedObject` property in our view**, that will create an instance of our **`Expenses`** class:

    ```swift
    @ObservedObject var expenses = Expenses()
    ```

    Remember, using **`@ObservedObject`** **here asks SwiftUI to watch the object for any change announcements, so any time one of our `@Published` properties changes the view will refresh its body.**

    Second, we can use that **`Expenses`** object with a **`NavigationView`**, a **`List`**, and a **`ForEach`**, to create our basic layout:

    ```swift
    NavigationView {
        List {
            ForEach(expenses.items, id: \.name) { item inText(item.name)
            }
        }
        .navigationBarTitle("iExpense")
    }
    ```

    **That tells the `ForEach` to identify each expense item uniquely by its name, then prints the name out as the list row.**

    We’re going to add two more things to our simple layout before we’re done: the ability to add new items for testing purposes, and the ability to delete items with a swipe.

    We’re going to let users add their own items soon, but it’s important to check that our list actually works well before we continue. So, we’re going to **add a trailing bar button item that adds example `ExpenseItem` instances for us to work with – add this modifier to the `List` now:**

    ```swift
    .navigationBarItems(trailing:
        Button(action: {
            let expense = ExpenseItem(name: "Test", type: "Personal", amount: 5)
            self.expenses.items.append(expense)
        }) {
            Image(systemName: "plus")
        }
    )
    ```

    That brings our app to life: you can launch it now, then press the + button repeatedly to add lots of testing expenses.

    **Now that we can *add* expenses, we can also add code to remove them. This means adding a method capable of deleting an `IndexSet` of list items, then passing that directly on to our `expenses` array**:

    ```swift
    func removeItems(at offsets: IndexSet) {
        expenses.items.remove(atOffsets: offsets)
    }
    ```

    **And to attach that to SwiftUI, we add an `onDelete()` modifier to our `ForEach`**, like this:

    ```swift
    ForEach(expenses.items, id: \.name) { item inText(item.name)
    }
    .onDelete(perform: removeItems)
    ```

    Go ahead and run the app now, press + a few times, then swipe to delete the rows.

    *Now try doing it while looking carefully*. What do you notice? You should see that adding items works fine, but deleting them behaves just a little oddly: swipe a little on your first row then tap its Delete button; you should see that the row slides back into place as normal, then the item at the end of the list gets removed.

    What’s going on? Well, it turns out we’ve lied to SwiftUI, and that lie is coming back to cause problems…

- **Working with Identifiable items in SwiftUI**

    When we create static views in SwiftUI – when we hard-code a **`VStack`**, then a **`TextField`**, then a **`Button`**, and so on – SwiftUI can see exactly which views we have, and is able to control them, animate them, and more. 

    But **when we use `List` or `ForEach` to make dynamic views, SwiftUI needs to know how it can identify each item uniquely otherwise it’s not able to compare view hierarchies to figure out what has changed.**

    In our current code, we have this:

    ```swift
    ForEach(expenses.items, id: \.name) { item inText(item.name)
    }
    .onDelete(perform: removeItems)
    ```

    In English, that means “**create a new row for every item in the expense items, identified uniquely by its name, showing that name in the row, and calling the `removeItems()` method to delete it**.”

    Then, later, we have this code:

    ```swift
    Button(action: {
        let expense = ExpenseItem(name: "Test", type: "Personal", amount: 5)
        self.expenses.items.append(expense)
    }) {
        Image(systemName: "plus")
    }
    ```

    Every time that button is pressed, it adds a test expense to our list, so we can make sure adding and deleting works.

    Can you see the problem?

    **Every time we create an example expense item we’re using the name “Test”, but we’ve also told SwiftUI that it can use the expense name as a unique identifier.** 

    So, **when our code runs and we delete an item, SwiftUI looks at the array beforehand – “Test”, “Test”, “Test”, “Test” – then looks at the array *afterwards* – “Test”, “Test”, “Test” – and can’t actually tell what changed**. 

    ***Something* has changed, because one item has disappeared, but SwiftUI can’t be sure which. As a result, it takes the simplest option and just removes the last one from the table.**

    This is a logic error on our behalf: our code is fine, and it doesn’t crash at runtime, but we’ve applied the wrong logic to get to that end result – we’ve told SwiftUI that something will be a unique identifier, when it isn’t unique at all.

    To fix this we need to think more about our **`ExpenseItem`** struct. Right now it has three properties: **`name`**, **`type`**, and **`amount`**. 

    The name by itself *might* be unique in practice, but it’s also likely not to be – as soon as the user enters “Lunch” twice we’ll start hitting problems. We could perhaps try to combine the name, type and amount into a new computed property, but even then we’re just delaying the inevitable; it’s still not really unique.

    **The smart solution here is to add something to `ExpenseItem` that *is* unique, such as an ID number that we assign by hand**. 

    **That would work, but it does mean tracking the last number we assigned so we don’t use duplicates there either.**

    **There is in fact an easier solution, and it’s called `UUID` – short for “universally unique identifier”**, and if *that* doesn’t sound unique I’m not sure what does.

    **UUIDs are long hexadecimal strings such as this one: 08B15DB4-2F02-4AB8-A965-67A9C90D8A44**. 

    So, that’s eight digits, four digits, four digits, four digits, then twelve digits, of which the only requirement is that there’s a 4 in the first number of the third block. If we subtract the fixed 4, we end up with 31 digits, each of which can be one of 16 values – if we generated 1 UUID every second for a billion years, we might begin to have the slightest chance of generating a duplicate.

    Now, we could update **`ExpenseItem`** to have a **`UUID`** property like this:

    ```swift
    struct ExpenseItem {
        let id: UUID
        let name: String
        let type: String
        let amount: Int
    }
    ```

    **And that would work. However, it would also mean we need to generate a UUID by hand, then load and save the UUID along with our other data.** 

    So, in this instance **we’re going to ask Swift to generate a `UUID` automatically for us like this**:

    ```swift
    struct ExpenseItem {
        let id = UUID()
        let name: String
        let type: String
        let amount: Int
    }
    ```

    **Now we don’t need to worry about the `id` value of our expense items – Swift will make sure they are always unique.**

    **With that in place we can now fix our `ForEach`**, like this:

    ```swift
    ForEach(expenses.items, id: \.id) { item inText(item.name)
    }
    ```

    If you run the app now you’ll see our problem is fixed: SwiftUI can now see exactly which expense item got deleted, and will animate everything correctly.

    We’re not done with this step quite yet, though. Instead, I’d like you to **modify the `ExpenseItem` to make it conform to a new protocol called `Identifiable`**, like this:

    ```swift
    struct ExpenseItem: Identifiable {
        let id = UUID()
        let name: String
        let type: String
        let amount: Int
    }
    ```

    All we’ve done is add **`Identifiable`** to the list of protocol conformances, nothing more. **This is one of the protocols built into Swift, and means “this type can be identified uniquely.”
    It has only one requirement, which is that there must be a property called `id` that contains a unique identifier.** 

    Now, you might wonder **why we added that, because our code was working fine before**. 

    Well, **because our expense items are now guaranteed to be identifiable uniquely, we no longer need to tell `ForEach` which property to use for the identifier** – it knows there will be an **`id`** property and that it will be unique, because that’s the point of the **`Identifiable`** protocol.

    So, as a result of this change we can modify the **`ForEach`** again, to this:

    ```swift
    ForEach(expenses.items) { item inText(item.name)
    }
    ```

- **Sharing an observed object with a new view**

    **Classes that conform to `ObservableObject` can be used in more than one SwiftUI view, and all of those views will be updated when the published properties of the class change.**

    In this app, we’re going to design a view specially for adding new expense items. When the user is ready, we’ll add that to our **`Expenses`** class, which will automatically cause the original view to refresh its data so the expense item can be shown.

    To make a new SwiftUI view you can either press Cmd+N or go to the File menu and choose New > File. Either way, **you should select “SwiftUI View” under the User Interface category**, then name the file AddView.swift. If you find that the group doesn’t have a yellow folder next to it, please select that then make sure you save the file inside the “iExpense” directory alongside your other code. All being well, Xcode should show you the new view, ready to edit.

    As with our other views, our first pass at **`AddView`** will be simple and we’ll add to it. 

    That means **we’re going to add text fields for the expense name and amount, plus a picker for the type, all wrapped up in a form and a navigation view.**

    This should all be old news to you by now, so let’s get into the code:

    ```swift
    struct AddView: View {
        @State private var name = ""
        @State private var type = "Personal"
        @State private var amount = ""

        static let types = ["Business", "Personal"]

        var body: some View {
            NavigationView {
                Form {
                    TextField("Name", text: $name)
                    Picker("Type", selection: $type) {
                        ForEach(Self.types, id: \.self) {
                            Text($0)
                        }
                    }
                    TextField("Amount", text: $amount)
                        .keyboardType(.numberPad)
                }
                .navigationBarTitle("Add new expense")
            }
        }
    }
    ```

    We’ll come back to that in a moment, but first let’s add some code to **`ContentView`** so we can show **`AddView`** when the + button is tapped.

    In order to present **`AddView`** as a new view, we need to make three changes to **`ContentView`**. 

    First, **we need some state to track whether or not `AddView` is being shown**, so add this as a property now:

    ```swift
    @State private var showingAddExpense = false
    ```

    Next, **we need to tell SwiftUI to use that Boolean as a condition for showing a sheet – a pop-up window**. 

    **This is done by attaching the `sheet()` modifier somewhere to our view hierarchy.** You can use the **`List`** if you want, but the **`NavigationView`** works just as well. Either way, add this code as a modifier to one of the views in **`ContentView`**:

    ```swift
    .sheet(isPresented: $showingAddExpense) {
        // show an AddView here
    }
    ```

    The third step is to **put something inside the sheet.** Often that will just be an instance of the view type you want to show, like this:

    ```swift
    .sheet(isPresented: $showingAddExpense) {
        AddView()
    }
    ```

    Here, though, we need something more.

    **You see, we already have the `expenses` property in our content view, and inside `AddView` we’re going to be writing code to add expense items. We don’t want to create a *second* instance of the `Expenses` class in `AddView`, but instead want it to share the existing instance from `ContentView`.**

    So, what **we’re going to do is add a property to `AddView` to store an `Expenses` object**.

    It won’t create the object there, just say that it will exist. Please add this property to **`AddView`**:

    ```swift
    @ObservedObject var expenses: Expenses
    ```

    **And now we can pass our existing `Expenses` object from one view to another – they will both share the same object, and will both monitor it for changes**. Modify your **`sheet()`** modifier in **`ContentView`** to this:

    ```swift
    .sheet(isPresented: $showingAddExpense) {
        AddView(expenses: self.expenses)
    }
    ```

    We’re not quite done with this step yet, for two reasons: our code won’t compile, and even if it *did* compile it wouldn’t work because our button doesn’t trigger the sheet.

    **The compilation failure happens because when we made the new SwiftUI view, Xcode also added a preview provider so we can look at the design of the view while we were coding**. 

    If you find that down at the bottom of AddView.swift, **you’ll see that it tries to create an `AddView` instance without providing a value for the `expenses` property.**

    That isn’t allowed any more, but we can just pass in a dummy value instead, like this:

    ```swift
    struct AddView_Previews: PreviewProvider {
        static var previews: some View {
            AddView(expenses: Expenses())
        }
    }
    ```

    **The second problem is that we don’t actually have any code to *show* the sheet, because right now the + button in `ContentView` adds test expenses.** Fortunately, the fix is trivial – just replace the existing action with code to toggle our **`showingAddExpense`** Boolean, like this:

    ```swift
    Button(action: {
        self.showingAddExpense = true
    }) {
        Image(systemName: "plus")
    }
    ```

    If you run the app now the whole sheet should be working as intended – you start with **`ContentView`**, tap the + button to bring up an **`AddView`** where you can type in the various fields, then can swipe to dismiss.

- **Making changes permanent with UserDefaults**

    At this point, our app’s user interface is functional: you’ve seen we can add and delete items, and now we have a sheet showing a user interface to create new expenses. However, the app is far from working: any data placed into **`AddView`** is completely ignored, and even if it *weren’t* ignored then it still wouldn’t be saved for future times the app is run.

    We’ll tackle those problems in order, starting with actually *doing* something with the data from **`AddView`**. We already have properties that store the values from our form, and previously we added a property to store an **`Expenses`** object passed in from the **`ContentView`**.

    We need to put those two things together: **we need a button that, when tapped, creates an `ExpenseItem` out of our properties and adds it to the `expenses` items**. 

    **Our `ExpenseItem` struct has an integer for its amount, which means we need to do a little typecasting from the string value of `amount`.**

    Add this modifier below **`navigationBarTitle()`** in **`AddView`**:

    ```swift
    .navigationBarItems(trailing: Button("Save") {
        if let actualAmount = Int(self.amount) {
            let item = ExpenseItem(name: self.name, type: self.type, amount: actualAmount)
            self.expenses.items.append(item)
        }
    })
    ```

    Although we have more work to do, I encourage you to run the app now because it’s actually coming together – **you can now show the add view, enter some details, press “Save”, then swipe to dismiss, and you’ll see your new item in the list**. That means our data synchronization is working perfectly: both the SwiftUI views are reading from the same list of expense items.

    Now try launching the app again, and you’ll immediately hit our second problem: **any data you add isn’t stored, meaning that everything starts blank every time you relaunch the app.**

    This is obviously a pretty terrible user experience, but thanks to the way we have **`Expense`** as a separate class it’s actually not that hard to fix.

    **We’re going to leverage four important technologies to help us save and load data in a clean way**:

    - The **`Codable`** protocol, **which will allow us to archive all the existing expense items ready to be stored.**
    - **`UserDefaults`**, which **will let us save and load that archived data.**
    - **A custom initializer for the `Expenses` class, so that when we make an instance of it we load any saved data from `UserDefaults`**
    - A **`didSet`** **property observer on the `items` property of `Expenses`, so that whenever an item gets added or removed we’ll write out changes.**

    Let’s tackle *writing* the data first. We already have this property in the **`Expenses`** class:

    ```swift
    @Published var items: [ExpenseItem]
    ```

    **That’s where we store all the expense item structs that have been created, and that’s also where we’re going to attach our property observer to write out changes as they happen.**

    This takes four steps in total: 

    **we need to create an instance of `JSONEncoder` that will do the work of converting our data to JSON, we ask that to try encoding our `items` array, and then we can write that to `UserDefaults` using the key “Items”.**

    Modify the **`items`** property to this:

    ```swift
    @Published var items: [ExpenseItem] {
        didSet {
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(items) {
                UserDefaults.standard.set(encoded, forKey: "Items")
            }
        }
    }
    ```

    Now, if you’re following along you’ll notice that code doesn’t actually compile. And if you’re following along *closely* you’ll have noticed that I said this process takes *four* steps while only listing three.

    The problem is that the **`encoder.encode()`** method can only archive objects that conform to the **`Codable`** protocol. 

    Remember, **conforming to `Codable` is what asks the compiler to generate code for us able to handle archiving and unarchiving objects, and if we don’t add a conformance for that then our code won’t build.**

    Helpfully, we don’t need to do any work other than add **`Codable`** to **`ExpenseItem`**, like this:

    ```swift
    struct ExpenseItem: Identifiable, Codable {
        let id = UUID()
        let name: String
        let type: String
        let amount: Int
    }
    ```

    **Swift already includes `Codable` conformances for the `UUID`, `String`, and `Int` properties of `ExpenseItem`, and so it’s able to make `ExpenseItem` conform automatically as soon as we ask for it.**

    With that change, we’ve written all the code needed to make sure our items are saved when the user adds them. However, it’s not effective by itself: **the data might be saved, but it isn’t loaded again when the app relaunches.**

    To solve that – and also to make our code compile again – **we need to implement a custom initializer. That will:**

    1. **Attempt to read the “Items” key from `UserDefaults`**.
    2. **Create an instance of `JSONDecoder`, which is the counterpart of `JSONEncoder` that lets us go from JSON data to Swift objects.**
    3. **Ask the decoder to convert the data we received from `UserDefaults` into an array of `ExpenseItem` objects.**
    4. **If that worked, assign the resulting array to `items` and exit.**
    5. **Otherwise, set `items` to be an empty array.**

    Add this initializer to the **`Expenses`** class now:

    ```swift
    init() {
        if let items = UserDefaults.standard.data(forKey: "Items") {
            let decoder = JSONDecoder()
            if let decoded = try? decoder.decode([ExpenseItem].self, from: items) {
                self.items = decoded
                return}
        }

        self.items = []
    }
    ```

    The two key parts of that code are the **`data(forKey: "Items")`** line, **which attempts to read whatever is in “Items” as a `Data` object, and `try? decoder.decode([ExpenseItem].self, from: items)`, which does the actual job of unarchiving the `Data` object into an array of `ExpenseItem` objects.**

    **It’s common to do a bit of a double take when you first see `[ExpenseItem].self` – what does the `.self` mean?** 

    **Well, if we had just used `[ExpenseItem]`, Swift would want to know what we meant – are we trying to make a copy of the class? Were we planning to reference a static property or method? Did we perhaps mean to create an instance of the class?** 

    To avoid confusion – **to say that we mean we’re referring to the type itself, known as the *type object* – we write `.self` after it.**

    Now that we have both loading and saving in place, you should be able to use the app. It’s not finished quite yet, though – let’s add some final polish!

- **Final polish**

    If you try using the app, **you’ll soon see it has two problems:**

    1. **Adding an expense doesn’t dismiss `AddView`; it just stays there.**
    2. **When you add an expense, you can’t actually see any details about it.**

    Before we wrap up this project, let’s fix those to make the whole thing feel a little more polished.

    First, **dismissing `AddView` is done by storing a reference to the view’s presentation mode**, **then calling `dismiss()` on it when the time is right**. 

    **The presentation mode is controlled by the view’s environment, and links to the `isPresented` parameter for our sheet** – **that Boolean gets set to true by us to show `AddView`, but will be flipped back to false by the environment when we call `dismiss()` on the presentation mode.**

    Start by adding this property to **`AddView`**:

    ```swift
    @Environment(\.presentationMode) var presentationMode
    ```

    **You’ll notice we don’t specify a type for that – Swift can figure it out thanks to the `@Environment` property wrapper.**

    Next, **we need to call `presentationMode.wrappedValue.dismiss()` when we want the view to dismiss itself**. 

    **This causes the `showingAddExpense` Boolean in `ContentView` to go back to false**, and hides the **`AddView`**. 

    We already have a Save button in **`AddView`** that creates a new expense item and appends it to our existing expenses, so add this on the line directly after:

    ```swift
    self.presentationMode.wrappedValue.dismiss()
    ```

    That solves the first problem, which just leaves the second: we show the name of each expense item but nothing more. This is because the **`ForEach`** for our list is trivial:

    ```swift
    ForEach(expenses.items) { item inText(item.name)
    }
    ```

    **We’re going to replace that with a stack within another stack, to make sure all the information looks good on screen**. T**he inner stack will be a `VStack` showing the expense name and type, then around that will be a `HStack` with the `VStack` on the left, then a spacer, then the expense amount**. 

    This kind of layout is common on iOS: title and subtitle on the left, and more information on the right.

    Replace the existing **`ForEach`** in **`ContentView`** with this:

    ```swift
    ForEach(expenses.items) { item inHStack {
            VStack(alignment: .leading) {
                Text(item.name)
                    .font(.headline)
                Text(item.type)
            }

            Spacer()
            Text("$\(item.amount)")
        }
    }
    ```

    Now run the program one last time and try it out – we’re done!