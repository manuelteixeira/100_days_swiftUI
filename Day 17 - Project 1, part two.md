# Day 17 - Project 1, part two

- **Reading text from the user with TextField**

    We’re building a check-splitting app, **which means users need to be able to enter the cost of their check, how many people are sharing the cost, and how much tip they want to leave.**

    Hopefully already you can see that **means we need to add three `@State` properties**, because there are three pieces of data we’re expecting users to enter into our app.

    So, start by adding these three properties to our **`ContentView`** struct:

    ```swift
    @State private var checkAmount = ""
    @State private var numberOfPeople = 2
    @State private var tipPercentage = 2
    ```

    As you can see, **that gives us an empty string for the check amount, a default value of 2 for the number of people, and a default value of 2 for the tip percentage.**

    **You might wonder why we’re using strings for the check amount, when clearly an `Int` or `Double` would work better. Well, the reason is that we have no choice:** 

    **SwiftUI *must* use strings to store text field values.**

    **Having two people be the default for splitting a check is sensible** - it won’t be right a lot of the time, but it’s still a good default. 

    **But having a tip percentage of 2 might seem odd: do we really intend to leave a 2% tip?**

    Well, no. **Instead, we’re using 2 here because we’re going to use that to select values from a predetermined array of tip sizes**, so you can see different picker styles in action.

    **We need to store the list of possible tip sizes somewhere, so please add this fourth property beneath the previous three**:

    ```swift
    let tipPercentages = [10, 15, 20, 25, 0]
    ```

    **Now you can see that a tip percentage of 2 actually means a 20% tip**, because that’s the values of **`tipPercentages[2]`**.

    We’re going to build up the form step by step, starting with a text field where users can enter the value of their check.

    Modify the **`body`** property to this:

    ```swift
    var body: some View {
        Form {
            Section {
                TextField("Amount", text: $checkAmount)
            }
        }
    }
    ```

    **That will create a scrolling entry form of one section, which in turn contains one row: our text field.** 

    **When you create text fields in forms, the first parameter is a string that gets used as the *placeholder*** – **gray text shown in side the text field, giving users an idea of what should be in there**. 

    The **second parameter is the two-way binding to our `checkAmount` property, which means as the user types that property will be updated.**

    **One of the great things about the `@State` property wrapper is that it automatically watches for changes, and when something happens it will automatically re-invoke the `body` property**. 

    That’s a **fancy way of saying it will reload your UI to reflect the changed state**, and it’s a fundamental feature of the way SwiftUI works.

    To demonstrate this, add a second section with a text view showing the value of **`checkAmount`**, like this:

    ```swift
    Form {
        Section {
            TextField("Amount", text: $checkAmount)
        }

        Section {
            Text("$\(checkAmount)")
        }
    }
    ```

    We’ll be making that show something else later on, but for now please run the app in the simulator so you can try it yourself.

    **Tap on the check amount text field, then enter some text – it doesn’t need to be a number; anything will do. What you’ll see is that as you type the text view in the second section automatically and immediately reflects your actions.**

    **This synchronization happens because**:

    1. **Our text field has a two-way binding to the `checkAmount` property.**
    2. **The `checkAmount` property is marked with `@State`, which automatically watches for changes in the value.**
    3. **When an `@State` property changes SwiftUI will re-invoke the `body` property** (i.e., reload our UI)
    4. **Therefore the text view will get the updated value of `checkAmount`.**

    The final project won’t show **`checkAmount`** in that text view, but it’s good enough for now. Before we move on, though, I want to address **one important problem: when you tap to enter text into our text field, users see a regular alphabetical keyboard. Sure, they can tap a button on the keyboard to get to the numbers screen, but it’s annoying and and not really necessary.**

    Fortunately, **text fields have a modifier that lets us force a different kind of keyboard:** **`keyboardType()`**. 

    **We can give this a parameter specifying the kind of keyboard we want, and in this instance either `.numberPad` or `.decimalPad` are good choices**. 

    **Both of those keyboards will show the digits 0 through 9 for users to tap on, but `.decimalPad` also shows a decimal point so users can enter check amount like $32.50 rather than just whole numbers.**

    So, modify your text field to this:

    ```swift
    TextField("Amount", text: $checkAmount)
        .keyboardType(.decimalPad)
    ```

    **You’ll notice I added a line break before `.keyboardType` and also indented it one level deeper than `TextField` – that isn’t required, but it can help you keep track of which modifiers apply to which views.**

    Go ahead and run the app now and you should find you can now only type numbers into the text field.

    **Tip:** **The `.numberPad` and `.decimalPad` keyboards types tell SwiftUI to show the digits 0 through 9 and optionally also the decimal point, but that doesn’t stop users from *entering* other values**. 

    For example, **if they have a hardware keyboard they can type what they like, and if they copy some text from elsewhere they’ll be able to paste that into the text field no matter what is inside that text**. That’s OK, though – we’ll be handling that eventuality later.

- **Creating pickers in a form**

    SwiftUI’s **pickers serve multiple purposes, and exactly how they look depends on which device you’re using and the context the picker is inside.**

    In our project we have a form asking users to enter how much their check came to, and **we want to add a picker to that so they can select how many people will share the check.**

    **Pickers**, like text fields, **need a two-way binding to a property so they can track their value**. 

    **We already made an `@State` property for this purpose, called `numberOfPeople`, so our next job is to loop over all the numbers from 2 through to 99 and show them inside a picker.**

    Modify the first section in your form to include a picker, like this:

    ```swift
    Section {
        TextField("Amount", text: $checkAmount)
            .keyboardType(.decimalPad)

        Picker("Number of people", selection: $numberOfPeople) {
            ForEach(2 ..< 100) {
                Text("\($0) people")
            }
        }
    }
    ```

    Now run the program in the simulator and try it out – what do you notice?

    Hopefully you spot **several things**:

    1. **There’s a new row that says “Number of people” on the left and “4 people” on the right.**
    2. **There’s a gray disclosure indicator on the right edge, which is the iOS way of signaling that tapping the row shows another screen**.
    3. **Tapping the row *doesn’t* show another screen**.
    4. **The row says “4 people”, but we gave our `numberOfPeople` property a default value of 2.**

    So, it’s a bit of “two steps forward, two steps back” – we have a nice result, but it doesn’t work and doesn’t show the right information!

    We’ll fix both of those, starting with the easy one: **why does it say 4 people when we gave `numberOfPeople` the default value of 2?** 

    Well, when creating the picker we used a **`ForEach`** view like this:

    ```swift
    ForEach(2 ..< 100) { ... }
    ```

    **That counts from 2 up to 100, creating rows**. 

    **What that means is that our 0th row** – the first that is created – **contains “2 People”, so when we gave `numberOfPeople` the value of 2 we were actually setting it to the *third* row, which is “4 People”.**

    So, although it’s a bit brain-bending, the fact that our UI shows “4 people” rather than “2 people” isn’t a bug. But **there is still a large bug** in our code: **why does tapping on the row do nothing?**

    **If you create a picker by itself, outside a form, iOS will show a spinning wheel of options**. 

    **Here, though, we’ve told SwiftUI that this is a form for user input, and so it has automatically changed the way our picker looks so that it doesn’t take up so much space.**

    **What SwiftUI *wants* to do – which is also why it’s added the gray disclosure indicator on the right edge of the row – is show a new view with the options from our picker**. 

    **To do that, we need to add a navigation view, which does two things**: 

    **gives us some space across the top to place a title**, 

    and also **lets iOS slide in new views as needed**.

    So, directly before the form add **`NavigationView {`**, and after the form’s closing brace add another closing brace. If you got it right, your code should look like this:

    ```swift
    var body: some View {
        NavigationView {
            Form {
                // everything inside your form
            }
        }
    }
    ```

    **If you run the program again you’ll see a large gray space at the top, which is where iOS is giving us room to place a title**. We’ll do that in a moment, but first **try tapping on the Number Of People row and you should see a new screen slide in with all the other possible options to choose from.**

    You should see that “4 People” has a checkmark next to it because it’s the selected value, but you can also tap a different number instead – the screen will automatically slide away again, taking the user back to the previous screen with their new selection.

    What you’re seeing here is the importance of what’s called ***declarative user interface design*.**
    This means **we say *what* we want rather than say *how* it should be done.** 

    **We said we wanted a picker with some values inside, but it was down to SwiftUI to decide whether a wheel picker or the sliding view approach is better.**

    **It’s choosing the sliding view approach because the picker is inside a form, but on other platforms and environments it could choose something else.**

    Before we’re done with this step, let’s add a title to that new navigation bar. Give the form this modifier:

    ```swift
    .navigationBarTitle("WeSplit")
    ```

    **Tip:** **It’s tempting to think that modifier should be attached to the end of the `NavigationView`, but it needs to be attached to the end of the `Form` instead.** 

    **The reason is that navigation views are capable of showing many views as your program runs, so by attaching the title to the thing inside the navigation view we’re allowing iOS to change titles freely.**

- **Adding a segmented control for tip percentages**

    **Now we’re going to add a second picker view to our app, but this time we want something slightly different: we want a *segmented control*.** 

    **This is a specialized kind of picker that shows a handful of options in a horizontal list, and it works great when you have only a small selection to choose from.**

    Our form already has two sections: one for the amount and number of people, and one where we’ll show the final result – it’s just showing **`checkAmount`** for now, but we’re going to fix it soon.

    In the middle of those two sections I’d like you to add a third to show tip percentages:

    ```swift
    Section {
        Picker("Tip percentage", selection: $tipPercentage) {
            ForEach(0 ..< tipPercentages.count) {
                Text("\(self.tipPercentages[$0])%")
            }
        }
    }
    ```

    **That counts through all the options in our `tipPercentages` array, converting each one into a text view**. 

    **Just like the previous picker, SwiftUI will convert that to a single row in our list, and slide a new screen of options in when it’s tapped.**

    **Here, though, I want to show you how to use a segmented control instead**, because it looks much better. So, please add this modifier to the tip picker:

    ```swift
    .pickerStyle(SegmentedPickerStyle())
    ```

    That should go at the end of the picker’s closing brace, like this:

    ```swift
    Section {
        Picker("Tip percentage", selection: $tipPercentage) {
            ForEach(0 ..< tipPercentages.count) {
                Text("\(self.tipPercentages[$0])%")
            }
        }
        .pickerStyle(SegmentedPickerStyle())
    }
    ```

    If you run the program now you’ll see things are starting to come together: users can now enter the amount on their check, select the number of people, and select how much tip they want to leave – not bad!

    But things aren’t *quite* what you think. One problem app developers face is that we take for granted that our app does what we intended it to do – we designed it to solve a particular problem, so we automatically know what everything means.

    **Try to look at our user interface with fresh eyes, if you can:**

    - **“Amount” makes sense – it’s a box users can type a number into.**
    - **“Number of people” is also pretty self-explanatory.**
    - **The label at the bottom is where we’ll show the total, so right now we can ignore that.**
    - **That middle section, though – what are those percentages for?**

    Yes, *we* know they are to select how much tip to leave, but that isn’t obvious on the screen. We can – and *should* do better.

    **One option is to add another text view directly before the segmented control, which we could do like this:**

    ```swift
    Section {
        Text("How much tip do you want to leave?")

        Picker("Tip percentage", selection: $tipPercentage) {
            ForEach(0 ..< tipPercentages.count) {
                Text("\(self.tipPercentages[$0])%")
            }
        }
        .pickerStyle(SegmentedPickerStyle())
    }
    ```

    **That works OK, but it doesn’t look great – it looks like it’s an item all by itself, rather than a label for the segmented control.**

    **A much better idea is to modify the section itself: SwiftUI lets us add views to the header and footer of a section, which in this instance we can use to add a small explanatory prompt**. 

    In fact, we can use the same text view we just created, just moved up to be the section header rather than a loose label inside it.

    Here’s how that looks in code:

    ```swift
    Section(header: Text("How much tip do you want to leave?")) {
        Picker("Tip percentage", selection: $tipPercentage) {
            ForEach(0 ..< tipPercentages.count) {
                Text("\(self.tipPercentages[$0])%")
            }
        }
        .pickerStyle(SegmentedPickerStyle())
    }
    ```

    It’s a small change to the code, but **I think the end result looks a lot better – the text now looks like a prompt for the segmented control directly below it.**

- **Calculating the total per person**

    So far the final section has shown a simple text view with whatever check amount the user entered, but now it’s time for the important part of this project: **we want that text view to show how much each person needs to contribute to the payment.**

    There are a few ways we could solve this, but the easiest one also happens to be the *cleanest* one, by which I mean it gives us code that is clear and easy to understand: **we’re going to add a computed property that calculates the total.**

    **This needs to do a small amount of mathematics: the total amount payable per person is equal to the value of the order, plus the tip percentage, divided by the number of people.**

    **But before we can get to that point, we first need to pull out the values for how many people there are, what the tip percentage is, and the value of the order. That might sound easy, but there are some small wrinkles:**

    - **As you’ve already seen, `numberOfPeople` is off by 2 – when it stores the value 3 it means 5 people.**
    - **The `tipPercentage` integer stores an index inside the `tipPercentages` array rather than the actual tip percentage.**
    - **The `checkAmount` property is a string that the user entered, which might be a valid number like 20, it might be a string like “fish”, or it might even be empty.**

    So, **we’re going to create a new computed property called `totalPerPerson` that will be a `Double`, and it will start by getting those three values above.**

    First, add the computed property itself, just before the **`body`** property:

    ```swift
    var totalPerPerson: Double {
        // calculate the total per person here
        return 0
    }
    ```

    That sends back 0 so your code doesn’t break, but we’re going to replace the **`// calculate the total per person here`** comment with our calculations.

    Next, **we can figure out how many people there are by reading `numberOfPeople` and adding 2 to it**. Remember, this thing has the range 2 to 100, but it *counts* from 0, which is why we need to add the 2.

    So, start by replacing **`// calculate the total per person here`** with this:

    ```swift
    let peopleCount = Double(numberOfPeople + 2)
    ```

    **You’ll notice that converts the resulting value to a `Double` so we can add everything up and divide it without losing accuracy.**

    Next we need to figure out the actual tip percentage. Our **`tipPercentage`** **property stores the value the user chose, but that’s actually just a position in the `tipPercentages` array.** As a result, we need to look in **`tipPercentages`** to figure out what they chose, and **again convert it to a `Double` so we can keep all our precision** – add this below the previous line:

    ```swift
    let tipSelection = Double(tipPercentages[tipPercentage])
    ```

    The final number we need for our calculation is the value of their check. Now, **if you remember this is actually a string right now, because it’s used as a two-way binding to a text field.** 

    Although we wrote code to show only a decimal pad keyboard, there’s nothing stopping creative users from entering invalid values in there, so we need to be careful how we handle it.

    What we *want* to have is another **`Double`** of the check amount. We *actually* have a string that may or may not contain a valid **`Double`**: it might be 22.50, it might be an empty string, or it might be the complete works of Shakespeare. It’s a string – it can be pretty much anything.

    Fortunately, Swift has a simple way of converting a string to a **`Double`**, and it looks like this:

    ```swift
    let stringValue = "0.5"
    let doubleValue = Double(stringValue)
    ```

    That might look easy enough, **but there’s a catch: the type of `doubleValue` ends up being `Double?` and not `Double` – yes, it’s an optional.** You see, Swift can’t know for sure that the string contains something that can be safely be converted into a **`Double`**, so it uses optionality: if the conversion was successful then our optional will contain the resulting value, but if the string was something invalid (“Fish”, the complete works of Shakespeare, etc) then the optional will be set to nil.

    **There are several ways we could handle the optionality here, but the easiest is to use the nil coalescing operator, `??`, to ensure there’s always a valid value.**

    Please add this code to the **`totalPerPerson`** computed property, below the previous two:

    ```swift
    let orderAmount = Double(checkAmount) ?? 0
    ```

    **That will attempt to convert `checkAmount` into a `Double`, but if that fails for some reason will use 0 instead.**

    Now that we have our three input values, it’s time do our mathematics. This takes another three steps:

    - **We can calculate the tip value by dividing `orderAmount` by 100 and multiplying by `tipSelection`.**
    - **We can calculate the grand total of the check by adding the tip value to `orderAmount`.**
    - **We can figure out the amount per person by dividing the grand total by `peopleCount`.**

    Once that’s done, we can return the amount per person and we’re done.

    Replace **`return 0`** in the property with this:

    ```swift
    let tipValue = orderAmount / 100 * tipSelection
    let grandTotal = orderAmount + tipValue
    let amountPerPerson = grandTotal / peopleCount

    return amountPerPerson
    ```

    If you’ve followed everything correctly your code should look like this:

    ```swift
    var totalPerPerson: Double {
        let peopleCount = Double(numberOfPeople + 2)
        let tipSelection = Double(tipPercentages[tipPercentage])
        let orderAmount = Double(checkAmount) ?? 0

        let tipValue = orderAmount / 100 * tipSelection
        let grandTotal = orderAmount + tipValue
        let amountPerPerson = grandTotal / peopleCount

        return amountPerPerson
    }
    ```

    Now that **`totalPerPerson`** gives us the correct value, **we can change the final section in our table so it shows the correct text.**

    Replace this:

    ```swift
    Section {
        Text("$\(checkAmount)")
    }
    ```

    With this:

    ```swift
    Section {
        Text("$\(totalPerPerson)")
    }
    ```

    Try running the app now, and see what you think. **You should find that because all the values that make up our total are marked with `@State`, changing any of them will cause the total to be recalculated automatically.**

    **Hopefully you’re now seeing for yourself what it means that SwiftUI’s views are a function of their state – when the state changes, the views automatically update to match.**

    Before we’re done, **we’re going to fix a small issue with our interface, which is the way the total price is shown**. 

    **We’re using a `Double` for our amount calculations, which means Swift is giving us much more precision than we need** – **we expect to see something like $25.50, but instead see $25.500000.**

    **We can solve this by using a neat string interpolation feature that SwiftUI adds: the ability to decide how a number ought to be formatted inside the string**. 

    This actually dates way back to the C programming language, so the syntax is a little odd at first: **we write a string called a *specifier*, giving it the value "%.2f”. That’s C’s syntax to mean “a two-digit floating-point number.”**

    Very roughly, **“%f” means “any sort of floating-point number,” which in our case will be the entire number**. 

    **An alternative is “%g”, which does the same thing except it removes insignificant zeroes from the end – $12.50 would be written as $12.5.** 

    **Putting “.2” into the mix is what asks for two digits after the decimal point, regardless of what they are.** SwiftUI is smart enough to round those intelligently, so we still get good precision.

    You can read more about these C-style format specifiers on Wikipedia: [https://en.wikipedia.org/wiki/Printf_format_string](https://en.wikipedia.org/wiki/Printf_format_string) – we aren’t going to any others, so it’s just there if you want to satisfy your curiosity!

    Anyway, we want the amount per person to use our new format specifier, so please modify the total text view to this:

    ```swift
    Text("$\(totalPerPerson, specifier: "%.2f")")
    ```

    Now run the project for the last time – we’re done!