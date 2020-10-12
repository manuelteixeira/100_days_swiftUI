# Day 30 - Project 5, part 2

- **Adding to a list of words**

    The user interface for this app will be made up of three main SwiftUI views: a **`NavigationView`** **showing the word they are spelling from**, a **`TextField`** **where they can enter one answer**, and a **`List`** **showing all the words they have entered previously**.

    For now, every time users enter a word into the text field, we’ll automatically add it to the list of used words. Later, though, we’ll add some validation to make sure the word hasn’t been used before, can actually be produced from the root word they’ve been given, and is a real word and not just some random letters.

    Let’s start with the basics: **we need an array of words they have already used**, **a root word for them to spell other words from**, **and a string we can bind to a text field**. So, add these three properties to **`ContentView`** now:

    ```swift
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    ```

    As for the body of the view, we’re going to start off as simple as possible: a **`NavigationView`** with **`rootWord`** for its title, then a **`VStack`** with a text field and a list:

    ```swift
    var body: some View {
        NavigationView {
            VStack {
                TextField("Enter your word", text: $newWord)

                List(usedWords, id: \.self) {
                    Text($0)
                }
            }
            .navigationBarTitle(rootWord)
        }
    }
    ```

    By giving **`usedWords`** to **`List`** directly, **we’re asking it to make one row for every word in the array**, **uniquely identified by the word itself**. 

    **This would cause problems if there were lots of duplicates in `usedWords`, but soon enough we’ll be disallowing that** so it’s not a problem.

    If you run the program, you’ll see the text field doesn’t look great – it’s not really even visible next to the navigation bar or the list. Fortunately, **we can fix that by asking SwiftUI to draw a light gray border around its edge using the `textFieldStyle()` modifier**. This usually looks best with a little padding around the edges so it doesn’t touch the edges of the screen, so add these two modifiers to the text field now:

    ```swift
    .textFieldStyle(RoundedBorderTextFieldStyle())
    .padding()
    ```

    That styling looks a little better, but the text view still has a problem: **although we can type into the text box, we can’t submit anything from there – there’s no way of adding our entry to the list of used words.**

    To fix that **we’re going to write a new method called** **`addNewWord()`** that will:

    1. **Lowercase `newWord` and remove any whitespace**
    2. **Check that it has at least 1 character otherwise exit**
    3. **Insert that word at position 0 in the `usedWords` array**
    4. **Set `newWord` back to be an empty string**

    Later on we’ll add some extra validation between steps 2 and 3 to make sure the word is allowable, but for now this method is straightforward:

    ```swift
    func addNewWord() {
        // lowercase and trim the word, to make sure we don't add duplicate words with case differences
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

        // exit if the remaining string is empty
        guard answer.count > 0 else {
            return}

        // extra validation to come

        usedWords.insert(answer, at: 0)
        newWord = ""
    }
    ```

    **We want to call `addNewWord()` when the user presses return on the keyboard**, and in SwiftUI **we can do that by providing an *on commit* closure for the text field**. I know that sounds fancy, but in practice it’s just a matter of providing a trailing closure to **`TextField`** that will be called whenever return is pressed.

    In fact, **because the closure’s signature – the parameters it needs to accept and its return type – exactly matches the `addNewWord()` method we just wrote, we can pass that in directly**:

    ```swift
    TextField("Enter your word", text: $newWord, onCommit: addNewWord)
    ```

    Run the app now and you’ll see that things are starting to come together already: we can now type words into the text field, press return, and see them appear in the list.

    Inside **`addNewWord()`** we used **`usedWords.insert(answer, at: 0)`** for a reason: **if we had used `append(answer)` the new words would have appeared at the end of the list where they would probably be off screen, but by inserting words at the start of the array they automatically slide in at the top of the list** – much better.

    Before we put a title up in the navigation view, I’m going to make two small changes to our layout.

    First, **when we call `addNewWord()` it lowercases the word the user entered, which is helpful because it means the user can’t add “car”, “Car”, and “CAR”.** 

    However, **it looks odd in practice: the text field automatically capitalizes the first letter of whatever the user types**, so when they submit “Car” what they see in the list is “car”.

    To fix this, **we can disable capitalization for the text field with another modifier**: **`autocapitalization()`**. Please add this to the text field now:

    ```swift
    .autocapitalization(.none)
    ```

    The second thing we’ll change, just because we can, is to **use Apple’s SF Symbols icons to show the length of each word next to the text**. 

    **SF Symbols provides numbers in circles from 0 through 50, all named using the format “x.circle.fill” – so 1.circle.fill, 20.circle.fill.**

    **In this program we’ll be showing eight-letter words to users, so if they rearrange all those letters to make a new word the longest it will be is also eight letters**. 

    As a result, we can use those SF Symbols number circles just fine – we know that all possible word lengths are covered.

    **If we use a second view inside a `List` row, SwiftUI will automatically create an implicit horizontal stack for us so that everything in the row sits neatly side by side**. 

    What this means is we can just add **`Image(systemName:)`** directly inside the list and we’re done:

    ```swift
    List(usedWords, id: \.self) {
        Image(systemName: "\($0.count).circle")
        Text($0)
    }
    ```

    If you run the app now you’ll see you can type words in the text field, press return, then see them slide into the list with their length icon to the side. Nice!

- **Runing code when our app launches**

    **When Xcode builds an iOS project, it puts your compiled program, your Info.plist file, your asset catalog, and any other assets into a single directory called a *bundle***, **then gives that bundle the name YourAppName.app**. This “.app” extension is automatically recognized by iOS and Apple’s other platforms, which is why if you double-click something like Notes.app on macOS it knows to launch the program inside the bundle.

    In our game, **we’re going to include a file called “start.txt”, which includes over 10,000 eight-letter words that will be randomly selected for the player to work with**. This was included in the files for this project that you should have downloaded from GitHub, so please **drag start.txt into your project now.**

    We already defined a property called **`rootWord`**, **which will contain the word we want the player to spell from**. 

    What **we need to do now is write a new method called `startGame()` that will**:

    1. **Find start.txt in our bundle**
    2. **Load it into a string**
    3. **Split that string into array of strings, with each element being one word**
    4. **Pick one random word from there to be assigned to `rootWord`, or use a sensible default if the array is empty.**

    Each of those four tasks corresponds to one line of code, but there’s a twist: **what if we can’t locate start.txt in our app bundle, or if we can *locate* it but we can’t *load* it?** 

    **In that case we have a serious problem, because our app is really broken** – either we forgot to include the file somehow (in which case our game won’t work), or we included it but for some reason iOS refused to let us read it (in which case our game won’t work, and our app is broken).

    Regardless of what caused it, **this is a situation that never ought to happen, and Swift gives us a function called `fatalError()` that lets us detect problems really clearly**. 

    **When we call `fatalError()` it will – unconditionally and always – cause our app to crash**. 

    It will just die. Not “might die” or “maybe die”: it will always just terminate straight away.

    I realize that sounds bad, but what it lets us do is important: for problems like this one, such as if we forget to include a file in our project, there is no point trying to make our app struggle on in a broken state. It’s much better to terminate immediately and give us a clear explanation of what went wrong so we can correct the problem, and that’s exactly what **`fatalError()`** does.

    Anyway, let’s take a look at the code – I’ve added comments matching the numbers above:

    ```swift
    func startGame() {
        // 1. Find the URL for start.txt in our app bundle
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            // 2. Load start.txt into a string
            if let startWords = try? String(contentsOf: startWordsURL) {
                // 3. Split the string up into an array of strings, splitting on line breaks
                let allWords = startWords.components(separatedBy: "\n")

                // 4. Pick one random word, or use "silkworm" as a sensible default
                rootWord = allWords.randomElement() ?? "silkworm"

                // If we are here everything has worked, so we can exit
                return}
        }

        // If were are *here* then there was a problem – trigger a crash and report the error
        fatalError("Could not load start.txt from bundle.")
    }
    ```

    Now that we have a method to load everything for the game, we need to actually call that thing when our view is shown. **SwiftUI gives us a dedicated view modifier for running a closure when a view is shown**, so we can use that to call **`startGame()`** and get things moving – add this modifier after **`navigationBarTitle()`**:

    ```swift
    .onAppear(perform: startGame)
    ```

    If you run the game now you should see a random eight-letter word at the top of the navigation view. It doesn’t really *mean* anything yet, because players can still enter whatever words they want. Let’s fix that next…

- **Validation words with UITextChecker**

    Now that our game is all set up, the last part of this project is to make sure the user can’t enter invalid words. 

    **We’re going to implement this as four small methods, each of which perform exactly one check**: 

    - is the **word original** (it hasn’t been used already),
    - is the **word possible** (they aren’t trying to spell “car” from “silkworm”),
    - and is the **word real** (it’s an actual English word).

    If you were paying attention you’ll have noticed that was only *three* methods – that’s because **the fourth method will be there to make showing error messages easier.**

    Anyway, let’s start with the **first method: this will accept a string as its only parameter, and return true or false depending on whether the word has been used before or not**. 

    We already have a **`usedWords`** array, so we can pass the word into its **`contains()`** method and send the result back like this:

    ```swift
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    ```

    That’s one method down!

    The next one is slightly trickier: **how can we check whether a random word can be made out of the letters from another random word?**

    There are a couple of ways we could tackle this, but the easiest one is this: **if we create a variable copy of the root word, we can then loop over each letter of the user’s input word to see if that letter exists in our copy.** 

    If it does, we remove it from the copy (so it can’t be used twice), then continue. If we make it to the end of the user’s word successfully then the word is good, otherwise there’s a mistake and we return false.

    So, here’s our second method:

    ```swift
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord

        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }

        return true
    }
    ```

    The final method is harder, because we need to use **`UITextChecker`** from UIKit. **In order to bridge Swift strings to Objective-C strings safely, we need to create an instance of `NSRange` using the UTF-16 count of our Swift string**. This isn’t nice, I know, but I’m afraid it’s unavoidable until Apple cleans up these APIs.

    So, our last method will make an instance of **`UITextChecker`**, **which is responsible for scanning strings for misspelled words**. 

    We’ll then create an **`NSRange`** **to scan the entire length of our string, then call `rangeOfMisspelledWord()` on our text checker so that it looks for wrong words**. 

    **When that finishes we’ll get back *another* `NSRange` telling us where the misspelled word was found, but if the word was OK the location for that range will be the special value `NSNotFound`.**

    So, here’s our final method:

    ```swift
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")

        return misspelledRange.location == NSNotFound
    }
    ```

    Before we can use those three, **I want to add some code to make showing error alerts easier.** First, we need some properties to control our alerts:

    ```swift
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    ```

    Now **we can add a method that sets the title and message based on the parameters it receives, then flips the `showingError` Boolean to `true`**:

    ```swift
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
    ```

    We can then pass those directly on to SwiftUI by adding an **`alert()`** modifier below **`.onAppear()`**:

    ```swift
    .alert(isPresented: $showingError) {
        Alert(title: Text(errorTitle), message: Text(errorMessage), dismissButton: .default(Text("OK")))
    }
    ```

    We’ve done that several times now, so hopefully it’s becoming second nature!

    At long last it’s time to finish our game: replace the **`// extra validation to come`** comment in **`addNewWord()`** with this:

    ```swift
    guard isOriginal(word: answer) else {
        wordError(title: "Word used already", message: "Be more original")
        return}

    guard isPossible(word: answer) else {
        wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
        return}

    guard isReal(word: answer) else {
        wordError(title: "Word not possible", message: "That isn't a real word.")
        return}
    ```

    If you run the app now you should find that it will refuse to let you use words if they fail our tests – trying a duplicate word won’t work, words that can’t be spelled from the root word won’t work, and gibberish words won’t work either.

    That’s another app done – good job!