# Day 50 - Project 10, part 2

- **Taking basic order details**

    **The first step in this project will be to create an ordering screen that takes the basic details of an order**: how many cupcakes they want, what kind they want, and whether there are any special customizations.

    Before we get into the UI, **we need to start by defining the data model**. 

    Previously **we’ve used `@State` for simple value types and `@ObservedObject` for reference types**, **and we’ve looked at how it’s possible to have an `ObservableObject` class containing structs inside it so that we get the benefits of both**.

    **Here we’re going to take a different solution: we’re going to have a single class that stores all our data**, which will be passed from screen to screen. **This means all screens in our app share the same data**, which will work really well as you’ll see.

    For now this class won’t need many properties:

    - **The type of cakes, plus a static array of all possible options.**
    - **How many cakes the user wants to order.**
    - **Whether the user wants to make special requests, which will show or hide extra options in our UI.**
    - **Whether the user wants extra frosting on their cakes.**
    - **Whether the user wants to add sprinkles on their cakes.**

    **Each of those need to update the UI when changed**, **which means we need to mark them with `@Published`** and **make the whole class conform to `ObservableObject`**.

    So, please make a new Swift file called Order.swift, change its Foundation import for SwiftUI, and give it this code:

    ```swift
    class Order: ObservableObject {
        static let types = ["Vanilla", "Strawberry", "Chocolate", "Rainbow"]

        @Published var type = 0
        @Published var quantity = 3

        @Published var specialRequestEnabled = false
        @Published var extraFrosting = false
        @Published var addSprinkles = false
    }
    ```

    We can now create a single instance of that inside **`ContentView`** by adding this property:

    ```swift
    @ObservedObject var order = Order()
    ```

    **That’s the only place the order will be created – every other screen in our app will be passed that property so they all work with the same data.**

    We’re going to **build the UI for this screen in three sections**, starting with cupcake type and quantity. 

    This **first section will show a picker** letting users choose from Vanilla, Strawberry, Chocolate and Rainbow cakes, **then a stepper with the range 3 through 20 to choose the amount**. **All that will be wrapped inside a form**, **which is itself inside a navigation view so we can set a title.**

    Put this into the body of **`ContentView`** now:

    ```swift
    NavigationView {
        Form {
            Section {
                Picker("Select your cake type", selection: $order.type) {
                    ForEach(0..<Order.types.count) {
                        Text(Order.types[$0])
                    }
                }

                Stepper(value: $order.quantity, in: 3...20) {
                    Text("Number of cakes: \(order.quantity)")
                }
            }
        }
        .navigationBarTitle("Cupcake Corner")
    }
    ```

    Before we add the second and third sections, I’d like you to build and run the code, then try it out. Our two form fields should work fine, but you might – *might* – see a regular annoying message in Xcode about our **`ForEach`**: “count (4) != its initial count (1)”.

    I say *might* because this feels like another SwiftUI bug: even though our **`ForEach`** *is* using fixed data (i.e., the number of items in the **`Order.types`** array), SwiftUI seems to be having a hard time working with it. If you don’t see the error you have nothing to worry about, but if you *do* see it then I want to show you how to resolve it: we need to give it an explicit identifier.

    So, modify your **`ForEach`** to this:

    ```
    ForEach(0..<Order.types.count, id: \.self) {
    ```

    That clears up the problem entirely, but honestly I’m hoping this error will just go away in a future SwiftUI update.

    The **second section of our form will hold three toggle switches bound** to **`specialRequestEnabled`**, **`extraFrosting`**, and **`addSprinkles`** respectively. 

    **However, the second and third switches should only be visible when the first one is enabled**, so we’ll wrap then in a condition.

    Add this second section now:

    ```swift
    Section {
        Toggle(isOn: $order.specialRequestEnabled.animation()) {
            Text("Any special requests?")
        }

        if order.specialRequestEnabled {
            Toggle(isOn: $order.extraFrosting) {
                Text("Add extra frosting")
            }

            Toggle(isOn: $order.addSprinkles) {
                Text("Add extra sprinkles")
            }
        }
    }
    ```

    Go ahead and run the app again, and try it out – **notice how I bound the first toggle with an `animation()` modifier attached, so that the second and third toggles slide in and out smoothly.**

    However, **there’s another bug**, and this time it’s one of our own making: if we enable special requests then enable one or both of “extra frosting” and “extra sprinkles”, then *disable* the special requests, our previous special request selection stays active. **This means if we re-enable special requests, the previous special requests are still active.**

    This kind of problem isn’t hard to work around if every layer of your code is aware of it – if the app, your server, your database, and so on are all programmed to ignore the values of **`extraFrosting`** and **`addSprinkles`** when **`specialRequestEnabled`** is set to false. 

    However, a better idea – a *safer* idea – **is to make sure that both `extraFrosting` and `addSprinkles` are reset to false when `specialRequestEnabled` is set to false.**

    **We can make this happen by adding a `didSet` property observer to `specialRequestEnabled`. Add this now:**

    ```swift
    @Published var specialRequestEnabled = false {
        didSet {
            if specialRequestEnabled == false {
                extraFrosting = false
                addSprinkles = false
            }
        }
    }
    ```

    Our **third section** is the easiest, because it’s **just going to be a `NavigationLink` pointing to the next screen**. 

    We don’t have a second screen, but we can add it quickly enough: create a new SwiftUI view called “AddressView”, and give it an **`order`** observed object property like this:

    ```swift
    struct AddressView: View {
        @ObservedObject var order: Order

        var body: some View {
            Text("Hello World")
        }
    }

    struct AddressView_Previews: PreviewProvider {
        static var previews: some View {
            AddressView(order: Order())
        }
    }
    ```

    We’ll make that more useful shortly, but for now it means we can return to ContentView.swift and add the final section for our form. **This will create a `NavigationLink` that points to an `AddressView`, passing in the current order object.**

    Please add this final section now:

    ```swift
    Section {
        NavigationLink(destination: AddressView(order: order)) {
            Text("Delivery details")
        }
    }
    ```

    That completes our first screen, so give it a try one last time before we move on – you should be able to select your cake type, choose a quantity, and toggle all the switches just fine.

- **Checking for a valid address**

    The **second step in our project will be to let the user enter their address into a form**, **but as part of that we’re going to add some validation** – **we only want to proceed to the third step if their address looks good.**

    We can accomplish this by adding a **`Form`** view to the **`AddressView`** struct we made previously, which will contain four text fields: name, street address, city, and zip. We can then add a **`NavigationLink`** to move to the next screen, which is where the user will see their final price and can check out.

    To make this easier to follow, **we’re going to start by adding a new view called** **`CheckoutView`**, **which is where this address view will push to once the user is ready**. This just avoids us having to put a placeholder in now then remember to come back later.

    So, create a new SwiftUI view called **`CheckoutView`** and give it the same **`Order`** observed object property and preview that **`AddressView`** has:

    ```swift
    struct CheckoutView: View {
        @ObservedObject var order: Order

        var body: some View {
            Text("Hello, World!")
        }
    }

    struct CheckoutView_Previews: PreviewProvider {
        static var previews: some View {
            CheckoutView(order: Order())
        }
    }
    ```

    Again, we’ll come back to that later, but first let’s implement **`AddressView`**. Like I said, this needs to have a form with four text fields bound to four properties from our **`Order`** object, plus a **`NavigationLink`** passing control off to our check out view.

    First, **we need four new `@Published` properties in `Order` to store delivery details**:

    ```swift
    @Published var name = ""
    @Published var streetAddress = ""
    @Published var city = ""
    @Published var zip = ""
    ```

    Now replace the existing **`body`** of **`AddressView`** with this:

    ```swift
    Form {
        Section {
            TextField("Name", text: $order.name)
            TextField("Street Address", text: $order.streetAddress)
            TextField("City", text: $order.city)
            TextField("Zip", text: $order.zip)
        }

        Section {
            NavigationLink(destination: CheckoutView(order: order)) {
                Text("Check out")
            }
        }
    }
    .navigationBarTitle("Delivery details", displayMode: .inline)
    ```

    As you can see, **that passes our `order` object on one level deeper, to `CheckoutView`, which means we now have three views pointing to the same data.**

    Go ahead and run the app again, because I want you to see why all this matters. 

    Enter some data on the first screen, enter some data on the second screen, then try navigating back to the beginning then forward to the end – that is, go back to the first screen, then click the bottom button twice to get to the checkout view again.

    What you should see is that **all the data you entered stays saved no matter what screen you’re on**. Yes, **this is the natural side effect of using a class for our data**, but it’s an instant feature in our app without having to do any work – 

    **if we had used a struct, then any address details we had entered would disappear if we moved back to the original view**. 

    If you really wanted to use a struct for your data, you should follow the same struct inside class approach we used back in project 7; it’s certainly worth keeping it in mind when you evaluate your options.

    Now that **`AddressView`** works, **it’s time to stop the user progressing to the checkout unless some condition is satisfied**. What condition? Well, that’s down to us to decide. Although we *could* write length checks for each of our four text fields, this often trips people up – some names are only four or five letters, so if you try to add length validation you might accidentally exclude people.

    So, instead **we’re just going to check that the `name`, `streetAddress`, `city`, and `zip` properties of our order aren’t empty**. 

    I prefer adding this kind of complex check inside my data, which means you need to **add a new computed property** to **`Order`** like this one:

    ```swift
    var hasValidAddress: Bool {
        if name.isEmpty || streetAddress.isEmpty || city.isEmpty || zip.isEmpty {
            return false
        }

        return true
    }
    ```

    **We can now use that condition in conjunction with SwiftUI’s `disabled()` modifier** – **attach that to any view along with a condition to check, and the view will stop responding to user interaction if the condition is true.**

    In our case, the condition we want to check is the computed property we just wrote, **`hasValidAddress`**. If that is false, then the form section containing our **`NavigationLink`** ought to be disabled, because we need users to fill in their delivery details first.

    So, add this modifier to the end of the second section in **`AddressView`**:

    ```swift
    .disabled(order.hasValidAddress == false)
    ```

    The code should look like this:

    ```swift
    Section {
        NavigationLink(destination: CheckoutView(order: order)) {
            Text("Check out")
        }
    }
    .disabled(order.hasValidAddress == false)
    ```

    Now if you run the app you’ll see that all four address fields must contain at least one character in order to continue. Even better, SwiftUI automatically grays out the button when the condition isn’t true, giving the user really clear feedback when it is and isn’t interactive.

- **Preparing for checkout**

    The final screen in our app is **`CheckoutView`**, and it’s really a tale of two halves: **the first half is the basic user interface, which should provide little real challenge for you; but the second half is all new: we need to encode our `Order` class to JSON, send it over the internet, and get a response.**

    We’re going to look at the whole encoding and transferring chunk of work soon enough, but first let’s tackle the easy part: giving **`CheckoutView`** a user interface. More specifically, **we’re going to create a `ScrollView` with an image, the total price of their order, and a Place Order button to kick off the networking.**

    For the image, I’ve provided two images in the files for this project, available from [https://github.com/twostraws/HackingWithSwift](https://github.com/twostraws/HackingWithSwift). Look in the SwiftUI/project10-files folder, and copy both cupcakes@2x.jpg and cupcakes@3x.jpg into your asset catalog. 

    **We’ll need to use `GeometryReader` to size this picture to the correct width of the screen, to avoid it stretching layouts on smaller devices.**

    **As for the order cost**, we don’t actually have any pricing for our cupcakes in our data, so we can just invent one – it’s not like we’re actually going to be charging people here. **The pricing we’re going to use is as follows:**

    - **There’s a base cost of $2 per cupcake.**
    - **We’ll add a little to the cost for more complicated cakes.**
    - **Extra frosting will cost $1 per cake.**
    - **Adding sprinkles will be another 50 cents per cake.**

    We can **wrap all that logic up in a new computed property for** **`Order`**, like this:

    ```swift
    var cost: Double {
        // $2 per cake
        var cost = Double(quantity) * 2

        // complicated cakes cost more
        cost += (Double(type) / 2)

        // $1/cake for extra frosting
        if extraFrosting {
            cost += Double(quantity)
        }

        // $0.50/cake for sprinkles
        if addSprinkles {
            cost += Double(quantity) / 2
        }

        return cost
    }
    ```

    The actual view itself is straightforward: **we’ll use a `GeometryReader` to make sure our cupcake image is sized correctly, a `VStack` inside a vertical `ScrollView`, then our image, the cost text, and button to place the order.**

    We’ll be filling in the button’s action in a minute, but first let’s get the basic layout done – replace the existing **`body`** of **`CheckoutView`** with this:

    ```swift
    GeometryReader { geo inScrollView {
            VStack {
                Image("cupcakes")
                    .resizable()
                    .scaledToFit()
                    .frame(width: geo.size.width)

                Text("Your total is $\(self.order.cost, specifier: "%.2f")")
                    .font(.title)

                Button("Place Order") {
                    // place the order
                }
                .padding()
            }
        }
    }
    .navigationBarTitle("Check out", displayMode: .inline)
    ```

    That should all be old news for you by now. But the tricky part comes next…