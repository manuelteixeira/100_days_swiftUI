# Day 21 - Project 2, part 2

- **Stacking up buttons**

    We’re going to start our app by building the **basic UI structure**, which will be **two labels telling the user what to do** **then three image buttons showing three world flags.**

    First, find the assets for this project and drag them into your asset catalog. That means opening Assets.xcassets in Xcode, then dragging in the flag images from the project2-files folder. **You’ll notice that the images are named after their country, along with either @2x or @3x – these are images at double resolution and triple resolution to handle different types of iPhone screen.**

    Next, **we need two properties to store our game data**: 

    - an **array of all the country images** we want to show in the game
    - plus an **integer storing which country image is correct**.

    ```swift
    var countries = ["Estonia", "France", "Germany", "Ireland", "Italy", "Nigeria", "Poland", "Russia", "Spain", "UK", "US"]
    var correctAnswer = Int.random(in: 0...2)
    ```

    The **`Int.random(in:)`** method **automatically picks a random number**, which is perfect here – **we’ll be using that to decide which country flag should be tapped.**

    Inside our body, **we need to lay out our game prompt in a vertical stack**, so let’s start with that:

    ```swift
    var body: some View {
        VStack {
            Text("Tap the flag of")
            Text(countries[correctAnswer])
        }
    }
    ```

    **Below there we want to have our tappable flag buttons**, and while we *could* just add them to the same **`VStack`** **we can actually create a *second* `VStack` so that we have more control over the spacing.**

    The **`VStack`** **we just created above holds two text views and has no spacing, but the flags are going to have 30 points of spacing between them so it looks better.**

    So, start by adding this **`ForEach`** loop directly below the end of the **`VStack`** we just created:

    ```swift
    ForEach(0 ..< 3) { number inButton(action: {
           // flag was tapped
        }) {
            Image(self.countries[number])
                .renderingMode(.original)
        }
    }
    ```

    The **`renderingMode(.original)`** modifier **tells SwiftUI to render the original image pixels rather than trying to recolor them as a button.**

    And now we have a problem: our **`body`** **property is trying to send back two views, a `VStack` and a `ForEach`, but that isn’t allowed**. 

    This is where our second **`VStack`** will come in: I’d like you to **wrap the original `VStack` and the `ForEach` below in a new `VStack`, this time with a spacing of 30 points.**

    So your code should look like this:

    ```swift
    var body: some View {
        VStack(spacing: 30) {
            VStack {
                Text("Tap the flag of")
                // etc
            }

            ForEach(0 ..< 3) { number in// etc
            }
        }
    }
    ```

    **Having two vertical stacks like this allows us to position things more precisely**: the outer stack will space its views out by 30 points each, whereas the inner stack has no spacing.

    That’s enough to give you a basic idea of our user interface, and already you’ll see it doesn’t look great – some flags have white in them, which blends into the background, and all the flags are centered vertically on the screen.

    We’ll come back to polish the UI later, but for now let’s **put in a blue background color to make the flags easier to see**. **Because this means putting something behind our outer `VStack`, we need to use a `ZStack` as well.** 

    Yes, we’ll have a **`VStack`** inside another **`VStack`** inside a **`ZStack`**, and that is perfectly normal.

    Start by putting a **`ZStack`** around your outer **`VStack`**, like this:

    ```swift
    var body: some View {
        ZStack {
            // previous VStack code
        }
    }
    ```

    Now put this just inside the **`ZStack`**, so it goes behind the outer **`VStack`**:

    ```swift
    Color.blue.edgesIgnoringSafeArea(.all)
    ```

    That **`edgesIgnoringSafeArea()`** **modifier ensures the color goes right to the edge of the screen.**

    **Now that we have a darker background color, we should give the text something brighter** so that it stands out better:

    ```swift
    Text("Tap the flag of")
        .foregroundColor(.white)

    Text(countries[correctAnswer])
        .foregroundColor(.white)
    ```

    The last change we’ll make, for now at least, **is to push upwards all the things in our outer `VStack`, so the UI sits next to the top of the screen**. **This is as simple as adding a spacer view** directly after the end of the **`ForEach`**:

    ```swift
    Spacer()
    ```

- **Showing the player's score with an alert**

    In order for this game to be fun, **we need to randomize the order in which flags are shown, trigger an alert telling them whether they were right or wrong whenever they tap a flag**, **then reshuffle the flags.**

    We already set **`correctAnswer`** to a random integer, but the flags always start in the *same* order. To fix that **we need to shuffle the `countries` array when the game starts**, so modify the property to this:

    ```swift
    var countries = ["Estonia", "France", "Germany", "Ireland", "Italy", "Nigeria", "Poland", "Russia", "Spain", "UK", "US"].shuffled()
    ```

    As you can see, the **`shuffled()`** **method automatically takes care of randomizing the array order for us.**

    Now for the more interesting part: when a flag has been tapped, what should we do? **We need to replace the `// flag was tapped` comment with some code that determines whether they tapped the correct flag or not, and the best way of doing *that* is with a new method that accepts the integer of the button and checks whether that matches our `correctAnswer` property.**

    **Regardless of whether they were correct, we want to show the user an alert saying what happened so they can track their progress**. 

    So, **add this property to store whether the alert is showing or not**:

    ```swift
    @State private var showingScore = false
    ```

    And **add this property to store the title that will be shown inside the alert**:

    ```swift
    @State private var scoreTitle = ""
    ```

    So, **whatever method we write will accept the number of the button that was tapped, compare that against the correct answer**, **then set those two new properties so we can show a meaningful alert.**

    Add this directly after the **`body`** property:

    ```swift
    func flagTapped(_ number: Int) {
        if number == correctAnswer {
            scoreTitle = "Correct"
        } else {
            scoreTitle = "Wrong"
        }

        showingScore = true
    }
    ```

    We can now call that by replacing the **`// flag was tapped`** comment with this:

    ```swift
    self.flagTapped(number)
    ```

    **We already have `number` because it’s given to us by `ForEach`, so it’s just a matter of passing that on to** **`flagTapped()`**.

    Before we show the alert, **we need to think about what happens when the alert is dismissed**. Obviously the game shouldn’t be over, otherwise the whole thing would be over immediately.

    Instead we’re going to write an **`askQuestion()`** method **that resets the game by shuffling up the countries and picking a new correct answer**:

    ```
    func askQuestion() {
        countries.shuffle()
        correctAnswer = Int.random(in: 0...2)
    }
    ```

    That code won’t compile, and hopefully you’ll see why pretty quickly: **we’re trying to change properties of our view that haven’t been marked with `@State`, which isn’t allowed**. 

    So, go to where **`countries`** and **`correctAnswer`** are declared, and put **`@State private`** before them, like this:

    ```swift
    @State private var countries = ["Estonia", "France", "Germany", "Ireland", "Italy", "Nigeria", "Poland", "Russia", "Spain", "UK", "US"].shuffled()
    @State private var correctAnswer = Int.random(in: 0...2)
    ```

    And now we’re ready to show the alert. This needs to:

    1. **Use the `alert()` modifier so the alert gets presented when `showingScore` is true**.
    2. **Show the title we set in `scoreTitle`**.
    3. **Have a dismiss button that calls** **`askQuestion()`** when tapped.

    So, put this at the end of the **`ZStack`** in the **`body`** property:

    ```swift
    .alert(isPresented: $showingScore) {
        Alert(title: Text(scoreTitle), message: Text("Your score is ???"), dismissButton: .default(Text("Continue")) {
            self.askQuestion()
        })
    }
    ```

    Yes, there are three question marks that should hold a score value – you’ll be completing that part soon!

- **Styling our flags**

    Our game now works, although it doesn’t look great. Fortunately, we can make a few small tweaks to our design to make the whole thing look better.

    First, l**et’s replace the solid blue background color with a linear gradient from blue to black**, which ensures that even if a flag has a similar blue stripe it will still stand out against the background.

    So, find this line:

    ```swift
    Color.blue.edgesIgnoringSafeArea(.all)
    ```

    And replace it with this:

    ```swift
    LinearGradient(gradient: Gradient(colors: [.blue, .black]), startPoint: .top, endPoint: .bottom)
        .edgesIgnoringSafeArea(.all)
    ```

    **It still ignores the safe area, ensuring that the background goes edge to edge.**

    Now **let’s make the country name** – the part they need to guess – **the most prominent piece of text on the screen.** 

    We can do that with the **`font()`** **modifier, which lets us select from one of the built-in font sizes on iOS, but we can add `fontWeight()` to it to make the text extra bold.**

    Put these two modifiers directly after the **`Text(countries[correctAnswer])`** view:

    ```swift
    .font(.largeTitle)
    .fontWeight(.black)
    ```

    **“Large title” is the largest built-in font size iOS offers us, and automatically scales up or down depending on what setting the user has for their fonts** – a feature known as ***Dynamic Type*.**

    Finally, let’s jazz up those flag images a little. **SwiftUI gives us a number of modifiers to affect the way views are presented**, and we’re going to use three here: 

    - **one to change the shape of flags**,
    - **one to add a border around the flags**,
    - **and a third to add a shadow.**

    **There are four built-in shapes in Swift**: 

    - rectangle,
    - rounded rectangle,
    - circle,
    - and capsule.

    **We’ll be using capsule here**: **it ensures the corners of the shortest edges are fully rounded, while the longest edges remain straight** – it looks great for buttons. 

    Making our image capsule shaped is as easy as adding the **`.clipShape(Capsule())`** modifier, like this:

    ```swift
    .clipShape(Capsule())
    ```

    **As for drawing a border around the image**, this **is done using** the **`overlay()`** modifier. 

    **This lets us draw another view over the flag, which in our case will be a capsule that has a black stroke around its edge**. So, add this modifier after **`clipShape()`**:

    ```swift
    .overlay(Capsule().stroke(Color.black, lineWidth: 1))
    ```

    And **finally we want to apply a shadow effect around each flag, making them really stand out from the background.** 

    This is done using **`shadow()`**, **which takes the color, radius, X, and Y offset of the shadow, but if you skip X and Y it assumes 0 for them**. So, add this last modifier below the previous two:

    ```swift
    .shadow(color: .black, radius: 2)
    ```

    So, our finished flag image looks like this:

    ```swift
    Image(self.countries[number])
        .renderingMode(.original)
        .clipShape(Capsule())
        .overlay(Capsule().stroke(Color.black, lineWidth: 1))
        .shadow(color: .black, radius: 2)
    ```

    SwiftUI has so many modifiers that help us adjust the way fonts and images are rendered. They all do exactly one thing, so it’s common to stack them up as you can see above.