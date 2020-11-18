# Day 51 - Project 10, part 3

- **Encoding an ObservableObject class**

    **We’ve organized our code so that we have one `Order` object that gets shared between all our screens**, which **has the advantage that we can move back and forward between those screens without losing data**. **However, this approach comes with a cost: we’ve had to use the `@Published` property wrapper for the properties in the class, and as soon we did that we lost support for automatic `Codable` conformance.**

    If you don’t believe me, just try modifying the definition of **`Order`** to include **`Codable`**, like this:

    ```swift
    class Order: ObservableObject, Codable {
    ```

    **The build will now fail, because Swift doesn’t understand how to encode and decode published properties**. 

    This is a problem, because we want to submit the user’s order to an internet server, which means we need it as JSON – we *need* the **`Codable`** protocol to work.

    **The fix here is to add `Codable` conformance by hand, which means telling Swift what should be encoded, how it should be encoded, and also how it should be *decoded*** – converted back from JSON to Swift data.

    That **first step means adding an enum that conforms to `CodingKey`, listing all the properties we want to save**. 

    In our **`Order`** class that’s almost everything – the only thing we don’t need is the static **`types`** property.

    So, add this enum to **`Order`** now:

    ```swift
    enum CodingKeys: CodingKey {
        case type, quantity, extraFrosting, addSprinkles, name, streetAddress, city, zip
    }
    ```

    The **second step requires us to write an `encode(to:)` method that creates a container using the coding keys enum we just created, then writes out all the properties attached to their respective key**. 

    This is just a matter of calling **`encode(_:forKey:)`** repeatedly, each time passing in a different property and coding key.

    Add this method to **`Order`** now:

    ```swift
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(type, forKey: .type)
        try container.encode(quantity, forKey: .quantity)

        try container.encode(extraFrosting, forKey: .extraFrosting)
        try container.encode(addSprinkles, forKey: .addSprinkles)

        try container.encode(name, forKey: .name)
        try container.encode(streetAddress, forKey: .streetAddress)
        try container.encode(city, forKey: .city)
        try container.encode(zip, forKey: .zip)
    }
    ```

    **Because that method is marked with `throws`, we don’t need to worry about catching any of the errors that are thrown inside** – we can just use **`try`** without adding **`catch`**, knowing that **any problems will automatically propagate upwards and be handled elsewhere.**

    Our **final step is to implement a required initializer to decode an instance of `Order` from some archived data**. This is pretty much the reverse of encoding, and even benefits from the same **`throws`** functionality:

    ```swift
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        type = try container.decode(Int.self, forKey: .type)
        quantity = try container.decode(Int.self, forKey: .quantity)

        extraFrosting = try container.decode(Bool.self, forKey: .extraFrosting)
        addSprinkles = try container.decode(Bool.self, forKey: .addSprinkles)

        name = try container.decode(String.self, forKey: .name)
        streetAddress = try container.decode(String.self, forKey: .streetAddress)
        city = try container.decode(String.self, forKey: .city)
        zip = try container.decode(String.self, forKey: .zip)
    }
    ```

    It’s worth adding here that you can encode your data in any order you want – you don’t need to match the order in which properties are declared in your object.

    **That makes our code fully `Codable` compliant**: we’ve effectively bypassed the **`@Published`** property wrapper, reading and writing the values directly. However, it doesn’t make our code compile – in fact, we now get a **completely** different error back in ContentView.swift.

    **The problem *now* is that we just created a custom initializer for our `Order` class, `init(from:)`, and Swift wants us to use it everywhere** 

    – even in places where we just want to create a new empty order because the app just started.

    Fortunately, **Swift lets us add multiple initializers to a class, so that we can create it in any number of different ways. In this situation, that means we need to write a new initializer that can create an order without any data whatsoever – it will rely entirely on the default property values we assigned.**

    So, add this new initializer to **`Order`** now:

    ```swift
    init() { }
    ```

    Now our code is back to compiling, and our **`Codable`** conformance is complete. This means we’re ready for the final step: sending and receiving **`Order`** objects over the network.

- **Sending and receiving orders over the internet**

    iOS comes with some fantastic functionality for handling networking, and in particular the **`URLSession`** class makes it surprisingly easy to send and receive data. 

    If we combine that with **`Codable`** to convert Swift objects to and from JSON, and **`URLRequest`**, which lets us configure exactly how data should be sent, we can accomplish great things in about 20 lines of code.

    First, let’s create a method we can call from our Place Order button – add this to **`CheckoutView`**:

    ```swift
    func placeOrder() {
    }
    ```

    Now modify the Place Order button to this:

    ```swift
    Button("Place Order") {
        self.placeOrder()
    }
    .padding()
    ```

    Inside **`placeOrder()`** we need to do three things:

    1. **Convert our current `order` object into some JSON** data that can be sent.
    2. **Prepare a `URLRequest` to send our encoded data as JSON.**
    3. **Run that request and process the response.**

    **The first of those is straightforward**, so let’s get it out of the way. We’ve made the **`Order`** class conform to **`Codable`**, which means we can **use `JSONEncoder` to archive it** by adding this code to `placeOrder()`:

    ```swift
    guard let encoded = try? JSONEncoder().encode(order) else {
        print("Failed to encode order")
        return}
    ```

    **The second step** – preparing a **`URLRequest`** to send our data – requires some more thought. 

    You see, **we need to attach the data in a very specific way so that the server can process it correctly, which means we need to provide two extra pieces of data beyond just our order**:

    1. **The HTTP method of a request determines how data should be sent**. There are several HTTP methods, but in practice only GET (“I want to read data”) and POST (“I want to write data”) are used much. We want to write data here, so we’ll be using POST.
    2. **The content type of a request determines what kind of data is being sent, which affects the way the server treats our data**. This is specified in what’s **called a MIME type**, which was originally made for sending attachments in emails, and it has several thousand highly specific options.

    So, **the next code for `placeOrder()` will be to create a `URLRequest`, configure it to send JSON data using a HTTP POST, and attach our data.**

    Of course, the *real* question is *where* to send our request, and I don’t think you really want to set up your own web server in order to follow this tutorial. 

    So, instead we’re going to use a really **helpful website called [https://reqres.in](https://reqres.in/) – it lets us send any data we want, and will automatically send it back. This is a great way of prototyping network code, because you’ll get real data back from whatever you send.**

    Add this code to **`placeOrder()`** now:

    ```swift
    let url = URL(string: "https://reqres.in/api/cupcakes")!
    var request = URLRequest(url: url)
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpMethod = "POST"
    request.httpBody = encoded
    ```

    Notice how I added a force unwrap for the **`URL(string:)`** initializer. Creating URLs from strings might fail because you inserted some gibberish, but here I hand-typed the URL so I can see it’s always going to be correct – there are no string interpolations in there that might cause problems.

    **At this point we’re all set to make our network request, which we’ll do using `URLSession.shared.dataTask()` and the URL request we just made**. 

    Remember, if you don’t call **`resume()`** on your data task it won’t ever start, which is why I nearly always write the task and call resume before actually filling in the body.

    So, go ahead and add this to **`placeOrder()`**:

    ```swift
    URLSession.shared.dataTask(with: request) { data, response, error in// handle the result here.
    }.resume()
    ```

    Now for the important work: **we need to read the result our request. If something went wrong – perhaps because there was no internet connection – we’ll just print a message and return.**

    Add this to **`placeOrder()`**:

    ```swift
    guard let data = data else {
        print("No data in response: \(error?.localizedDescription ?? "Unknown error").")
        return}
    ```

    **If we make it past that, it means we got some sort of data back from the server**. 

    **Because we’re using the ReqRes.in, we’ll actually get back to the same order we sent, which means we can use `JSONDecoder` to convert that back from JSON to an object.**

    **To confirm everything worked correctly we’re going to show an alert containing some details of our order, but we’re going to use the *decoded* order we got back from ReqRes.in**.

    Yes, this ought to be identical to the one we sent, so if it *isn’t* it means we made a mistake in our coding.

    **Showing an alert requires properties to store the message and whether it’s visible or not**, so please add these two new properties to **`CheckoutView`** now:

    ```swift
    @State private var confirmationMessage = ""
    @State private var showingConfirmation = false
    ```

    We also need to attach an **`alert()`** modifier to watch that Boolean, and show an alert as soon as its true. Add this modifier to the **`GeometryReader`** in **`CheckoutView`**:

    ```swift
    .alert(isPresented: $showingConfirmation) {
        Alert(title: Text("Thank you!"), message: Text(confirmationMessage), dismissButton: .default(Text("OK")))
    }
    ```

    And now we can finish off our networking code: **we’ll decode the data that came back, use it to set our confirmation message property, then set `showingConfirmation` to true so the alert appears.** 

    **If the decoding fails – if the server sent back something that wasn’t an order for some reason – we’ll just print an error message.**

    Add this final code to **`placeOrder()`**, just inside the completion closure for **`dataTask(with:)`**:

    ```swift
    if let decodedOrder = try? JSONDecoder().decode(Order.self, from: data) {
        self.confirmationMessage = "Your order for \(decodedOrder.quantity)x \(Order.types[decodedOrder.type].lowercased()) cupcakes is on its way!"
        self.showingConfirmation = true
    } else {
        print("Invalid response from server")
    }
    ```

    With that final code in place our networking code is complete, and in fact our app is complete too. If you try running it now you should be able to select the exact cakes you want, enter your delivery information, then press Place Order to see an alert appear!

    We’re done! Well, *I’m* done – you still have some challenges to complete!