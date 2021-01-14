# Day 70 - Project 14, part 3

- **Advanced MKMapView with SwiftUI**

    This project is going to be based around a map view, asking users to add places to the map that they want to visit. To make this work we can’t just embed a simple **`MKMapView`** in SwiftUI and hope for the best: **we need to track the center coordinate, whether or not the user is viewing place details, what annotations they have, and more.**

    So, **we’re going to start with a basic `MKMapView` wrapper that has a coordinator**, then quickly add some extras onto it so that it becomes more useful.

    Create a new SwiftUI view called “MapView”, add an import for MapKit, then give it this code:

    ```swift
    struct MapView: UIViewRepresentable {
        func makeUIView(context: Context) -> MKMapView {
            let mapView = MKMapView()
            mapView.delegate = context.coordinator
            return mapView
        }

        func updateUIView(_ view: MKMapView, context: Context) {

        }

        func makeCoordinator() -> Coordinator {
            Coordinator(self)
        }

        class Coordinator: NSObject, MKMapViewDelegate {
            var parent: MapView

            init(_ parent: MapView) {
                self.parent = parent
            }
        }
    }
    ```

    There’s nothing special there, so let’s change that immediately by **making the map keep track of its center coordinate**. 

    As we looked at previously **this means implementing the `mapViewDidChangeVisibleRegion()` method in our coordinator**, but this time **we’re going to pass that data up to the `MapView` struct so we can use `@Binding` to store the value** somewhere else. 

    So, **the coordinator will receive the value from MapKit and pass it up to the** **`MapView`**, **that `MapView` puts the value in an `@Binding` property**, **which means it’s actually being stored somewhere else** – we’ve made a little chain that connects **`MKMapView`** to **whatever SwiftUI view is embedding the map.**

    Start by adding this property to **`MapView`**:

    ```swift
    @Binding var centerCoordinate: CLLocationCoordinate2D
    ```

    That will immediately break the **`MapView_Previews`** struct, because it needs to provide a binding. **This preview isn’t really useful because `MKMapView` doesn’t work outside of the simulator**, so I wouldn’t blame you if you just deleted it. 

    However, if you really want to make it work you should **add some example data** to **`MKPointAnnotation`** so that it’s easy to reference:

    ```swift
    extension MKPointAnnotation {
        static var example: MKPointAnnotation {
            let annotation = MKPointAnnotation()
            annotation.title = "London"
            annotation.subtitle = "Home to the 2012 Summer Olympics."
            annotation.coordinate = CLLocationCoordinate2D(latitude: 51.5, longitude: -0.13)
            return annotation
        }
    }
    ```

    With that in place it’s easy to fix **`MapView_Previews`**, because we can just use that example annotation:

    ```swift
    struct MapView_Previews: PreviewProvider {
        static var previews: some View {
            MapView(centerCoordinate: .constant(MKPointAnnotation.example.coordinate))
        }
    }
    ```

    We’re going to add more to that in just a moment, but first I want to put it into **`ContentView`**. In this app users are going to be adding places to a map that they want to visit, and we’ll represent that with a **full-screen `MapView` and a translucent circle on top to represent the center point.** 

    **Although this view will have a binding to track the center coordinate**, we don’t need to use that to place the circle – **a simple `ZStack` will make sure the circle always stays in the center of the map.**

    First, add an extra **`import`** line so we get access to MapKit’s data types:

    ```swift
    import MapKit
    ```

    Second, add a property inside **`ContentView`** that **will store the current center coordinate of the map**. Later on we’re going to use this to add a place mark:

    ```swift
    @State private var centerCoordinate = CLLocationCoordinate2D()
    ```

    And now we can fill in the **`body`** property

    ```swift
    ZStack {
        MapView(centerCoordinate: $centerCoordinate)
            .edgesIgnoringSafeArea(.all)
        Circle()
            .fill(Color.blue)
            .opacity(0.3)
            .frame(width: 32, height: 32)
    }
    ```

    If you run the app now you’ll see you can move the map around freely, but **there’s always a blue circle showing exactly where the center is**.

    **Although our blue dot will always be fixed at the center of the map, we still want `ContentView` to have its `centerCoordinate` property updated as the map moves around**. 

    We’ve connected it to **`MapView`**, but we still need to implement the **`mapViewDidChangeVisibleRegion()`** method in the map view’s coordinator to kick off that whole chain.

    So, add this method to the **`Coordinator`** class of **`MapView`** now:

    ```swift
    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
        parent.centerCoordinate = mapView.centerCoordinate
    }
    ```

    All this work by itself isn’t terribly interesting, so the next step is to **add a button in the bottom-right that lets us add place marks to the map**. 

    We’re already inside a **`ZStack`**, so **the easiest way to align this button is to place it inside a `VStack` and a `HStack` with spacers before it each time**. 

    Both those spacers end up occupying the full vertical and horizontal space that’s left over, making whatever comes at the end sit comfortably in the **bottom-right corner**.

    We’ll add some functionality for the button soon, but first let’s get it in place and add some basic styling to make it look good.

    Please add this **`VStack`** below the **`Circle`**:

    ```swift
    VStack {
        Spacer()
        HStack {
            Spacer()
            Button(action: {
                // create a new location
            }) {
                Image(systemName: "plus")
            }
            .padding()
            .background(Color.black.opacity(0.75))
            .foregroundColor(.white)
            .font(.title)
            .clipShape(Circle())
            .padding(.trailing)
        }
    }
    ```

    **Notice how I added the `padding()` modifier twice there – once is to make sure the button is bigger before we add a background color, and the second time to push it away from the trailing edge.**

    Where things get *interesting* is **how we place pins on the map**. 

    **We’ve bound the center coordinate of the map to a property in our map view, but now we need to send data the *other* way.**

    **We need to make an array of locations in** **`ContentView`**, **and send those to the `MKMapView` to be displayed**.

    Solving this is best done by breaking the problem down into several smaller, simpler parts. 

    The first part is obvious: **we need an array of locations in `ContentView`, which stores all the places the user wants to visit.**

    So, start by adding this property to **`ContentView`**:

    ```swift
    @State private var locations = [MKPointAnnotation]()
    ```

    Next, **we want to add a location to that whenever the + button is tapped**. 

    We aren’t going to add a title and subtitle yet, so for now this is just as simple as creating an **`MKPointAnnotation`** using the current value of **`centerCoordinate`**.

    Replace the **`// create a new location`** comment with this:

    ```swift
    let newLocation = MKPointAnnotation()
    newLocation.coordinate = self.centerCoordinate
    self.locations.append(newLocation)
    ```

    Now for the challenging part: **how can we synchronize that with the map view?** Remember, we *don’t* want **`ContentView`** to even know that MapKit is being used – **we want to isolate all that functionality inside `MapView`, so that we keep our SwiftUI code nice and clean.**

    **This is where `updateUIView()` comes in: SwiftUI will automatically call it when any of the values being sent into the `UIViewRepresentable` struct have changed**. 

    **This method** is then **responsible for synchronizing both the view and its coordinator to the latest configuration from the parent view.**

    In our case, **we’re sending the `centerCoordinate` binding into `MapView`, which means every time the user moves the map that value changes, which in turn means `updateUIView()` is being called all the time**. 

    This has been happening quietly all this time because **`updateUIView()`** is empty, but if you add a simple **`print()`** call in there you’ll see it come to life:

    ```swift
    func updateUIView(_ view: MKMapView, context: Context) {
        print("Updating")
    }
    ```

    Now as you move the map around you’ll see “Updating” printing again and again.

    Anyway, all this matters because **we can also pass into `MapView` the `locations` array we just made, and have it use that array to insert annotations for us.**

    So, start by adding this new property to **`MapView`** to hold all the locations we’ll pass to it:

    ```swift
    var annotations: [MKPointAnnotation]
    ```

    Second, we need to update **`MapView_Previews`** so that it sends in our example annotation, although again I wouldn’t blame you if you had already deleted the preview because it really isn’t useful at this time! Anyway, if you still have it then adjust it to this:

    ```swift
    MapView(centerCoordinate: .constant(MKPointAnnotation.example.coordinate), annotations: [MKPointAnnotation.example])
    ```

    Third, we need to **implement `updateUIView()` inside `MapView` so that it compares the current annotations to the latest annotations**, and **if they aren’t the same then it replaces them**. 

    Now, **we *could* compare each item in the annotations to see whether they are the same, but there isn’t any point** – **we can’t add and remove items at the same time, so all we need to do is check whether the two arrays contain the same number of items**, and if they don’t remove all existing annotations and add them again.

    Replace your current **`updateUIView()`** method with this:

    ```swift
    func updateUIView(_ view: MKMapView, context: Context) {
        if annotations.count != view.annotations.count {
            view.removeAnnotations(view.annotations)
            view.addAnnotations(annotations)
        }
    }
    ```

    Finally, update **`ContentView`** so that it sends in the **`locations`** array to be converted into annotations:

    ```swift
    MapView(centerCoordinate: $centerCoordinate, annotations: locations)
    ```

    That’s enough map work for now, so go ahead and run your app again – you should be able to move around as much as you need, then press the + button to add pins.

    One thing you might notice is how **iOS automatically coalesces pins when they are placed close together**. For example, if you place a few pins in a one kilometer region then zoom out, iOS **will hide some of them to avoid making the map hard to read**.

- **Customizing MKMapView annotations**

    Adding annotations to an **`MKMapView`** is just a matter of dropping pins at the correct location, but in this app we want users to be able to tap the locations for more information, then tap *again* to edit that location. Making all this happen takes a little SwiftUI, a little UIKit, and a little MapKit, all rolled into one – it’s an interesting challenge!

    The **first step is to implement the `mapView(_:viewFor:)` method, which will be called if we want to provide a custom view to represent our map pin**. 

    We looked at this previously, but this time **we’re going to use a more advanced solution that re-uses views for performance**, and **also adds a button that can be tapped for more information**. 

    MapKit handles that button press in a curious way, but it’s not *hard*, just a bit odd at first.

    Anyway, the main thing here is reusing views for performance. Remember, **creating views is *expensive*, so it’s best to create a handful and just recycle them as needed** – just changing the text labels rather than destroying and recreating them each time.

    **MapKit gives us a nice and simple API for handling view reuse**: **we create a string identifier of our choosing, then call `dequeueReusableAnnotationView(withIdentifier:)` on the map view, passing in that identifier**. 

    **If there is a view waiting to be recycled we’ll get it back and can reconfigure it as needed**; **if not, we’ll get back `nil` and need to create the view ourselves.**

    **If we *do* get back `nil` it means we need to create the view, which means instantiating a new `MKPinAnnotationView` and giving it our annotation to display**. 

    However, we’re also going to **set a property called `rightCalloutAccessoryView`, which is where we’ll place a button to show more information**.

    We’re *not* in SwiftUI land here, which means we can’t use the **`Button`** view. Instead, we need to use the UIKit equivalent, **`UIButton`**. I could spend a few hours teaching you about the intricacies of working with **`UIButton`**, but fortunately I don’t need to: when used with MapKit it’s only one line of code because we can use a built-in button style called **`.detailDisclosure`** – it looks like an “I” with a circle around it.

    Like all delegate methods from UIKit and MapKit, this next one has a long name. So, the best thing to do is go inside the **`Coordinator`** class in **`MapView`**, and type “viewfor” to have Xcode’s code completion pop up. Hopefully the correct **`MKMapView`** method should pop up and you can press return to make it fill in the full method.

    Once that’s done, edit it to this:

    ```swift
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // this is our unique identifier for view reuse
        let identifier = "Placemark"

        // attempt to find a cell we can recycle
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

        if annotationView == nil {
            // we didn't find one; make a new one
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)

            // allow this to show pop up information
            annotationView?.canShowCallout = true

            // attach an information button to the view
            annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            // we have a view to reuse, so give it the new annotation
            annotationView?.annotation = annotation
        }

        // whether it's a new view or a recycled one, send it back
        return annotationView
    }
    ```

    **That won’t *quite* work yet, because even though we set `canShowCallout` to true MapKit won’t show call outs for annotations without a title**. 

    We don’t have a way of entering titles just yet, so for now we’ll just hard-code one – go back to ContentView.swift and add this line where we create the **`MKPointAnnotation`** for the **`locations`** array:

    ```swift
    newLocation.title = "Example location"
    ```

    If you run the app now you’ll find you can drop pins by pressing the + button, and you can then tap a pin to bring up the title – along with the little "i" button on the right. Making that button *do* something is where the fun comes in, albeit for a very specific definition of “fun”.

    Things start off straightforward: **we’re going to add two properties to our `MapView` that track whether we should show place details or not, and what place was actually selected**. 

    **These will form another bridge between `MKMapView` and SwiftUI**, so we’re going to mark them with **`@Binding`**.

    Add these two properties now:

    ```swift
    @Binding var selectedPlace: MKPointAnnotation?
    @Binding var showingPlaceDetails: Bool
    ```

    It’s down to you, but **I prefer to place all my `@Binding` properties together, which affects how Swift creates its memberwise initializers**.

    Having those extra properties in place means we need to adjust the **`MapView_Previews`** struct to include them, like this:

    ```swift
    MapView(centerCoordinate: .constant(MKPointAnnotation.example.coordinate), selectedPlace: .constant(MKPointAnnotation.example), showingPlaceDetails: .constant(false), annotations: [MKPointAnnotation.example])
    ```

    Remember to **adjust the order of those parameters based on how you arranged the properties in** **`MapView`**!

    Over in ContentView.swift we need to do much the same, although first we need some **`@State`** properties to pass in. So, start by adding these to **`ContentView`**:

    ```swift
    @State private var selectedPlace: MKPointAnnotation?
    @State private var showingPlaceDetails = false
    ```

    We can now update its **`MapView`** line to pass those values in:

    ```swift
    MapView(centerCoordinate: $centerCoordinate, selectedPlace: $selectedPlace, showingPlaceDetails: $showingPlaceDetails, annotations: locations)
    ```

    **When that `showingPlaceDetails` Boolean becomes true, we want to show an alert with the title and subtitle of the currently selected place, along with a button that lets users edit the place**. 

    We don’t have editing ready yet, but we can at least show the alert and connect it up to MapKit.

    Start by adding this **`alert()`** modifier to the **`ZStack`** in **`ContentView`**:

    ```swift
    .alert(isPresented: $showingPlaceDetails) {
        Alert(
    			title: Text(selectedPlace?.title ?? "Unknown"), 
    			message: Text(selectedPlace?.subtitle ?? "Missing place information."), 
    			primaryButton: .default(Text("OK")), 
    			secondaryButton: .default(Text("Edit")
    		) {
            // edit this place
        })
    }
    ```

    Finally, **we need to update `MapView` so that tapping the "i" button for an annotation sets the `selectedPlace` and `showingPlaceDetails` properties.** 

    This is done by implementing a method with an even longer name than before, so the best thing to do is go inside the **`Coordinator`** class and type “mapviewcall” – Xcode’s code completion should offer a recommendation, and you can press return to fill it in.

    This method, the important part of which is called **`calloutAccessoryControlTapped`**, **gets called when the button is tapped**, and it’s down to us to decide what should happen. 

    In this instance, **we’re going to start by checking we have an `MKAnnotationView`, and if so use that to set the `selectedPlace` property of the parent `MapView`**. 

    **We can then also set `showingPlaceDetails` to true, which will in turn trigger the alert in `ContentView`** – it’s another chain, this time connecting map pin taps to our alert.

    Add this method to the **`Coordinator`** class now:

    ```
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let placemark = view.annotation as? MKPointAnnotation else { return }

        parent.selectedPlace = placemark
        parent.showingPlaceDetails = true
    }
    ```

    With that in place the next step of our project is complete, so please run it now – you should be able to drop a pin, tap on it to reveal more information, then press the "i" button to show an alert. This is coming together!