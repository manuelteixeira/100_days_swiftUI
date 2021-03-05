# Day 96 - Project 19, part 1

- **Working with two side by side views in SwiftUI**

    One of the most important UI components in UIKit is **`UISplitViewController`**, which you’ll **see in many of Apple’s apps such as Notes, Mail**, and more. 

    **On iPad split views show two views side by side, usually with some a primary list on the left and a detail view on the right**. 

    **On iPhone the split view automatically collapses the two views into one**, so you get **navigation view push-and-pop behavior instead.**

    SwiftUI doesn’t have a direct equivalent for split view controllers, but instead makes the same functionality available through a creative use of **`NavigationView`**. 

    You’re already familiar with the basic usage of **`NavigationView`**, which allows us to create views like this one:

    ```swift
    struct ContentView: View {
    var body: some View {
            NavigationView {
                Text("Hello, World!")
                    .navigationBarTitle("Primary")
            }
        }
    }
    ```

    Previously you’ve seen how that works great in portrait mode, but **in *landscape* mode it results in a blank white screen. This is because of the split view behavior of `NavigationView`**: it’s **designed to work with two views rather than one**, and right now SwiftUI doesn’t seem to care if you only provided one.

    However, **if we *do* provide two views then we get some really useful behavior out of the box.** Try changing your view to this:

    ```swift
    NavigationView {
        Text("Hello, World!")
            .navigationBarTitle("Primary")

        Text("Secondary")
    }
    ```

    When you launch the app now, what you say depends on your device and orientation:

    1. On portrait iPhones you’ll see “Hello, World!”
    2. On large landscape iPhones (such as iPhone 11 Pro Max) you’ll see “Secondary”.
    3. On portrait iPads you’ll also see “Secondary”
    4. On landscape iPads you’ll see both “Hello, World!” and “Secondary” side by side.

    On the second and third of those combinations you’ll find **you can swipe from the left edge of the device to bring up the other view** – “Hello, World!” will partly slide over the top of “Secondary”, and can be dismissed by tapping anywhere in the “Secondary” view. 

    **Having a split view like this is a great way to take advantage of the extra screen space of iPads, while also giving users a faster way to navigate through your content.**

    **SwiftUI automatically links the primary and secondary views, which means if you have a `NavigationLink` in the primary view it will automatically load its content in the secondary view:**

    ```swift
    NavigationView {
        NavigationLink(destination: Text("New secondary")) {
            Text("Hello, World!")
        }
        .navigationBarTitle("Primary")

        Text("Secondary")
    }
    ```

    However, right now at least, all this magic has a few drawbacks that I hope are likely to be fixed in a future SwiftUI update:

    1. Your initial secondary view isn’t given a navigation bar at the top, so even though you’re able to set a title nothing will appear.
    2. Subsequent detail views *always* get a navigation bar whether you want it or not, so you need to use **`navigationBarHidden(true)`** to hide it.
    3. There’s no way of making the primary view stay visible on iPad even when there is more than enough space.
    4. There’s no way of having a Menu button appear in the navigation bar of the secondary view, to make the primary view more discoverable.
    5. You can’t make the primary view shown in landscape by default; SwiftUI always chooses the detail.

    The reason I feel confident these will be fixed in the future is because they are all possible in UIKit with its **`UISplitViewController`**, so hopefully it’s only a matter of time before the same functionality is enabled in SwiftUI.

    **Tip:** **`NavigationView` supports either one or two child views.** Although you can place more in there, the third and subsequent views will be ignored.

- **Using alert() and sheet() with optionals**

    SwiftUI **has two ways of creating alerts and sheets**, and so far we’ve only been using one: **a binding to a Boolean that shows the alert or sheet when the Boolean becomes true**.

    **The *second* option** isn’t used quite so often, but is really useful for the few times you need it: 

    **you can use an optional `Identifiable` object as your condition, and the alert or sheet will be shown when that object has a value**. 

    **The closure for this variety hands you the non-optional value that was used for the condition,** so you can use it safely.

    To demonstrate this, we could create a trivial **`User`** struct that conforms to the **`Identifiable`** protocol:

    ```swift
    struct User: Identifiable {
    	var id = "Taylor Swift"
    }
    ```

    We could then create a property inside **`ContentView`** that tracks which user is selected, set to **`nil`** by default:

    ```swift
    @Stateprivatevar selectedUser: User? = nil
    ```

    Now we can change the **`body`** of **`ContentView`** so that it sets **`selectedUser`** to a value when its text view is tapped, then uses **`alert(item:)`** to **show an alert when `selectedUser` is given a value**:

    ```swift
    Text("Hello, World!")
        .onTapGesture {
    				self.selectedUser = User()
        }
        .alert(item: **$selectedUser**) { **user** in
    				Alert(title: Text(**user**.id))
        }
    ```

    With that simple code, whenever you tap “Hello, World!” an alert saying “Taylor Swift” appears. 

    **As soon as the alert is dismissed, SwiftUI sets `selectedUser` back to `nil`.**

    This might seem like a simple piece of functionality, but **it’s simpler and safer than the alternative**. If we were to rewrite the above code using the old **`.alert(isPresented:)`** modifier it would look like this:

    ```swift
    struct ContentView: View {
        @Stateprivatevar selectedUser: User? = nil
        @Stateprivatevar isShowingAlert = false

    		var body: some View {
            Text("Hello, World!")
                .onTapGesture {
    								self.selectedUser = User()
    								self.isShowingAlert = true
                }
                .alert(isPresented: $isShowingAlert) {
                    Alert(title: Text(selectedUser!.id))
                }
        }
    }
    ```

    **That’s another property, another value to set in the `onTapGesture()`, and a force unwrap in the `alert()` modifier – if you can avoid those things you should.**

- **Using groups as transparent layout containers**

    SwiftUI’s **`Group`** view is commonly used to work around the 10-child view limit, but it also has another important behavior: **it acts as a transparent layout container**. 

    This means **you can create a series of views inside a group, then wrap that group in different stacks to get different behaviors**.

    For example, this **`UserView`** has a **`Group`** containing three text views:

    ```swift
    struct UserView: View {
    		var body: some View {
            Group {
                Text("Name: Paul")
                Text("Country: England")
                Text("Pets: Luna, Arya, and Toby")
            }
        }
    }
    ```

    **That group contains no layout information**, so **we don’t know whether the three text fields will be stacked vertically, horizontally, or by depth.** 

    This is where the transparent layout behavior of **`Group`** becomes important: **whatever parent places a `UserView` gets to decide how its text views get arranged.**

    For example, we could create a **`ContentView`** like this:

    ```swift
    struct ContentView: View {
        @State private var layoutVertically = false

    		var body: some View {
            Group {
    						if layoutVertically {
                    VStack {
                        UserView()
                    }
                } else {
                    HStack {
                        UserView()
                    }
                }
            }
            .onTapGesture {
    						self.layoutVertically.toggle()
            }
        }
    }
    ```

    **That flips between vertical and horizontal layout every time the group is tapped.**

    You might wonder how often you need to have alternative layouts like this, but the answer might surprise you: it’s really common! You see, this is exactly what you want to happen when using size classes, because **you can write code to show horizontal layout when there’s lots of horizontal space, but switch to a vertical layout when space is reduced.**

    So, we could rewrite our previous example like this:

    ```swift
    struct ContentView: View {
        @Environment(\.horizontalSizeClass) var sizeClass

    		var body: some View {
            Group {
    						if sizeClass == .compact {
                    VStack {
                        UserView()
                    }
                } else {
                    HStack {
                        UserView()
                    }
                }
            }
        }
    }
    ```

    **Tip:** In situations like this, **where you have only one view inside a stack and it doesn’t take any parameters, you can pass the view’s initializer directly to the `VStack` to make your code shorter**:

    ```swift
    if sizeClass == .compact {
        VStack(content: UserView.init)
    } else {
        HStack(content: UserView.init)
    }
    ```

    I know short code isn’t everything, but this technique is pleasingly concise when you’re using this approach to grouped view layout.