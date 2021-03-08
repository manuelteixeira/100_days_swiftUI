# Day 97 - Project 19, part 2

- **Building a primary list of items**

    **In this app we’re going to display two views side by side**, just like Apple’s Mail and Notes apps. 

    In SwiftUI **this is done by placing two views into a `NavigationView`, then using a `NavigationLink` in the primary view to control what’s visible in the secondary view.**

    So, we’re going to start off our project by building the primary view for our app, which will show a list of all ski resorts, along with which country they are from and how many ski runs it has – how many pistes you can ski down, sometimes called “trails” or just “slopes”.

    I’ve provided some assets for this project in the GitHub repository for this book, so if you haven’t already downloaded them please do so now. You should drag resorts.json into your project navigator, then copy all the pictures into your asset catalog. You might notice that I’ve included 2x and 3x images for the countries, but only 2x pictures for the resorts. This is intentional: those flags are going to be used for both retina and Super Retina devices, but the resort pictures are designed to fill all the space on an iPad Pro – they are more than big enough for a Super Retina iPhone even at 2x resolution.

    To get our list up and running quickly, **we need to define a simple `Resort` struct that can be loaded from our JSON.** That means **it needs to conform to `Codable`, but to make it easier to use in SwiftUI we’ll also make it conform to `Identifiable`**. 

    The actual data itself is mostly just strings and integers, but there’s also a string array called **`facilities`** that describe what else there is on the resort – I should add that this data is mostly fictional, so don’t try to use it in a real app!

    Create a new Swift file called Resort.swift, then give it this code:

    ```swift
    struct Resort: Codable, Identifiable {
    	let id: String
    	let name: String
    	let country: String
    	let description: String
    	let imageCredit: String
    	let price: Int
    	let size: Int
    	let snowDepth: Int
    	let elevation: Int
    	let runs: Int
    	let facilities: [String]
    }
    ```

    As usual, **it’s a good idea to add an example value to your model so that it’s easier to show working data in your designs**. This time, though, there are quite a few fields to work with and it’s helpful if they have real data, so I don’t really want to create one by hand.

    Instead, we have two options. 

    The **first option is to add two static properties: one to load all resorts into an array, and one to store the first item in that array**, like this:

    ```swift
    static let allResorts: [Resort] = Bundle.main.decode("resorts.json")
    static let example = allResorts[0]
    ```

    The **second is to collapse all that down to a single line of code**. 

    This requires a little bit of gentle typecasting because our **`decode()`** extension method needs to know what type of data it’s decoding:

    ```swift
    static let example = (Bundle.main.decode("resorts.json")as [Resort])[0]
    ```

    Of the two, **I prefer the first option because it’s simpler and has a little more use if we wanted to show random examples rather than the same one again and again**. 

    In case you were curious, **when we use `static let` for properties, Swift automatically makes them lazy – they don’t get created until they are used**. 

    **This means when we try to read `Resort.example` Swift will be forced to create `Resort.allResorts` first, then send back the first item in that array for `Resort.example`.** 

    This means **we can always be sure the two properties will be run in the correct order** – there’s no chance of **`example`** going missing because **`allResorts`** wasn’t called yet.

    We want to load an array of resorts from JSON stored in our app bundle, which means we can re-use the same code we wrote for project 8 – the Bundle-Decodable.swift extension. If you have yours to hand you can drop it into your new project, but if not then create a new Swift file called Bundle-Decodable.swift and give it this code:

    ```swift
    extension Bundle {
    func decode<T: Decodable>(_ file: String) -> T {
    				guard let url = self.url(forResource: file, withExtension: nil) else {
                fatalError("Failed to locate \(file) in bundle.")
            }

    				guard let data = try? Data(contentsOf: url)else {
                fatalError("Failed to load \(file) from bundle.")
            }

    				let decoder = JSONDecoder()

    				guard let loaded = try? decoder.decode(T.self, from: data) else {
                fatalError("Failed to decode \(file) from bundle.")
            }

    				return loaded
        }
    }
    ```

    With that extension we can now add a property to **`ContentView`** that loads all our resorts into a single array:

    ```swift
    let resorts: [Resort] = Bundle.main.decode("resorts.json")
    ```

    For the body of our view, we’re going to use a **`NavigationView`** with a **`List`** inside it, showing all our resorts. In each row we’re going to show:

    - A 40x25 flag of which country the resort is in.
    - The name of the resort.
    - How many runs it has.

    40x25 is smaller than our flag source image, and also a different aspect ratio, but we can fix that by using **`resizable()`**, **`scaledToFit()`**, and a custom frame. To make it look a little better on the screen, we’ll use a custom clip shape and a stroked overlay.

    **When the row is tapped we’re going to push to a detail view showing more information about the resort**, but we haven’t built that yet so instead we’ll just push to a temporary text view as a placeholder.

    Replace your current **`body`** property with this:

    ```swift
    NavigationView {
        List(resorts) { resort in 
    				NavigationLink(destination: Text(resort.name)) {
                Image(resort.country)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 25)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 5)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.black, lineWidth: 1)
                    )

                VStack(alignment: .leading) {
                    Text(resort.name)
                        .font(.headline)
                    Text("\(resort.runs) runs")
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationBarTitle("Resorts")
    }
    ```

    Go ahead and run the app now and you should see it looks good enough, but if you rotate your iPhone to landscape you’ll see the screen goes blank. This happens because SwiftUI wants to show a detail view there, but we haven’t created one yet – let’s fix that next.

- **Making NavigationView work in landscape**

    When we use a **`NavigationView`**, **by default SwiftUI expects us to provide both a primary view and a secondary detail view that can be shown side by side**, with the primary view shown on the left and the secondary on the right. 

    **Previously we solved this by using `StackNavigationViewStyle()` as the navigation style for our `NavigationView`, which tells SwiftUI we only want to show one view**, but here we actually *want* the two-view behavior so we aren’t going to use that.

    On landscape iPhones that are big enough – iPhone 11 Pro Max, for example – SwiftUI’s default behavior is to show the secondary view, and provide the primary view as a slide over. It’s always been there, but you might not have realized until now: try sliding from the left edge of your screen to reveal the **`ContentView`** we just made. If you tap rows in there you’ll see the text behind **`ContentView`** change as the result of our **`NavigationLink`**, and if you *tap* on the text behind you can dismiss the **`ContentView`** slide over.

    Now, there is a problem here, and it’s the same problem you’ve had all along: **it’s not immediately obvious to the user that they need to slide from the left to reveal the list of options**. 

    In UIKit this can be fixed easily, but SwiftUI doesn’t give us an alternative right now so we’re going to work around the problem: **we’ll create a second view to show on the right by default, and use *that* to help the user discover the left-hand list.**

    First, create a new SwiftUI view called **`WelcomeView`**, then give it this code:

    ```swift
    struct WelcomeView: View {
    		var body: some View {
            VStack {
                Text("Welcome to SnowSeeker!")
                    .font(.largeTitle)

                Text("Please select a resort from the left-hand menu; swipe from the left edge to show it.")
                    .foregroundColor(.secondary)
            }
        }
    }
    ```

    **That’s all just static text; it will only be shown when the app first launches, because as soon as the user taps any of our navigation links it will get replaced with whatever they were navigating to.**

    To put that into **`ContentView`** so **the two parts of our UI can be used side by side**, all we need to do is add a second view to our **`NavigationView`** like this:

    ```swift
    NavigationView {
        List(resorts) { resort in
    			// all the previous list code
        }
        .navigationBarTitle("Resorts")

        WelcomeView()
    }
    ```

    **That’s enough for SwiftUI to understand exactly what we want**. 

    Try running the app on several different devices, both in portrait and landscape, to see how SwiftUI responds:

    - On an iPhone 11 Pro you’ll see **`ContentView`** in both portrait and landscape.
    - On an iPhone 11 (not 11 Pro – 11 Amateur?!) you’ll see **`ContentView`** in portrait and **`WelcomeView`** in landscape.
    - On an iPad you’ll also see **`ContentView`** in portrait and **`WelcomeView`** in landscape.

    The first two of those might seem backwards, but it’s a result of Apple’s slightly odd hardware choices: although the iPhone 11 Pro uses a Super Retina display at 3x resolution it is physically smaller than the iPhone 11’s 2x display, so Apple considers it too small to support the slide over **`ContentView`**.

    Although UIKit lets us control whether the primary view should be shown on iPad portrait, this is not yet possible in SwiftUI. **However, we *can* stop the iPhone 11 from using the slide over approach if that’s what you want – try it first and see what you think. If you want it gone, add this extension to your project:**

    ```swift
    extension View {
    		func phoneOnlyStackNavigationView() -> some View {
    				if UIDevice.current.userInterfaceIdiom == .phone {
    						return AnyView(
    								self.navigationViewStyle(StackNavigationViewStyle())
    						)
            } else {
    						return AnyView(self)
            }
        }
    }
    ```

    **That uses Apple’s `UIDevice` class to detect whether we are currently running on a phone or a tablet**, and **if it’s a phone enables the simpler `StackNavigationViewStyle` approach**. 

    **We need to use type erasure here because the two returned view types are different**.

    **Once you have that extension, simply add the `.phoneOnlyStackNavigationView()` modifier to your `NavigationView` so that iPads retain their default behavior whilst iPhones always use stack navigation.**

    Again, give it a try and see what you think – it’s your app, and it’s important you like how it works.

    **Tip:** I’m not going to be using this modifier in my own project because I prefer to use Apple’s default behavior where possible, but don’t let that stop you from making your own choice!

- **Creating a secondary view for NavigationView**

    Right now our **`NavigationLink`** directs the user to some sample text, which is fine for prototyping but obviously not good enough for our actual project. We’re going to replace that with a new **`ResortView`** that shows a picture from the resort, some description text, and a list of facilities.

    **Important:** Like I said earlier, the content in my example JSON is mostly fictional, and this includes the photos – these are just generic ski photos taken from Unsplash. Unsplash photos can be used commercially or non-commercially without attribution, but I’ve included the photo credit in the JSON so you can add it later on. As for the text, this is taken from Wikipedia. If you intend to use the text in your own shipping projects, it’s important you give credit to Wikipedia and its authors and make it clear that the work is licensed under CC-BY-SA available from here: [https://creativecommons.org/licenses/by-sa/3.0](https://creativecommons.org/licenses/by-sa/3.0).

    To start with, our **`ResortView`** layout is going to be pretty simple – not much more than a scroll view, a **`VStack`**, an **`Image`**, and some **`Text`**. The only interesting part is that we’re going to show the resort’s facilities as a single text view using **`resort.facilities.joined(separator: ", ")`** to get a single string.

    Replace the default **`ResortView`** with this:

    ```swift
    struct ResortView: View {
    	let resort: Resort

    	var body: some View {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Image(decorative: resort.id)
                        .resizable()
                        .scaledToFit()

                    Group {
                        Text(resort.description)
                            .padding(.vertical)

                        Text("Facilities")
                            .font(.headline)

                        Text(resort.facilities.joined(separator: ", "))
                            .padding(.vertical)
                    }
                    .padding(.horizontal)
                }
            }
            .navigationBarTitle(Text("\(resort.name), \(resort.country)"), displayMode: .inline)
        }
    }
    ```

    You’ll also need to update **`ResortView_Previews`** to pass in an example resort for Xcode’s preview window:

    ```swift
    struct ResortView_Previews: PreviewProvider {
    		static var previews: some View {
            ResortView(resort: Resort.example)
        }
    }
    ```

    And now we can update the navigation link in **`ContentView`** to point to our actual view, like this:

    ```swift
    NavigationLink(destination: ResortView(resort: resort)) {
    ```

    There’s nothing terribly interesting in our code so far, but that’s going to change now because I want to add more details to this screen – how big the resort is, roughly how much it costs, how high it is, and how deep the snow is.

    **We could just put all that into a single `HStack` in `ResortView`, but that restricts what we can do in the future**. 

    **So instead we’re going to group them into two views: one for resort information (price and size) and one for ski information (elevation and snow depth).**

    The ski view is the easier of the two to implement, so we’ll start there: create a new SwiftUI view called **`SkiDetailsView`** and give it this code:

    ```swift
    struct SkiDetailsView: View {
    		let resort: Resort

    		var body: some View {
            VStack {
                Text("Elevation: \(resort.elevation)m")
                Text("Snow: \(resort.snowDepth)cm")
            }
        }
    }

    struct SkiDetailsView_Previews: PreviewProvider {
    		static var previews: some View {
            SkiDetailsView(resort: Resort.example)
        }
    }
    ```

    **As for the resort details, this is a little trickier because of two things:**

    1. **The size of a resort is stored as a value from 1 to 3**, but really w**e want to use “Small”, “Average”, and “Large” instead.**
    2. **The price is stored as a value from 1 to 3**, but we’re going to **replace that with $, $$, or $$$.**

    As always, **it’s a good idea to get calculations out of your SwiftUI layouts so it’s nice and clear, so we’re going to create two computed properties**: **`size`** and **`price`**.

    Start by creating a new SwiftUI view called **`ResortDetailsView`**, and give it this property:

    ```swift
    let resort: Resort
    ```

    As with **`ResortView`**, you’ll need to update the preview struct to use some example data:

    ```swift
    struct ResortDetailsView_Previews: PreviewProvider {
    		static var previews: some View {
            ResortDetailsView(resort: Resort.example)
        }
    }
    ```

    When it comes to getting the size of the resort we could just add this property to **`ResortDetailsView`**:

    ```swift
    var size: String {
        ["Small", "Average", "Large"][resort.size - 1]
    }
    ```

    That works, **but it would cause a crash if an invalid value was used,** and it’s also a bit too cryptic for my liking. **Instead, it’s safer and clearer to use a `switch` block like this:**

    ```swift
    var size: String {
    		switch resort.size {
    		case 1:
    				return "Small"
    		case 2:
    				return "Average"
    		default:
    				return "Large"
        }
    }
    ```

    As for the **`price`** property, we can leverage the same repeating/count initializer we used to create example cards in project 17: **`String(repeating:count:)`** **creates a new string by repeating a substring a certain number of times.**

    So, please add this second computed property to **`ResortDetailsView`**:

    ```swift
    var price: String {
        String(repeating: "$", count: resort.price)
    }
    ```

    Now what remains in the **`body`** property is simple, because we just use the two computed properties we wrote:

    ```swift
    var body: some View {
        VStack {
            Text("Size: \(size)")
            Text("Price: \(price)")
        }
    }
    ```

    That completes our two mini views, **so we can now drop them into `ResortView` with spacers on either side to make sure they are centered** – put this into the group in **`ResortView`**, directly before the resort description:

    ```swift
    HStack {
        Spacer()
        ResortDetailsView(resort: resort)
        SkiDetailsView(resort: resort)
        Spacer()
    }
    .font(.headline)
    .foregroundColor(.secondary)
    .padding(.top)
    ```

    We’re going to add to that some more in a moment, but first I want to make one small tweak: using **`joined(separator:)`** does an OK job of converting a string array into a single string, but we’re not here to write OK code – we’re here to write *great* code.

    **Apple’s Foundation library comes with a better solution called `ListFormatter`, which only has one job: to convert an array of strings into a string**. 

    The difference is that rather than sending back “A, B, C” like we have right now, we get back “A, B, *and* C” – it’s more natural to read.

    To use **`ListFormatter`**, replace the current facilities text view with this:

    ```swift
    Text(ListFormatter.localizedString(byJoining: resort.facilities))
        .padding(.vertical)
    ```

    Much better!