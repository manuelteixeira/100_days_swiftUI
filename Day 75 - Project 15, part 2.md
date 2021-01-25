# Day 75 - Project 15, part 2

- **Fixing Guess the Flag**

    Way back in project 2 we made Guess the Flag, which showed three flag pictures and asked the users to guess which was which. Well, based on what you now know about VoiceOver, can you spot the fatal flaw in our game?

    That’s right: **SwiftUI’s default behavior is to read out the image names as their VoiceOver label, which means anyone using VoiceOver can just move over our three flags to have the system announce which one is correct**.

    To fix this **we need to add text descriptions for each of our flags, describing them in enough detail that they can be guessed correctly by someone who has learned them, but of course without actually giving away the name of the country.**

    If you open your copy of this project, you’ll see it was written to use an array of country names, like this:

    ```swift
    @State private var countries = ["Estonia", "France", "Germany", "Ireland", "Italy", "Nigeria", "Poland", "Russia", "Spain", "UK", "US"].shuffled()
    ```

    So, the easiest way to attach labels there – the way that doesn’t require us to change any of our code – is to **create a dictionary with country names as keys and accessibility labels as values**, like this. Please add this to **`ContentView`**:

    ```swift
    let labels = [
        "Estonia": "Flag with three horizontal stripes of equal size. Top stripe blue, middle stripe black, bottom stripe white",
        "France": "Flag with three vertical stripes of equal size. Left stripe blue, middle stripe white, right stripe red",
        "Germany": "Flag with three horizontal stripes of equal size. Top stripe black, middle stripe red, bottom stripe gold",
        "Ireland": "Flag with three vertical stripes of equal size. Left stripe green, middle stripe white, right stripe orange",
        "Italy": "Flag with three vertical stripes of equal size. Left stripe green, middle stripe white, right stripe red",
        "Nigeria": "Flag with three vertical stripes of equal size. Left stripe green, middle stripe white, right stripe green",
        "Poland": "Flag with two horizontal stripes of equal size. Top stripe white, bottom stripe red",
        "Russia": "Flag with three horizontal stripes of equal size. Top stripe white, middle stripe blue, bottom stripe red",
        "Spain": "Flag with three horizontal stripes. Top thin stripe red, middle thick stripe gold with a crest on the left, bottom thin stripe red",
        "UK": "Flag with overlapping red and white crosses, both straight and diagonally, on a blue background",
        "US": "Flag with red and white stripes of equal size, with white stars on a blue background in the top-left corner"
    ]
    ```

    And now all **we need to do is add the `accessibility(label:)` modifier to the flag images**. I realize that sounds simple, but the code has to do four things:

    1. **Use `self.countries[number]` to get the name of the country for the current flag**.
    2. **Use that name as the key for** **`self.labels`**.
    3. **Provide a string to use as a default if somehow the country name doesn’t exist in the dictionary**. (This should never happen, but there’s no harm being safe!)
    4. **Convert the final string to a text view**.

    Putting all that together, put this modifier directly below the rest of the modifiers for the flag images:

    ```swift
    .accessibility(label: Text(self.labels[self.countries[number], default: "Unknown flag"]))
    ```

    And now if you run the game again you’ll see it actually *is* a game, regardless of whether you use VoiceOver or not. This gets right to the core of accessibility: everyone can have fun playing this game now, regardless of their access needs.

- **Fixing Word Scramble**

    In project 5 we built Word Scramble, a game where users were given a random eight-letter word and had to produce new words using its letters. This mostly works great with VoiceOver: no parts of the app are *inaccessible*, although that doesn’t mean we can’t do better.

    To see an obvious pain point, try adding a word. You’ll see it slide into the table underneath the prompt, but if you tap into it with VoiceOver you’ll realize it isn’t read well: **the letter count is read as “five circle”, and the text is a separate element.**

    There are a few ways of improving this, but probably **the best is to make both those items a single group where the children are ignored by VoiceOver, then add a label for the whole group that contains a much more natural description**.

    Our current code looks like this:

    ```swift
    List(usedWords, id: \.self) {
        Image(systemName: "\($0.count).circle")
        Text($0)
    }
    ```

    **That relies on an implicit `HStack` to place the image and text side by side**. 

    So, to fix this **we need to create an *explicit* `HStack` so we can apply our VoiceOver customization**. 

    The **`HStack`** itself **accepts a closure for its content, which means we can no longer rely on `$0` from the `List`, so we’ll use a named parameter** instead.

    Replace the current **`List`** with this:

    ```swift
    List(usedWords, id: \.self) { word in
    		HStack {
            Image(systemName: "\(word.count).circle")
            Text(word)
        }
        .accessibilityElement(children: .ignore)
        .accessibility(label: Text("\(word), \(word.count) letters"))
    }
    ```

    If you try the game again, you’ll see it now reads “spill, five letters”, which is much better.

- **Fixing Bookworm**

    In project 11 we built Bookworm, an app that lets users store ratings and descriptions for books they had read, and we also introduced a **custom `RatingView` UI component that showed star ratings from 1 to 5.**

    Again, most of the app does well with VoiceOver, but that rating control is a hard fail – **it uses tap gestures to add functionality, so users won’t realize they are buttons, and it doesn’t even convey the fact that they are supposed to represent ratings**. 

    For example, if I tap one of the gray stars, VoiceOver reads out to me, “star, fill, image, possibly airplane, star” – it’s really not useful at all.

    That in itself is a problem, but it’s *extra* problematic because our **`RatingView`** is designed to be reusable – it’s the kind of thing you can take from this project and use in a dozen other projects, and that just means you end polluting many apps with poor accessibility.

    We can fix this with three modifiers, each added below the current **`tapGesture()`** modifier inside **`RatingView`**. 

    First, we need to **add one that provides a meaningful label for each star**, like this:

    ```swift
    .accessibility(label: Text("\(number == 1 ? "1 star" : "\(number) stars")"))
    ```

    Second, **we can remove the `.isImage` trait, because it really doesn’t matter that these are images:**

    ```swift
    .accessibility(removeTraits: .isImage)
    ```

    And finally, **we should tell the system that each star is actually a button, so users know it can be tapped**. 

    While we’re here, **we can make VoiceOver do an even better job by adding a second trait, `.isSelected`, if the star is already highlighted.**

    So, add this final modifier beneath the previous two:

    ```swift
    .accessibility(addTraits: number > self.rating ? .isButton : [.isButton, .isSelected])
    ```

    It only took three small changes, but this improved component is much better than what we had before.