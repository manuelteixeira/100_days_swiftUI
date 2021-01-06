# Day 64 - Project 13, part 3

- **Using coordinators to manage SwiftUI view controllers**

    Previously we looked at how we can use **`UIViewControllerRepresentable`** to wrap a UIKit view controller so that it can be used inside SwiftUI, in particular focusing on **`UIImagePickerController`**. 

    However, **we hit a problem: although we could show the image picker, we didn’t get notified when the user selected an image.**

    **SwiftUI’s solution to this is called *coordinators***, which is a bit confusing for folks coming from a UIKit background because there we had a design pattern also called coordinators that performed an entirely different role. 

    To be clear, **SwiftUI’s coordinators are nothing like the coordinator pattern many developers used with UIKit**, so if you’ve used that pattern previously please jettison it from your brain to avoid confusion!

    **SwiftUI’s coordinators are designed to act as delegates for UIKit view controllers**. 

    Remember, **“delegates” are objects that respond to events that occur elsewhere**. 

    For example, UIKit lets us attach a delegate object to its text field view, and that delegate will be notified when the user types anything, when they press return, and so on. This meant that UIKit developers could modify the way their text field behaved without having to create a custom text field type of their own.

    Using coordinators in SwiftUI requires you to learn a little about the way UIKit works, which is no surprise given that we’re literally integrating UIKit’s view controllers. So, to demonstrate this we’re going to upgrade our **`ImagePicker`** view so that it can report back when images are chosen.

    As a reminder, here’s the code we have right now:

    ```swift
    struct ImagePicker: UIViewControllerRepresentable {
        func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
            let picker = UIImagePickerController()
            return picker
        }

        func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {

        }
    }
    ```

    We’re going to take it step by step, because there’s a lot to take in here – don’t feel bad if it takes you some time to understand, because coordinators really aren’t easy the first time you encounter them.

    First, add this nested class inside the **`ImagePicker`** struct:

    ```swift
    class Coordinator {
    }
    ```

    Yes, it needs to be a class as you’ll see in a moment. **It *doesn’t* need to be a nested class, although it’s a good idea because it neatly encapsulates the functionality** – without a nested class it would be confusing if you had lots of view controllers and coordinators all mixed up.

    Even though that class is inside a **`UIViewControllerRepresentable`** struct, SwiftUI won’t automatically use it for the view’s coordinator. 

    Instead, **we need to add a new method called `makeCoordinator()`, which SwiftUI will automatically call if we implement it**. 

    **All this needs to do is create and configure an instance of our `Coordinator` class, then send it back.**

    Right now our **`Coordinator`** class doesn’t do anything special, so we can just send one back by adding this method to the **`ImagePicker`** struct:

    ```swift
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    ```

    What we’ve done so far is create an **`ImagePicker`** struct that knows how to create a **`UIImagePickerController`**, and **now we just told `ImagePicker` that it should have a coordinator to handle communication from that** **`UIImagePickerController`**.

    **The next step is to tell the `UIImagePickerController` that when something happens it should tell our coordinator**. This takes just one line of code in **`makeUIViewController()`**, so add this directly before the **`return picker`** line:

    ```swift
    picker.delegate = context.coordinator
    ```

    That code won’t compile, but before we fix it I want to spend just a moment digging in to what just happened. 

    **We don’t call `makeCoordinator()` ourselves; SwiftUI calls it automatically when an instance of `ImagePicker` is created**. 

    Even better, **SwiftUI automatically associated the coordinator it created with our `ImagePicker` struct, which means when it calls `makeUIViewController()` and `updateUIViewController()` it will automatically pass that coordinator object to us.**

    So, **the line of code we just wrote tells Swift to use the coordinator that just got made as the delegate for the `UIImagePickerController`**. 

    This means any time something happens inside the image picker controller – i.e., when the user selects an image – it will report that action to our coordinator.

    The reason our code doesn’t compile is that Swift is checking that our coordinator class is capable of acting as a delegate for **`UIImagePickerController`**, finding that it isn’t, and so is refusing to build our code any further. To fix this we need to modify our **`Coordinator`** class from this:

    ```swift
    class Coordinator {
    ```

    To this:

    ```swift
    class Coordinator: NSObject, 
    									 UIImagePickerControllerDelegate, 
    									 UINavigationControllerDelegate {
    ```

    **That does three things**:

    1. **It makes the class inherit from** **`NSObject`**, which **is the parent class for almost everything in UIKit**. **`NSObject`** **allows Objective-C to ask the object what functionality it supports at runtime**, which means the image picker can say things like “hey, the user selected an image, what do you want to do?”
    2. It makes the class conform to the **`UIImagePickerControllerDelegate`** protocol, which is what **adds functionality for detecting when the user selects an image**. (**`NSObject`** lets Objective-C *check* for the functionality; this protocol is what actually provides it.)
    3. It makes the class conform to the **`UINavigationControllerDelegate`** protocol, which **lets us detect when the user moves between screens in the image picker**.

    Now you can see why we needed to use a class for **`Coordinator`**: **we need to inherit from `NSObject` so that Objective-C can query our coordinator to see what functionality it supports.**

    At this point we have an **`ImagePicker`** struct that wraps a **`UIImagePickerController`**, and we’ve configured that image picker controller to talk to our **`Coordinator`** class when something interesting happens.

    The **`UIImagePickerControllerDelegate`** **protocol defines two optional methods that we can implement: one for when the user selected an image, and one for when they pressed cancel.** 

    **If we don’t implement the cancel method, UIKit will automatically just dismiss the image picker controller, so we can just forget about that**. 

    But the “image selected” method *matters*: **we need to catch that and do something with that image**. The question is *what* should we do with it?

    If we put UIKit to one side for a second and think in pure functionality, what we want is for our **`ImagePicker`** to report back that image to whatever used the picker in the first place. **We’re presenting `ImagePicker` inside a sheet in our `ContentView` struct, so we want that to be given whatever image was selected, then dismiss the sheet.**

    What **we need here is SwiftUI’s `@Binding` property wrapper, which allows us to create a binding from `ImagePicker` up to whatever created it**. **This means we can set the binding value in our image picker and have it actually update a value being stored somewhere else** – **in** **`ContentView`**, for example.

    So, add this property to **`ImagePicker`**:

    ```swift
    @Binding var image: UIImage?
    ```

    While you’re there, **we also want to dismiss this view when an image is chosen**. 

    **Right now we aren’t handling image selection at all, so we get UIKit’s default dismissing behavior, but as soon as we inject some custom functionality we need to handle dismissal by hand**.

    So, add this second property to **`ImagePicker`** so we can dismiss the view programmatically:

    ```swift
    @Environment(\.presentationMode) var presentationMode
    ```

    Now, we just added those properties to **`ImagePicker`**, but **we *need* them inside our `Coordinator` class because that’s the one that will be informed when an image was selected.**

    **Rather than just pass the data down one level, a better idea is to tell the coordinator what its parent is, so it can modify values there directly**. That means adding an **`ImagePicker`** property and associated initializer to the **`Coordinator`** class, like this:

    ```swift
    var parent: ImagePicker

    init(_ parent: ImagePicker) {
        self.parent = parent
    }
    ```

    And now we can modify **`makeCoordinator()`** so that it passes the **`ImagePicker`** struct into the coordinator, like this:

    ```swift
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    ```

    At this point your entire **`ImagePicker`** struct should look like this:

    ```swift
    struct ImagePicker: UIViewControllerRepresentable {
        @Environment(\.presentationMode) var presentationMode
        @Binding var image: UIImage?

        class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
            var parent: ImagePicker

            init(_ parent: ImagePicker) {
                self.parent = parent
            }
        }

        func makeCoordinator() -> Coordinator {
            Coordinator(self)
        }

        func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
            let picker = UIImagePickerController()
            picker.delegate = context.coordinator
            return picker
        }

        func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {

        }
    }
    ```

    At long last we’re ready to actually read the response from our **`UIImagePickerController`**, which is done by implementing a method with a very specific name. UIKit will look for this method in our **`Coordinator`** class, as it’s the delegate of the image picker, and if the method is found it will be called.

    The method name is long and needs to be exactly right in order for UIKit to find it, but helpfully Xcode can help us out with autocomplete. So, go inside the **`Coordinator`** class and start typing this: “didFinishPicking” – without the quote marks, of course. Xcode’s code completion should offer exactly one method, and if you select it you’ll get this code:

    ```swift
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        code            
    }
    ```

    That method receives a dictionary where the keys are of the type **`UIImagePickerController.InfoKey`**, and the values are of the type **`Any`**. **It’s our job to dig through that to find the image that was selected, assign it to our parent, then dismiss the image picker.**

    So, replace the “code” placeholder with this:

    ```swift
    if let uiImage = info[.originalImage] as? UIImage {
        parent.image = uiImage
    }

    parent.presentationMode.wrappedValue.dismiss()
    ```

    **Notice how we need the typecast for `UIImage` – that’s because the dictionary we’re provided holds all sorts of data types, so we need to be careful.**

    At this point I bet you’re *really* missing the beautiful simplicity of SwiftUI, so you’ll be glad to know that we’re **finally** done with the **`ImagePicker`** struct – it does everything we need now.

    So, at last we can return to ContentView.swift. Here’s how we left it from earlier:

    ```swift
    struct ContentView: View {
        @State private var image: Image?
        @State private var showingImagePicker = false

        var body: some View {
            VStack {
                image?
                    .resizable()
                    .scaledToFit()

                Button("Select Image") {
                    self.showingImagePicker = true
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker()
            }
        }
    }
    ```

    To integrate our **`ImagePicker`** view into that **we need to start by adding another `@State` image property that can be passed into the picker**:

    ```swift
    @State private var inputImage: UIImage?
    ```

    Next, **we need a method we can call when that property changes**. 

    Remember, **we can’t use a plain property observer here because Swift will ignore it, so instead we’ll write a method that checks whether `inputImage` has a value, and if it does uses it to assign a new `Image` view to the `image` property.**

    Add this method to **`ContentView`** now:

    ```swift
    func loadImage() {
        guard let inputImage = inputImage else { return }
        image = Image(uiImage: inputImage)
    }
    ```

    Finally, **we need to change our `sheet()` modifier** in two ways:

    - **We need to pass the `inputImage` property into our image picker**, so it will be updated when the image is selected.
    - **We need to call our new `loadImage()` method when the sheet is dismissed**.

    That first task is as simple as changing the contents of the sheet to this:

    ```swift
    ImagePicker(image: self.$inputImage)
    ```

    The second task requires you to learn something new: an extra **`onDismiss`** **parameter we can pass to the `sheet()` modifier, which lets us specify a function to run when the sheet is dismissed.** We want to call **`loadImage()`**, so we should update the **`sheet()`** modifier to this:

    ```swift
    .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
    ```

    And we’re done! Go ahead and run the app and try it out – you should be able to tap the button, browse through your photo library, and select a picture. When that happens the image picker view should disappear, and your selected image will be shown below.

    I realize at this point you’re probably sick of UIKit and coordinators, but before we move on I want to **sum up the complete process**:

    - **We created a SwiftUI view that conforms to** **`UIViewControllerRepresentable`**.
    - We **gave it a** **`makeUIViewController()`** **method that created some sort** of **`UIViewController`**, which in our example was a **`UIImagePickerController`**.
    - We **added a nested `Coordinator` class to act as a bridge between the UIKit view controller and our SwiftUI view**.
    - We **gave that coordinator a `didFinishPickingMediaWithInfo` method, which will be triggered by UIKit when an image was selected**.
    - Finally, **we gave our `ImagePicker` an `@Binding` property so that it can send changes back to a parent view.**

    For what it’s worth, after you’ve used coordinators once, the second and subsequent times are easier, but I wouldn’t blame you if you found the whole system quite baffling for now.

    Don’t worry too much – we’ll be coming back to this again soon, and then more in later projects. You’ll have more than enough chance to practice!

- **How to save images to the user's photo library**

    Before we’re done with the techniques for this project, there’s one last piece of UIKit joy we need to tackle: once we’ve processed the user’s image we’ll get a **`UIImage`** back, but **we need a way to save that processed image to the user’s photo library**. 

    **This uses a UIKit function called `UIImageWriteToSavedPhotosAlbum()`**, which in its simplest form is trivial to use, but in order to make it work *usefully* you need to wade back into UIKit. At the very least it will make you really appreciate how much better SwiftUI is!

    Before we write any code, **I need you to make one small change to the Info.plist** file for your project. You see, writing to the photo library is a protected operation, which means we can’t do it without explicit permission from the user.

    iOS will take care of asking for permission and checking the response, but ***we* need to provide a short string explaining to users why we want to write images in the first place**. To do that, open Info.plist, right-click on some empty space, then choose Add Row. You’ll see a dropdown list of options to choose from – I’d like you to scroll down and select **“Privacy - Photo Library Additions Usage Description”.** For the value on its right, please enter the text “We want to save the filtered photo.”

    With that done, we can now use the **`UIImageWriteToSavedPhotosAlbum()`** method to write out a picture. We already have this **`loadImage()`** method from our previous work:

    ```swift
    func loadImage() {
        guard let inputImage = inputImage else { return }
        image = Image(uiImage: inputImage)
    }
    ```

    **We could modify that so it immediately saves the image that got loaded, effectively creating a duplicate**. Add this line to the end of the method:

    ```swift
    UIImageWriteToSavedPhotosAlbum(inputImage, nil, nil, nil)
    ```

    And that’s it – every time you import an image, our app will save it back to the photo library. The first time you try it, iOS will automatically prompt the user for permission to write the photo and show the string we added to the Info.plist file.

    Now, you might look at that and think “that was easy!” And you’d be right. But **the reason it’s easy is because we did the least possible work: we provided the image to save as the first parameter to `UIImageWriteToSavedPhotosAlbum()`, then provided `nil` as the other three.**

    **Those `nil` parameters *matter*, or at least the first two do**: **they tell Swift what method should be called when saving completes, which in turn will tell us whether the save operation succeeded or failed**. 

    If you don’t care about that then you’re done – passing **`nil`** for all three is fine. But remember: users can deny access to their photo library, so if you don’t catch the save error they’ll wonder why your app isn’t working properly.

    **The reason it takes UIKit *two* parameters to know which function to call is because this code is *old* – way older than Swift, and in fact so old it even pre-dates Objective-C’s equivalent of closures**. 

    So instead, this uses a completely different way of referring to functions: **in place of the first `nil` we should point to an object, and in place of the second `nil` we should point to the name of the method that should be called**.

    If that sounds bad, I’m afraid you only know half the story. You see, both of those two parameters have their own complexities:

    - **The object we provide must be a class, and it must inherit from `NSObject`**. This means we can’t point to a SwiftUI view struct.
    - **The method is provided as a method *name*, not an actual method. This method name was used by Objective-C to find the actual code at runtime, which could then be run**. **That method needs to have a specific signature (list of parameters) otherwise our code just won’t work.**

    But wait: there’s more! For performance reasons, Swift prefers not to generate code in a way that Objective-C can read – that whole “look up methods at runtime” thing was really neat, but also really slow. And so, **when it comes to writing the method name we need to do two things**:

    1. **Mark the method using a special compiler directive called** **`#selector`**, which asks Swift to make sure the method name exists where we say it does.
    2. **Add an attribute called `@objc` to the method**, which tells Swift to generate code that can be read by Objective-C.

    You know, I wrote UIKit code for over a decade before I switched to SwiftUI, and already writing out all this explanation makes this old API seem like a crime against humanity. Sadly it is what it is, and we’re stuck with it.

    Before I show you the code, **I want to mention the fourth parameter**. So, the first one is the image to save, the second one is an object that should be notified about the result of the save, the third one is the method on the object that should be run, and then there’s the fourth one. We aren’t going to be using it here, but you need to be *aware* of what it does: **we can provide any sort of data here, and it will be passed *back* to us when our completion method is called.**

    **This is what UIKit calls “context”, and it helps you identify one image save operation from another.** **You can provide literally anything you want here, so UIKit uses the most hands-off type you can imagine: a raw chunk of memory that Swift makes no guarantees about whatsoever. This has its own special type name in Swift**: **`UnsafeRawPointer`**. 

    Honestly, if it weren’t for the fact that we *had* to use it here I simply wouldn’t even tell you it existed, because it’s not really useful at this point in your app development career.

    Anyway, that’s more than enough talk. Before you decide to throw this project away and go straight to the next one, let’s get this over and done with.

    As I’ve said, **to write an image to the photo library and read the response, we need some sort of class that inherits from `NSObject`**. 

    Inside there we need a method **with a precise signature** that’s marked with `**@objc`,** and we can then call that from **`UIImageWriteToSavedPhotosAlbum()`**.

    Putting all that together, please add this class somewhere outside of **`ContentView`**:

    ```swift
    class ImageSaver: NSObject {
        func writeToPhotoAlbum(image: UIImage) {
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveError), nil)
        }

        @objc func saveError(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
            print("Save finished!")
        }
    }
    ```

    With that in place we can now use it from SwiftUI, like this:

    ```swift
    let imageSaver = ImageSaver()
    imageSaver.writeToPhotoAlbum(image: inputImage)
    ```

    If you run the code now, you should see the “Save finished!” message output as soon as you select an image. Yes, that is remarkably little code given how much explanation it needed, but on the bright side that completes the overview for this project so at long (long, long!) last we can get into the actual implementation. Please go ahead and put your project back to its default state so we have a clean slate to work from.