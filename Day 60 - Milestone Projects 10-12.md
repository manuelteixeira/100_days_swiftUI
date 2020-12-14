# Day 60 - Milestone: Projects 10-12

- **Key points**

    # **Key points**

    Although we’ve covered a lot in these last three projects, there are two things in particular I’d like to cover in more detail: type erasure and **`Codable`**. We already looked at these a little in our projects, but they deserve some additional time as you’ll see…

    ## **AnyView vs Group: type erasure in practice**

    SwiftUI’s views have only one requirement, which is that they have a **`body`** property that returns some specific sort of view. As we looked at in an earlier technique project, specifying the precise return type is painful because of the way SwiftUI builds containers when we apply modifiers, which is why we have **`some View`** – “this will return one specific sort of view, but we don’t want to say what.”

    However, this has a downside: we can’t dynamically determine the type of view we return. This means we can’t return a text view sometimes and an image other times, but thanks to the way SwiftUI wraps views with modifier containers it even means we can’t mix and match many modifiers. For example, this kind of code isn’t valid:

    ```swift
    struct ContentView: View {
        var body: some View {
            if Bool.random() {
                return Text("Hello, World!")
                    .frame(width: 300)
            } else {
                return Text("Hello, World!")
            }
        }
    }
    ```

    One way we can solve this is using *type erasure*, which is the process of hiding the underlying type of some data. This is used often in Swift: we have type erasing wrappers such as **`AnyHashable`** and **`AnySequence`**, and all they do is act as shells that forward on their operations to whatever they contain, without revealing what the contents are to anything externally.

    In SwiftUI we have **`AnyView`** for this purpose: it can hold any kind of view inside it, which allows us to mix and match views freely, like this:

    ```swift
    struct ContentView: View {
        var body: some View {
            if Bool.random() {
                return AnyView(Text("Hello, World!")
                    .frame(width: 300))
            } else {
                return AnyView(Text("Hello, World!"))
            }
        }
    }
    ```

    However, there is a performance cost to using **`AnyView`**: by hiding the way our views are structured, we’re forcing SwiftUI to do a lot more work when our view hierarchy changes – if we make one small change SwiftUI inside one of the type erased parts of our view hierarchy, there’s a good chance it will need to recreate the entire thing.

    There’s an alternative here, and although it’s not a true alternative for everything **`AnyView`** offers it’s still worth using a lot of the time. The alternative is to use a container such as **`Group`** like this:

    ```swift
    struct ContentView: View {
        var body: some View {
            Group {
                if Bool.random() {
                    Text("Hello, World!")
                        .frame(width: 300)
                } else {
                    Text("Hello, World!")
                }
            }
        }
    }
    ```

    Even though that has a condition returning either a text view or a modified text view, both are wrapped inside a group and so **`some View`** has its requirement satisfied.

    Of course, the question that should arise is: why not use groups everywhere? In theory – *in theory* – using **`Group`** should always be faster, because it doesn’t hide information from SwiftUI, which in turn means it can avoid doing extra work if you’re regularly changing view hierarchies.

    In practice, this feels to me like a case of premature optimization: I’d be surprised if you were hitting performance problems when using **`AnyView`**, and if you did you can migrate at that point rather than trying to plan ahead. Realistically, the most important thing your code can do is convey your intent, and to me groups are used for:

    1. Breaking through the 10-child view limit: each group can have ten children of its own, so you can have groups inside groups to create much more complex layouts
    2. Delegating layout to a parent container. If you make a custom view that has a group as the top-level thing in its body, you can embed that view inside a **`HStack`** or a **`VStack`** to dynamically change its layout.
    3. Letting us apply one set of modifiers to many views at once.

    On the other hand, **`AnyView`** is specifically there for type erasure, so when you see it in action you immediately know it’s there for a reason.

    There are also times when **`Group`** simply won’t cut it because it doesn’t have the type erasing powers of **`AnyView`**. For example, you can’t make an array of groups, because **`[Group]`** by itself has no meaning – SwiftUI wants to know what’s *in* the group. On the other hand, **`[AnyView]`** is perfectly fine, because the point of **`AnyView`** is that the contents don’t matter.

    So, this kind of code is only possible with actual type erasure:

    ```swift
    struct ContentView: View {
        @State var views = [AnyView]()

        var body: some View {
            VStack {
                Button("Add Shape") {
                    if Bool.random() {
                        self.views.append(AnyView(Circle().frame(height: 50)))
                    } else {
                        self.views.append(AnyView(Rectangle().frame(width: 50)))
                    }
                }

                ForEach(0..<views.count, id: \.self) {
                    self.views[$0]
                }

                Spacer()
            }
        }
    }
    ```

    Every time you tap the button a shape gets added to the array, but because both **`Shape`** and **`Group`** are meaningless the array must be typed **`[AnyView]`**.

    If you intend to use type erasure regularly, it’s worth adding this convenience extension:

    ```swift
    extension View {
        func erasedToAnyView() -> AnyView {
            AnyView(self)
        }
    }
    ```

    With this approach we can treat **`erasedToAnyView()`** like a modifier:

    ```swift
    Text("Hello World")
        .font(.title)
        .erasedToAnyView()    
    ```

    As SwiftUI continue to develop I’m hoping we’ll get a clearer picture of the times where **`Group`** has a meaningful performance improvement over **`AnyView`**, but right now it feels a bit too much like cargo cult programming for my liking.

    ## **Codable keys**

    When we have JSON data that matches the way we’ve designed our types, **`Codable`** works perfectly. In fact, if we don’t use property wrappers such as **`@Published`**, we often don’t need to do anything other than add **`Codable`** conformance – the Swift compiler will synthesize everything we need automatically.

    However, a lot of the time things aren’t so straightforward. In these situations we might need to write custom **`Codable`** conformance – i.e., writing **`init(from:)`** and **`encode(to:)`** by hand – but there is a middle ground where, with some guidance, **`Codable`** can still do most of the work for us.

    One common example of this is where our incoming JSON using a different naming convention for its properties. For example, we might receive JSON property names in snake case (e.g. **`first_name`**) whereas our Swift code uses property names in camel case (e.g. **`firstName`**). **`Codable`** is able to translate between these two as long as it knows what to expect – we need to set a property on our decoder called **`keyDecodingStrategy`**.

    To demonstrate this, here’s a **`User`** struct with two properties:

    ```swift
    struct User: Codable {
        var firstName: String
        var lastName: String
    }
    ```

    And here is some JSON data with the same two properties, but using snake case:

    ```swift
    let str = """
    {
        "first_name": "Andrew",
        "last_name": "Glouberman"
    }
    """

    let data = Data(str.utf8)
    ```

    If we try to decode that JSON into a **`User`** instance, it won’t work:

    ```swift
    do {
        let decoder = JSONDecoder()

        let user = try decoder.decode(User.self, from: data)
        print("Hi, I'm \(user.firstName) \(user.lastName)")
    } catch {
        print("Whoops: \(error.localizedDescription)")
    } 
    ```

    However, if we modify the key decoding strategy before we call **`decode()`**, we can ask Swift to convert snake case to and from camel case. So, this will succeed:

    ```swift
    do {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        let user = try decoder.decode(User.self, from: data)
        print("Hi, I'm \(user.firstName) \(user.lastName)")
    } catch {
        print("Whoops: \(error.localizedDescription)")
    } 
    ```

    That works great when we’re converting snake_case to and from camelCase, but what if our data is completely different?

    As an example, take a look at this JSON:

    ```swift
    let str = """
    {
        "first": "Andrew",
        "last": "Glouberman"
    }
    """
    ```

    It still has the first and last name of a user, but the property names don’t match our struct at all.

    When we were looking at **`Codable`** I said that we can create an enum of coding keys that describe which keys should be encoded and decoded. At the time I said “this enum is conventionally called **`CodingKeys`**, with an S on the end, but you can call it something else if you want,” and while that’s true it’s not the whole story.

    You see, the reason we conventionally use **`CodingKeys`** for the name is that this name has super powers: if a **`CodingKeys`** enum exists, Swift will automatically use it to decide how to encode and decode an object for times we don’t provide custom **`Codable`** implementations.

    I realize that’s a lot to take in, so it’s best demonstrated with some code. Try changing the **`User`** struct to this:

    ```swift
    struct User: Codable {
        enum ZZZCodingKeys: CodingKey {
            case firstName
        }

        var firstName: String
        var lastName: String
    }
    ```

    That code will compile just fine, because the name **`ZZZCodingKeys`** is meaningless to Swift – it’s just a nested enum. But if you rename the enum to just **`CodingKeys`** you’ll find the code no longer builds: we’re now instructing Swift to encode and decode just the **`firstName`** property, which means there is no initializer that handles setting the **`lastName`** property - and that’s not allowed.

    All this matters because **`CodingKeys`** has a second super power: if we attach raw value strings to our properties, Swift will use those for the JSON property names. That is, the case names should match our Swift property names, and the case *values* should match the JSON property names.

    So, let’s return to our example JSON:

    ```swift
    let str = """
    {
        "first": "Andrew",
        "last": "Glouberman"
    }
    """
    ```

    That uses “first” and “last” for property names, whereas our **`User`** struct uses **`firstName`** and **`lastName`**. This is a great place where **`CodingKeys`** can come to the rescue: we don’t need to write a custom **`Codable`** conformance, because we can just add coding keys that marry up our Swift property names to the JSON property names, like this:

    ```swift
    struct User: Codable {
        enum CodingKeys: String, CodingKey {
            case firstName = "first"
            case lastName = "last"
        }

        var firstName: String
        var lastName: String
    }
    ```

    Now that we have specifically told Swift how to convert between JSON and Swift naming, we no longer need to use **`keyDecodingStrategy`** – just adding that enum is enough.

    So, while you *do* need to know how to create custom **`Codable`** conformance, it’s generally best practice to do without it if these other options are possible.

- **Challenge**

    It’s time for you to build an app from scratch, and it’s a particularly expansive challenge today: your job is to use **`URLSession`** to download some JSON from the internet, use **`Codable`** to convert it to Swift types, then use **`NavigationView`**, **`List`**, and more to display it to the user.

    Your first step should be to examine the JSON. The URL you want to use is this: [https://www.hackingwithswift.com/samples/friendface.json](https://www.hackingwithswift.com/samples/friendface.json) – that’s a massive collection of randomly generated data for example users.

    As you can see, there is an array of people, and each person has an ID, name, age, email address, and more. They also have an array of tag strings, and an array of friends, where each friend has a name and ID.

    How far you implement this is down to you, but at the very least you should:

    - [x]  Fetch the data and parse it into **`User`** and **`Friend`** structs.
    - [ ]  Display a list of users with a little information about them.
    - [ ]  Create a detail view shown when a user is tapped, presenting more information about them.

    **Where things get more interesting is with their friends: if you really want to push your skills, think about how to show each user’s friends on the detail screen.**

    **For a medium-sized challenge, show a little information about their friends right on the detail screen. For a bigger challenge, make each of those friends tappable to show their own detail view.**

    Even though there’s a lot of data, we’re only working with 100 friends at a time – using something like **`first(where:)`** to find friends in the array is perfectly fine.

    If you’re not sure where to begin, start by designing your types: build a **`User`** struct with properties for **`name`**, **`age`**, **`company`**, and so on, then a **`Friend`** struct with **`id`** and **`name`**. After that, move onto some **`URLSession`** code to fetch the data and decode it into your types.

    While you’re building this, I want you to keep one thing in mind: this kind of app is the bread and butter” of iOS app development – if you can nail this with confidence, you’re well on your way to a full-time job as an app developer.