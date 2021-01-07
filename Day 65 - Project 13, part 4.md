# Day 65 - Project 13, part 4

- **Building our basic UI**

    The first step in our project is to build the basic user interface, which for this app will be:

    1. A **`NavigationView`** so we can show our app’s name at the top.
    2. A large gray box saying “Tap to select a picture”, over which we’ll place their imported picture.
    3. An “Intensity” slider that will affect how strongly we apply our Core Image filters, stored as a value from 0.0 to 1.0.
    4. A “Save” button to write out the modified image to the user’s photo library.
    5. 

    Initially the user won’t have selected an image, so we’ll represent that using an **`@State`** optional image property.

    First add these two properties to **`ContentView`**:

    ```swift
    @State private var image: Image?
    @State private var filterIntensity = 0.5
    ```

    Now modify the contents of its **`body`** property to this:

    ```swift
    NavigationView {
        VStack {
            ZStack {
                Rectangle()
                    .fill(Color.secondary)

                // display the image
            }
            .onTapGesture {
                // select an image
            }

            HStack {
                Text("Intensity")
                Slider(value: self.$filterIntensity)
            }.padding(.vertical)

            HStack {
                Button("Change Filter") {
                    // change filter
                }

                Spacer()

                Button("Save") {
                    // save the picture
                }
            }
        }
        .padding([.horizontal, .bottom])
        .navigationBarTitle("Instafilter")
    }
    ```

    There are lots of placeholders in there, and we’ll be filling them piece by piece as we work through this project.

    For now, I want to focus on this comment: **`// display the image`**. **This is where we need to show the selected image if we have one, but otherwise we should show a prompt telling the user to tap that area to trigger image selection.**

    Now, **you might think this is a great place to use `if let` and try replacing that comment with something like this:**

    ```swift
    if let image = image {
        image
            .resizable()
            .scaledToFit()
    } else {
        Text("Tap to select a picture")
            .foregroundColor(.white)
            .font(.headline)
    }
    ```

    However, **if you try building that you’ll see it doesn’t work** – you’ll get a fairly obscure error message along the lines of “Closure containing control flow statement cannot be used with function builder ViewBuilder”.

    **What Swift is trying to say is it has support for only a small amount of logic inside SwiftUI layouts – we can use `if someCondition`, but we can’t use `if let`**, **`for`**, **`while`**, **`switch`**, and so on.

    **What’s *actually* happening here is that Swift is able to convert `if someCondition` into a special internal view type called** **`ConditionalContent`**: **it stores the condition and the true and false views, and can check it at runtime**. 

    **However, `if let` creates a constant, and `switch` can have any number of cases, so neither can be used**.

    So, **the fix here is to replace `if let` with a simple condition, then rely on SwiftUI’s support for optional views**:

    ```swift
    if image != nil {
        image?
            .resizable()
            .scaledToFit()
    } else {
        Text("Tap to select a picture")
            .foregroundColor(.white)
            .font(.headline)
    }
    ```

    That code will now compile, and because **`image`** is **`nil`** you should see the “Tap to select a picture” prompt displayed over our gray rectangle.

- **Importing an image into SwiftUI using UIImagePickerController**

    In order to bring this project to life, we need to let the user select a photo from their library, then display it in **`ContentView`**. I’ve already shown you how this all works, so now it’s just a matter of putting it into our app – hopefully it will make a little more sense this time!

    **Start by making a new Swift file called ImagePicker.swift**, **replace its “Foundation” import with “SwiftUI”,** then give it this basic struct:

    ```swift
    struct ImagePicker: UIViewControllerRepresentable {
        @Environment(\.presentationMode) var presentationMode
        @Binding var image: UIImage?

        func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
            let picker = UIImagePickerController()
            return picker
        }

        func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {

        }
    }
    ```

    If you recall, **using `UIViewControllerRepresentable` means that `ImagePicker` is already a SwiftUI view that we can place inside our view hierarchy**. 

    In this instance **we’re wrapping UIKit’s `UIImagePickerController`, which lets the user select something from their photo library.**

    **When that `ImagePicker` struct is created, SwiftUI will automatically call its `makeUIViewController()` method**, which is what goes on to create and send back a **`UIImagePickerController`**. 

    **However, our code doesn’t actually *respond* to any events inside the image picker** – the user can search for an image and select it to dismiss the view, but we don’t then do anything with it.

    Rather than making us create a subclass of **`UIImagePickerController`**, **UIKit instead uses a system of *delegation*: we create a custom class that will be told when something interesting happened**. 

    **Each delegate class will usually need to conform to one or more protocols, and in our case that means `UINavigationControllerDelegate` and** **`UIImagePickerControllerDelegate`**. 

    The delegates work much like real-life delegates – if you delegate work to someone else, it means you’re giving it to them to complete.

    **SwiftUI handles these delegate classes by letting us define a *coordinator* that belongs to the struct.** 

    This class can do anything we need, including acting as the delegate for UIKit components, and we can then pass any relevant information back up to the **`ImagePicker`** that owns it.

    Start by adding this as a nested class inside **`ImagePicker`**:

    ```swift
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }
    }
    ```

    **You can see that conforms to the two protocols we need to use for working with UIKit’s image picker, and also inherits from `NSObject`** which is the base class for most types that come from UIKit.

    **Because our coordinator class conforms to the `UIImagePickerControllerDelegate` protocol, we can make it the delegate of the UIKit image picker** by modifying **`makeUIViewController()`** to this:

    ```swift
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        **picker.delegate = context.coordinator**
        return picker
    }
    ```

    We need to make two more changes to **`ImagePicker`** to make it useful. 

    The first is to **add a `makeCoordinator()` method that tells SwiftUI to use the `Coordinator` class for the `ImagePicker` coordinator**. From our perspective this is obvious, because we created a class called **`Coordinator`** that was inside the **`ImagePicker`** struct, but **this `makeCoordinator()` method lets us control *how* the coordinator is made.**

    If you recall, **we gave the `Coordinator` class a single property: `let parent: ImagePicker`. This means we need to create it with a reference to the image picker that owns it**, so the coordinator can forward on interesting events. 

    So, inside our **`makeCoordinator()`** method we’ll create a **`Coordinator`** object and pass in **`self`**.

    Add this method to the **`ImagePicker`** struct now:

    ```swift
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    ```

    **The final step for `ImagePicker` is to give the coordinator some sort of functionality**. 

    The **`UIImagePickerController`** class looks for two methods, but here we’re only going to use one: **`didFinishPickingMediaWithInfo`**. **This will be called when the user has selected an image, and will be given a dictionary of information about the selected image**.

    To make **`ImagePicker`** useful **we need to implement that method inside `Coordinator`**, **make it set the `image` property of its parent `ImagePicker`, then dismiss the view.**

    UIKit’s method name is long and complex, so it’s best written using code completion. Make some space inside the **`Coordinator`** class and type “didFinishPicking”, then press return to have Xcode fill in the whole method for you. Now modify it to have this code:

    ```swift
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let uiImage = info[.originalImage] as? UIImage {
            parent.image = uiImage
        }

        parent.presentationMode.wrappedValue.dismiss()
    }
    ```

    That completes ImagePicker.swift, so please head back to ContentView.swift so we can make use of it.

    First **we need an `@State` Boolean to track whether our image picker is being shown or not**, so start by adding this to **`ContentView`**:

    ```swift
    @State private var showingImagePicker = false
    ```

    Second, we need to set that Boolean to true when the big gray rectangle is tapped, so replace the **`// select an image`** comment with this:

    ```swift
    self.showingImagePicker = true
    ```

    Third, **we need a property that will store the image the user selected.** 

    **We gave the `ImagePicker` struct an `@Binding` property attached to a `UIImage`, which means when we create the image picker we need to pass in a `UIImage` for it to link to**. 

    When the **`@Binding`** property changes, the external value changes as well, which lets us read the value.

    So, add this property to **`ContentView`**:

    ```swift
    @State private var inputImage: UIImage?
    ```

    Fourth, **we need a method that will be called when the `ImagePicker` view has been dismissed**. 

    For now **this will just place the selected image directly into the UI**, so please add this method to **`ContentView`** now:

    ```
    func loadImage() {
        guard let inputImage = inputImage else { return }
        image = Image(uiImage: inputImage)
    }
    ```

    And finally, **we need to add a `sheet()` modifier somewhere in `ContentView`**. 

    **This will use `showingImagePicker` as its condition, will reference `loadImage` as its `onDismiss` parameter, and present an `ImagePicker` bound to `inputImage` as its contents.**

    So, add this directly below the existing **`navigationBarTitle()`** modifier:

    ```swift
    .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
        ImagePicker(image: self.$inputImage)
    }
    ```

    That completes all the steps required to wrap a UIKit view controller for use inside SwiftUI. We went over it a little faster this time but hopefully it still all made sense!

    Go ahead and run the app again, and you should be able to tap the gray rectangle to import a picture, and when you’ve found one it will appear inside our UI.

    **Tip:** The **`ImagePicker`** view we just made is completely reusable – you can put that Swift file to one side and use it on other projects easily. If you think about it, all the complexity of wrapping the view is contained inside ImagePicker.swift, which means if you *do* choose to use it elsewhere it’s just a matter of showing a sheet and binding an image.

- **Basic image filtering using Core Image**

    Now that our project has an image the user selected, **the next step is to let the user apply varying Core Image filters to it**. 

    To start with we’re just going to work with a single filter, but shortly we’ll extend that using an action sheet.

    **If we want to use Core Image in our apps, we first need to add two imports** to the top of ContentView.swift:

    ```swift
    import CoreImage
    import CoreImage.CIFilterBuiltins
    ```

    **Next we need both a context and a filter**. 

    **A Core Image context** is an object that’s **responsible for rendering a `CIImage` to a `CGImage`**, or **in** more **practical** **terms** an object for **converting the recipe for an image into an actual series of pixels we can work with.** 

    **Contexts are expensive to create, so if you intend to render many images it’s a good idea to create a context once and keep it alive**. 

    As for the filter, we’ll be using **`CISepiaTone`** as our default but because we’ll make it flexible later we’ll make the filter use **`@State`** so it can be changed.

    So, add these two properties to **`ContentView`**:

    ```swift
    @State private var currentFilter = CIFilter.sepiaTone()
    let context = CIContext()
    ```

    With those two in place **we can now write a method that will process whatever image was imported** – **that means it will set our sepia filter’s intensity based on the value in `filterIntensity`, read the output image back from the filter,** **ask our `CIContext` to render it**, **then place the result into our `image` property** so it’s visible on-screen.

    ```swift
    func applyProcessing() {
        currentFilter.intensity = Float(filterIntensity)

        guard let outputImage = currentFilter.outputImage else { return }

        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            let uiImage = UIImage(cgImage: cgimg)
            image = Image(uiImage: uiImage)
        }
    }
    ```

    The next job is to change the way **`loadImage()`** works. 

    Right now *that* assigns to the **`image`** property, but we don’t want that any more. 

    Instead, **it should send whatever image was chosen into the sepia tone filter, then call `applyProcessing()` to make the magic happen**.

    **Core Image filters have a dedicated `inputImage` property that lets us send in a `CIImage` for the filter to work with, but often this is thoroughly broken and will cause your app to crash – it’s much safer to use the filter’s `setValue()` method with the key `kCIInputImageKey`.**

    So, replace your existing **`loadImage()`** method with this:

    ```swift
    func loadImage() {
        guard let inputImage = inputImage else { return }

        let beginImage = CIImage(image: inputImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        applyProcessing()
    }
    ```

    If you run the code now you’ll see our basic app flow works great: we can select an image, then see it with a sepia effect applied. But **that intensity slider we added doesn’t do anything, even though it’s bound to the same `filterIntensity` value that our filter is reading from**.

    What’s happening here ought not to be too surprising: **even though the slider is changing the value of `filterIntensity`, changing that property won’t automatically trigger our `applyProcessing()` method again**. 

    Instead, we need to do that by hand, and **it’s not as easy as just creating a property observer on `filterIntensity` because they don’t work well thanks to the `@State` property wrapper being used.**

    Instead, what **we need is a custom binding that will return `filterIntensity` when it’s read, but when it’s written it will both update `filterIntensity` and also call `applyProcessing()`** so that the latest intensity setting is immediately used in our filter.

    **Custom bindings** **that rely on properties of our view need** **to be created inside the `body` property** of the view, because **Swift** **doesn’t allow one property to reference another**. 

    So, add this just inside the start of the **`body`** property:

    ```swift
    let intensity = Binding<Double>(
        get: {
            self.filterIntensity
        },
        set: {
            self.filterIntensity = $0
            self.applyProcessing()
        }
    )
    ```

    **Important:** Now that there is some logic inside the **`body`** property, **you *must* place `return`** before the **`NavigationView`**, like this: **`return NavigationView {`**.

    Now that we have a custom binding, we should attach our slider to *that* rather than directly to the **`@State`** property, so that changes to the slider will trigger **`applyProcessing()`**.

    So, change the slider code to this:

    ```swift
    Slider(value: intensity)
    ```

    Remember, **because `intensity` is already a binding, we don’t need to use a dollar sign before it** – you need to write **`value: intensity`** rather than **`value: $intensity`**.

    You can go ahead and run the app now, but be warned: even though Core Image is extremely fast on all iPhones, it’s extremely slow in the simulator. That means you can try it out to make sure everything works, but don’t be surprised if your code runs about as fast as an asthmatic ant carrying a heavy bag of shopping.