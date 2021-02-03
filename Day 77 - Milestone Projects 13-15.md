# Day 77 - Milestone: Projects 13-15

- Challenge

    Have you ever been to a conference or a meetup, chatted to someone new, then realized seconds after you walk away that you’ve already forgotten their name? You’re not alone, and the app you’re building today will help solve that problem and others like it.

    Your goal is to build an app that asks users to import a picture from their photo library, then attach a name to whatever they imported. The full collection of pictures they name should be shown in a **`List`**, and tapping an item in the list should show a detail screen with a larger version of the picture.

    Breaking it down, you should:

    - Wrap **`UIImagePickerController`** so it can be used to select photos.
    - Detect when a new photo is imported, and immediately ask the user to name the photo.
    - Save that name and photo somewhere safe.
    - Show all names and photos in a list, sorted by name.
    - Create a detail screen that shows a picture full size.
    - Decide on a way to save all this data.

    We’ve covered how to save data to the user’s photo library using **`UIImageWriteToSavedPhotosAlbum()`**, but saving an image to disk requires a small extra step: you need to convert your **`UIImage`** to **`Data`** by calling its **`jpegData()`** method like this:

    ```
    if let jpegData = yourUIImage.jpegData(compressionQuality: 0.8) {
        try? jpegData.write(to: yourURL, options: [.atomicWrite, .completeFileProtection])
    }
    ```

    The **`compressionQuality`** parameter can be any value between 0 (very low quality) and 1 (maximum quality); something like 0.8 gives a good trade off between size and quality.

    You can use Core Data for this project if you want to, but it isn’t required – a simple JSON file written out to the documents directory is fine, although you will need to add a custom conformance to **`Comparable`** to get array sorting to work.

    If you *do* choose to use Core Data, make sure you don’t save the actual image into the database because that’s not efficient. Core Data or not, the optimal thing to do is generate a new **`UUID`** for the image filename then write it to the documents directory, and store that **`UUID`** in your data model.

    Remember, you already know everything you need to make this work – good luck!