# Day 66 - Project 13, part 5

- **Customizing our filter using ActionSheet**

    So far we’ve brought together SwiftUI, **`UIImagePickerController`**, and Core Image, but the app still isn’t terribly useful – after all, the sepia tone effect isn’t *that* interesting.

    To make the whole app better, **we’re going to let users customize the filter they want to apply, and we’ll accomplish that using an *action sheet***. 

    On iPhone this is a **list of buttons that slides up from the bottom of the screen**, and you can add as many as you want – it can even scroll if you really need it to.

    First we need a property that will store whether the action sheet should be showing or not, so add this to **`ContentView`**:

    ```swift
    @State private var showingFilterSheet = false
    ```

    Now we can add an action sheet using the **`actionSheet()`** modifier. **This works identically to `sheet()` and `alert`: we provide it a condition to monitor, and as soon as the condition becomes true the action sheet will be shown.**

    Start by adding this modifier below the **`sheet()`**:

    ```swift
    .actionSheet(isPresented: $showingFilterSheet) {
        // action sheet here
    }
    ```

    Now replace the **`// change filter`** button action with this:

    ```swift
    self.showingFilterSheet = true
    ```

    **In terms of *what* to show in the action sheet, we can provide a title, a message, and an array of buttons to show**. 

    These buttons work just like **`Alert`**: **we provide a text title and an action to run when it’s selected.**

    For the action sheet in this app, we want users to select from a range of different Core Image filters, and when they choose one it should be activated and immediately applied. To make this work we’re going to **write a method that modifies `currentFilter` to whatever new filter they chose, then calls `loadImage()` straight away**.

    There is a wrinkle in our plan, and it’s a result of the way Apple wrapped the Core Image APIs to make them more Swift-friendly. You see, **the underlying Core Image API is entirely stringly typed, so rather than invent all new classes for us to use Apple instead created a series of protocols.**

    **When we assign `CIFilter.sepiaTone()` to a property, we get an object of the class `CIFilter` that happens to conform to a protocol called `CISepiaTone`**. 

    **That protocol then exposes the `intensity` parameter we’ve been using, but internally it will just map it to a call to `setValue(_:forKey:)`.**

    **This flexibility actually works in our favor because it means we can write code that works across all filters, as long as we’re careful not to send in an invalid value.**

    So, let’s start solving the problem. Please change your **`currentFilter`** property to this:

    ```swift
    @State private var currentFilter: CIFilter = CIFilter.sepiaTone()
    ```

    **So, again, `CIFilter.sepiaTone()` returns a `CIFilter` object that conforms to the `CISepiaTone` protocol. Adding that explicit type annotation means we’re throwing away some data: we’re saying that the filter must be a `CIFilter` but doesn’t have to conform to `CISepiaTone` any more.**

    **As a result of this change we lose access to the `intensity` property**, which means this code won’t work any more:

    ```swift
    currentFilter.intensity = Float(filterIntensity)
    ```

    Instead, **we need to replace that with a call to `setValue(:_forKey:)`**. This is all the protocol was doing anyway, but it did provide valuable extra type safety.

    Replace that broken line of code with this:

    ```swift
    currentFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey)
    ```

    **`kCIInputIntensityKey`** is another Core Image constant value, and it has the same effect as setting the **`intensity`** parameter of the sepia tone filter.

    With that change, we can return to our action sheet: we want to be able to change that filter to something else, then call **`loadImage()`**. So, add this method to **`ContentView`**:

    ```swift
    func setFilter(_ filter: CIFilter) {
        currentFilter = filter
        loadImage()
    }
    ```

    With that in place we can now replace the **`// action sheet here`** comment with a series of buttons that try out various Core Image filters.

    Put this in its place:

    ```swift
    ActionSheet(title: Text("Select a filter"), buttons: [
        .default(Text("Crystallize")) { self.setFilter(CIFilter.crystallize()) },
        .default(Text("Edges")) { self.setFilter(CIFilter.edges()) },
        .default(Text("Gaussian Blur")) { self.setFilter(CIFilter.gaussianBlur()) },
        .default(Text("Pixellate")) { self.setFilter(CIFilter.pixellate()) },
        .default(Text("Sepia Tone")) { self.setFilter(CIFilter.sepiaTone()) },
        .default(Text("Unsharp Mask")) { self.setFilter(CIFilter.unsharpMask()) },
        .default(Text("Vignette")) { self.setFilter(CIFilter.vignette()) },
        .cancel()
    ])
    ```

    I picked out those from the vast range of Core Image filters, but you’re welcome to try using code completion to try something else – type **`CIFilter.`** and see what comes up!

    Go ahead and run the app, select a picture, then try changing Sepia Tone to Vignette – this applies a darkening effect around the edges of your photo. (If you’re using the simulator, remember to give it a little time because it’s slow!)

    Now **try** **changing it to Gaussian Blur, which *ought* to blur the image, but will instead cause our app to cras**h. 

    **By jettisoning the `CISepiaTone` restriction for our filter, we’re now forced to send values in using `setValue(_:forKey:)`, which provides no safety at all**. 

    In this case, **the Gaussian Blur filter doesn’t have an intensity value, so the app just crashes.**

    To fix this – and also to make our single slider do much more work – **we’re going to add some more code that reads all the valid keys we can use with `setValue(_:forKey:)`, and only sets the intensity key if it’s supported by the current filter**. 

    Using this approach **we can actually query as many keys as we want, and set all the ones that are supported**. 

    So, **for sepia tone this will set intensity, but for Gaussian blur it will set the radius** (size of the blur), and so on.

    **This conditional approach will work with any filters you choose to apply**, which means you can experiment with others safely. 

    The only thing **you need be careful with is to make sure you scale up `filterIntensity` by a number that makes sense** – a 1-pixel blur is pretty much invisible, for example, so I’m going to multiply that by 200 to make it more pronounced.

    Replace this line:

    ```swift
    currentFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey)
    ```

    With this:

    ```swift
    let inputKeys = currentFilter.inputKeys
    if inputKeys.contains(kCIInputIntensityKey) { currentFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey) }
    if inputKeys.contains(kCIInputRadiusKey) { currentFilter.setValue(filterIntensity * 200, forKey: kCIInputRadiusKey) }
    if inputKeys.contains(kCIInputScaleKey) { currentFilter.setValue(filterIntensity * 10, forKey: kCIInputScaleKey) }
    ```

    And with that in place you can now run the app safely, import a picture of your choosing, then try out all the various filters – nothing should crash any more. Try experimenting with different filters and keys to see what you can find!

- **Saving the filtered image using UIImageWriteToSavedPhotosAlbum()**

    To complete this project we’re going to make that Save button do something useful: **save the filtered photo to the user’s photo library, so they can edit it further, share it, and so on.**

    As I explained previously, **the `UIImageWriteToSavedPhotosAlbum()` function does everything we need, but it has the catch that it needs to be used with some code that really doesn’t fit well with SwiftUI**: **it needs to be a class that inherits from `NSObject`, have a callback method that is marked with `@objc`, then point to that method using the `#selector` compiler directive.**

    Like I showed you previously, we’re going to isolate this in a separate, reusable class. Create a new Swift file called ImageSaver.swift, change its Foundation import to UIKit, then give it this code:

    ```swift
    class ImageSaver: NSObject {
        func writeToPhotoAlbum(image: UIImage) {
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveError), nil)
        }

        @objc func saveError(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
            // save complete
        }
    }
    ```

    We’re going to return back to that in a moment to make it more useful, but first **we need to make sure we request photo saving permission from the user correctly**: we need to **add a key to Info.plist**. If you deleted the one you added earlier, please re-add it now:

    - Open Info.plist
    - Right-click in some blank space
    - Choose Add Row
    - Select “Privacy - Photo Library Additions Usage Description” for the key name.
    - Enter “We want to save the filtered photo.” as the value.

    With that in place, we can now think about how to save an image using the **`ImageSaver`** class. Right now we’re setting our **`image`** property like this:

    ```swift
    if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
        let uiImage = UIImage(cgImage: cgimg)
        image = Image(uiImage: uiImage)
    }
    ```

    **You can actually go straight from a `CGImage` to a SwiftUI `Image` view, and previously I said we’re going via `UIImage` because the `CGImage` equivalent requires some extra parameters.** 

    That’s all true, **but there’s an important second reason that now becomes important: we need a `UIImage` to send to our `ImageSaver` class**, and this is the perfect place to create it.

    So, **add a new property to `ContentView` that will store this intermediate `UIImage`**:

    ```swift
    @State private var processedImage: UIImage?
    ```

    And now we can modify the **`applyProcessing()`** method so that our **`UIImage`** gets stashed away for later:

    ```swift
    if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
        let uiImage = UIImage(cgImage: cgimg)
        image = Image(uiImage: uiImage)
        processedImage = uiImage
    }
    ```

    And now filling in the Save button is almost trivial:

    ```swift
    Button("Save") {
        guard let processedImage = self.processedImage else { return }

        let imageSaver = ImageSaver()
        imageSaver.writeToPhotoAlbum(image: processedImage)
    }
    ```

    Now, we *could* leave it there, but **the whole reason we made `ImageSaver` into its own class was so that we could read whether the save was successful or not. Right now this gets reported back to us in a method in `ImageSaver`**:

    ```swift
    @objc func saveError(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        // save complete
    }
    ```

    In order for that result to be useful **we need to make it propagate upwards so that our `ContentView` can use it.** 

    However, **I don’t want the evil horrors of `@objc` to escape our little class, so instead we’re going to isolate that mess where it is and instead report back success or failure using closures** – a much friendlier solution for Swift developers.

    First add these two properties to the **`ImageSaver`** class, to represent closures handling success and failure:

    ```swift
    var successHandler: (() -> Void)?
    var errorHandler: ((Error) -> Void)?
    ```

    Second, **fill in the `didFinishSavingWithError` method so that it checks whether an error was provided, and calls one of those two closures**:

    ```swift
    if let error = error {
        errorHandler?(error)
    } else {
        successHandler?()
    }
    ```

    And now we can – if we want to – **provide one or both of those closures when using the `ImageSaver`** class, like this:

    ```swift
    let imageSaver = ImageSaver()

    imageSaver.successHandler = {
        print("Success!")
    }

    imageSaver.errorHandler = {
        print("Oops: \($0.localizedDescription)")
    }

    imageSaver.writeToPhotoAlbum(image: processedImage)
    ```

    Although the code is very different, the concept here is identical to what we did with **`ImagePicker`**: we wrapped up some UIKit functionality in such a way that we get all the behavior we want, just in a nicer, more SwiftUI-friendly way. Even better, this gives us another reusable piece of code that we can put into other projects in the future – we’re slowly building a library!

    That final step completes our app, so go ahead and run it again and try it from end to end – import a picture, apply a filter, then save it to your photo library. Well done!