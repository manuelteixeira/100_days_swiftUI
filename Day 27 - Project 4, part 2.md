# Day 27 - Project 4, part 2

- **Building a basic layout**

    **This app is going to allow user input with a date picker and two steppers**, which combined **will tell us when they want to wake up, how much sleep they usually like, and how much coffee they drink.**

    So, please start by **adding three properties** that let us store the information for those controls:

    ```swift
    @State private var wakeUp = Date()
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    ```

    Inside our **`body`** **we’re going to place three sets of components wrapped in a `VStack` and a `NavigationView`**, so let’s start with the wake up time. Replace the default “Hello World” text view with this:

    ```swift
    NavigationView {
        VStack {
            Text("When do you want to wake up?")
                .font(.headline)

            DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                .labelsHidden()

            // more to come
        }
    }
    ```

    **Because we’re in a `VStack`, that will render the date picker as a spinning wheel on iOS**, which is fine here. 

    **We’ve asked for `.hourAndMinute` configuration because we care about the time someone wants to wake up and not the day**, and with the **`labelsHidden()`** **modifier we don’t get a second label** for the picker – the one above is more than enough.

    Next we’re going to **add a stepper to let users choose roughly how much sleep they want**. By giving this thing an **`in`** range of **`4...12`** and a step of 0.25 we can be sure they’ll enter sensible values, but **we can combine that with the `%g` string interpolation specifier so we see numbers like “8” and not “8.000000”.**

    Add this code in place of the **`// more to come`** comment”

    ```swift
    Text("Desired amount of sleep")
        .font(.headline)

    Stepper(value: $sleepAmount, in: 4...12, step: 0.25) {
        Text("\(sleepAmount, specifier: "%g") hours")
    }
    ```

    Finally **we’ll add one last stepper and label to handle how much coffee they drink**. This time we’ll use the range of 1 through 20 (because surely 20 coffees a day is enough for anyone?), **but we’ll also display one of two labels inside the stepper to handle pluralization better**. **If the user has set a `coffeeAmount` of exactly 1 we’ll show “1 cup”, otherwise we’ll use that amount plus “cups”.**

    Add these inside the **`VStack`**, below the previous views:

    ```swift
    Text("Daily coffee intake")
        .font(.headline)

    Stepper(value: $coffeeAmount, in: 1...20) {
        if coffeeAmount == 1 {
            Text("1 cup")
        } else {
            Text("\(coffeeAmount) cups")
        }
    }
    ```

    **The final thing we need is a button to let users calculate the best time they should go to sleep**. We could do that with a simple button at the end of the **`VStack`**, but to spice up this project a little I want to try something new: **we’re going to add a button directly to the navigation bar.**

    First **we need a method for the button to call**, so add an empty **`calculateBedtime()`** method like this:

    ```swift
    func calculateBedtime() {
    }
    ```

    **Now we need to use the `navigationBarItems()` modifier to add a trailing button to the navigation view**. “Trailing” in left-to-right languages like English means “on the right”, and you can provide any view here – **if you want several buttons, you could use a `HStack`, for example**. While we’re here, we might as well also use **`navigationBarTitle()`** to put some text at the top.

    So, add these modifiers to the **`VStack`**:

    ```swift
    .navigationBarTitle("BetterRest")
    .navigationBarItems(trailing:
        // our button here
    )
    ```

    **In our case we want to replace that comment with a “Calculate” button. Previously I explained that buttons come in two forms**:

    ```swift
    Button("Hello") {
        print("Button was tapped")
    }

    Button(action: {
        print("Button was tapped")
    }) {
        Text("Hello")
    }
    ```

    We could use the first option here, if we wanted:

    ```swift
    Button("Calculate") {
        self.calculateBedtime()
    }
    ```

    **That would work fine, but I’d like you reconsider.** 

    **That code creates a new closure, and the closure’s sole job is to call a method.** 

    Closures are, for the most part, just functions without a name – we assign them directly to something, rather than having them as a separate entity.

    So, **we’re creating a function that just calls another function**. Wouldn’t it be better for everyone if we could skip that middle layer entirely?

    Well, we *can*. **What the button cares about is that its action is some sort of function that accepts no parameters and sends nothing back – it doesn’t care whether that’s a method or a closure, as long as they both follow those rules.**

    As a result, **we can actually send `calculateBedtime` directly to the button’s action**, like this:

    ```swift
    Button(action: calculateBedtime) {
        Text("Calculate")
    }
    ```

    Now, **when people see that they often think I’ve made a mistake. They want to write this instead**:

    ```swift
    Button(action: calculateBedtime()) {
        Text("Calculate")
    }
    ```

    **However, that code won’t work and in fact means something quite different.** 

    **If we add the parentheses after `calculateBedtime` it means “call `calculateBedtime()` and it will send back to the correct function to use when the button is tapped.” So, Swift would require that `calculateBedtime()` returns a closure to run.**

    **By writing `calculateBedtime` rather than `calculateBedtime()` we’re telling Swift to run that method when the button is tapped, and nothing more; it won’t return anything that should then be run.**

    Swift really blurs the lines between functions, methods, closures, and even operators (**`+`**, **`-`** and so on), which is what allows us to use them so interchangeably.

    So, the whole modifier should look like this:

    ```swift
    .navigationBarItems(trailing:
        Button(action: calculateBedtime) {
            Text("Calculate")
        }
    )
    ```

    That won’t do anything yet because **`calculateBedtime()`** is empty, but at least our UI is good enough for the time being.

- **Connecting SwiftUI to Core ML**

    In the same way that SwiftUI makes user interface development easy, Core ML makes machine learning easy. How easy? Well, once you have a trained model you can get predictions in just two lines of code – **you just need to send in the values that should be used as input, then read what comes back.**

    In our case, we already made a Core ML model using Xcode’s Create ML app, so we’re going to use that. You should have saved it on your desktop, so please now **drag it into the project navigator in Xcode – just below Info.plist should do the trick.**

    **When you add an .mlmodel file to Xcode, it will automatically create a Swift class of the same name.** 

    **You can’t see the class, and don’t need to – it’s generated automatically as part of the build process.** 

    However, **it *does* mean that if your model file is named oddly then the auto-generated class name will also be named oddly.**

    In my case, I had a file called “BetterRest 1.mlmodel”, which meant Xcode would generate a Swift class called **`BetterRest_1`**. No matter what name your model file has, **please rename it to be `“SleepCalculator.mlmodel”`, thus making the auto-generated class be called `SleepCalculator`.**

    How can we be sure? Well, **just select the model file itself and Xcode will show you more information.** 

    You’ll see it knows our author and description, the name of the Swift class that gets made, plus a list of inputs and their types, and an output plus type too – these were encoded in the model file, which is why it was (comparatively!) so big.

    Let’s start filling in **`calculateBedtime()`**. **First, we need to create an instance of the `SleepCalculator` class**, like this:

    ```swift
    let model = SleepCalculator()
    ```

    **That’s the thing that reads in all our data, and will output a prediction.** 

    **We trained our model with a CSV file containing the following fields**:

    - **“wake”**: **when the user wants to wake up**. This is expressed as the **number of seconds from midnight**, so 8am would be 8 hours multiplied by 60 multiplied by 60, giving 28800.
    - **“estimatedSleep”**: **roughly how much sleep the user wants to have**, **stored as values from 4 through 12 in quarter increments**.
    - **“coffee”**: **roughly how many cups of coffee the user drinks per day**.

    So, **in order to get a prediction out of our model, we need to fill in those values.**

    We already have two of them, because our **`sleepAmount`** and **`coffeeAmount`** properties are mostly good enough – **we just need to convert `coffeeAmount` from an integer to a `Double`** so that Swift is happy.

    But figuring out the wake time requires more thinking, because **our `wakeUp` property is a `Date` not a `Double` representing the number of seconds.** 

    Helpfully, this is where Swift’s **`DateComponents`** type comes in: **it stores all the parts required to represent a date as individual values, meaning that we can read the hour and minute components and ignore the rest**. 

    **All we then need to do is multiply the minute by 60 (to get seconds rather than minutes), and the hour by 60 and 60 (to get seconds rather than hours).**

    We can get a **`DateComponents`** instance from a **`Date`** with a very specific method call: **`Calendar.current.dateComponents()`**. 

    We can then request the hour and minute components, and pass in our wake up date. 

    The **`DateComponents`** instance that comes back has properties for all its components – year, month, day, timezone, etc – but most of them won’t be set. **The ones we asked for – hour and minute – *will* be set, but will be optional, so we need to unwrap them carefully.**

    So, put this directly below the previous line in **`calculateBedtime()`**:

    ```swift
    let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
    let hour = (components.hour ?? 0) * 60 * 60
    let minute = (components.minute ?? 0) * 60
    ```

    **That code uses 0 if either the hour or minute can’t be read, but realistically that’s never going to happen so it will result in `hour` and `minute` being set to those values in seconds.**

    **The next step is to feed our values into Core ML and see what comes out.** 

    **This might fail if Core ML hits some sort of problem, so we need to use `do` and `catch`.** 

    Honestly, I can’t think I’ve ever had a prediction fail in my life, but there’s no harm being safe!

    So, we’re going to create a **`do/catch`** block, and inside there use the **`prediction()`** method of our model. **This wants the wake time, estimated sleep, and coffee amount values required to make a prediction, all provided as `Double` values.** 

    We just calculated our **`hour`** and **`minute`** as seconds, so we’ll add those together before sending them in.

    Please add this code to **`calculateBedtime()`** now:

    ```swift
    do {
        let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))

        // more code here
    } catch {
        // something went wrong!
    }
    ```

    With that in place, **`prediction`** **now contains how much sleep they actually need**. This almost certainly wasn’t part of the training data our model saw, but was instead computed dynamically by the Core ML algorithm.

    **However, it’s not a helpful value for users – it will be some number in seconds**. 

    What we want is to **convert that into the time they should go to bed**, **which means we need to subtract that value in seconds from the time they need to wake up.**

    Thanks to Apple’s powerful APIs, that’s just one line of code – **you can subtract a value in seconds directly from a `Date`, and you’ll get back a new `Date`!** 

    So, add this line of code after the prediction:

    ```swift
    let sleepTime = wakeUp - prediction.actualSleep
    ```

    And now we know exactly when they should go to sleep. **Our final challenge, for now at least, is to show that to the user.** 

    **We’ll be doing this with an alert**, because you’ve already learned how to do that and could use the practice.

    So, **start by adding three properties that determine the title and message of the alert, and whether or not it’s showing**:

    ```swift
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    ```

    We can immediately use those values in **`calculateBedtime()`**. If our calculation goes wrong – if reading a prediction throws an error – we can replace the **`// something went wrong`** comment with some code that sets up a useful error message:

    ```swift
    alertTitle = "Error"
    alertMessage = "Sorry, there was a problem calculating your bedtime." 
    ```

    **And regardless of whether or not the prediction worked, we should show the alert**. 

    It might contain the results of their prediction or it might contain the error message, but it’s still useful. So, put this at the end of **`calculateBedtime()`**, *after* the **`catch`** block:

    ```swift
    showingAlert = true
    ```

    Now for the more challenging part: **if the prediction worked we create a constant called `sleepTime` that contains the time they need to go to bed.** 

    **But this is a `Date` rather than a neatly formatted string, so we need to use Swift’s `DateFormatter` to make that look better.**

    **`DateFormatter`** can format dates and times in all sorts of ways using its **`dateStyle`** and **`timeStyle`** properties. In this instance, though, we just want a time string so we can put that into **`alertMessage`**.

    So, put these final lines of code into **`calculateBedtime()`**, directly after where we set the **`sleepTime`** constant:

    ```swift
    let formatter = DateFormatter()
    formatter.timeStyle = .short

    alertMessage = formatter.string(from: sleepTime)
    alertTitle = "Your ideal bedtime is…"
    ```

    **To wrap up this stage of the app, we just need to add an `alert()` modifier that shows `alertTitle` and `alertMessage` when `showingAlert` becomes true.**

    Please add this modifier to our **`VStack`**:

    ```swift
    .alert(isPresented: $showingAlert) {
        Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
    }
    ```

    Now go ahead and run the app – it works! It doesn’t look *great*, but it works.

- **Cleaning up the user interface**

    Although our app works right now, it’s not something you’d want to ship on the App Store – it has at least one major usability problem, and the design is… well… let’s say “substandard”.

    Let’s look at the usability problem first, because it’s possible it hasn’t occurred to you. 

    **When you create a new instance of `Date` it is automatically set to the current date and time.** 

    **So, when we create our `wakeUp` property with a new date, the default wake up time will be whatever time it is right now.**

    Although the app needs to be able to handle any sort of times – we don’t want to exclude folks on night shift, for example – **I think it’s safe to say that a default wake up time somewhere between 6am and 8am is going to be more useful to the vast majority of users.**

    T**o fix this we’re going to add a computed property to our `ContentView` struct that contains a `Date` value referencing 7am of the current day**. This is surprisingly easy: we can just create a new **`DateComponents`** of our own, and use **`Calendar.current.date(from:)`** to convert those components into a full date.

    So, add this property to **`ContentView`** now:

    ```swift
    var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date()
    }
    ```

    And now we can use that for the default value of **`wakeUp`** in place of **`Date()`**:

    ```swift
    @State private var wakeUp = defaultWakeTime
    ```

    **If you try compiling that code you’ll see it fails, and the reason is that we’re accessing one property from inside another.**

    **Swift doesn’t know which order the properties will be created in**, so this isn’t allowed.

    **The fix** here is simple: **we can make `defaultWakeTime` a static variable, which means it belongs to the `ContentView` struct itself rather than a single instance of that struct**. 

    This in turn means **`defaultWakeTime`** **can be read whenever we want, because it doesn’t rely on the existence of any other properties.**

    So, change the property definition to this:

    ```swift
    static var defaultWakeTime: Date {
    ```

    That fixes our usability problem, because the majority of users will find the default wake up time is close to what they want to choose.

    As for our styling, this requires more effort. **A simple change to make is to switch to a `Form` rather than a `VStack`.** So, find this:

    ```swift
    NavigationView {
        VStack {
    ```

    And replace it with this:

    ```swift
    NavigationView {
        Form {
    ```

    That immediately makes the UI look better – **we get a clearly segmented table of inputs, rather than some controls centered in a white space.**

    If you prefer, you can get the old style back by specifically asking for the wheel picker to be used. We lost it when we moved to a **`Form`**, because **`DatePicker`** has a different style when used in forms, but we can get it back by using the modifier **`.datePickerStyle(WheelDatePickerStyle())`**.

    So, modify your date picker code to this:

    ```swift
    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
        .labelsHidden()
        .datePickerStyle(WheelDatePickerStyle())
    ```

    **Tip:** **Wheel pickers are available only on iOS and watchOS, so if you plan to write SwiftUI code for macOS or tvOS you should avoid them.**

    There’s still an annoyance in our form: **every view inside the form is treated as a row in the list, when really all the text views form part of the same logical form section.**

    We *could* use **`Section`** views here, with our text views as titles – you’ll get to experiment with that in the challenges. **Instead, we’re going to wrap each pair of text view and control with a `VStack` so they are seen as a single row each.**

    Go ahead and wrap each of the pairs in a **`VStack`** now, using **`.leading`** for the alignment and 0 for spacing. For example, you’d take these two views:

    ```swift
    Text("Desired amount of sleep")
        .font(.headline)

    Stepper(value: $sleepAmount, in: 4...12, step: 0.25) {
        Text("\(sleepAmount, specifier: "%g") hours")
    }
    ```

    And wrap them in a **`VStack`** like this:

    ```swift
    VStack(alignment: .leading, spacing: 0) {
        Text("Desired amount of sleep")
            .font(.headline)

        Stepper(value: $sleepAmount, in: 4...12, step: 0.25) {
            Text("\(sleepAmount, specifier: "%g") hours")
        }
    }
    ```

    And now run the app one last time, because it’s done – good job!