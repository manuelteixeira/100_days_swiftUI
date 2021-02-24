# Day 90 - Project 17, part 5

- **Making iPhones vibrate with UINotificationFeedbackGenerator**

    iOS comes with a number of options for generating haptic feedback, and they are all available for us to use in SwiftUI. In its simplest form, this is **as simple as creating an instance of one of the subclasses of `UIFeedbackGenerator` then calling its `play()` method, but for more precise control over feedback you should first call its `prepare()` method to give the Taptic Engine chance to warm up.**

    **Important:** Warming up the Taptic Engine helps reduce the latency between us calling **`play()`** and the effect actually happening, but it also **has a battery impact** so the system will only stay ready for a second or two after you call **`prepare()`**.

    There are a few different subclasses of **`UIFeedbackGenerator`** we could use, but the one **we’ll use here is `UINotificationFeedbackGenerator` because it provides success and failure haptics** that are common across iOS. 

    Now, **we *could* add one central instance of `UINotificationFeedbackGenerator` to every `ContentView`, but that causes a problem: `ContentView` gets notified whenever a card has been removed, but *isn’t* notified when a drag is in progress, which means we don’t have the opportunity to warm up the Taptic Engine.**

    So, instead **we’re going to give each `CardView` its own instance of `UINotificationFeedbackGenerator` so they can prepare and play them as needed**. The system will take care of making sure the haptics are all neatly arranged, so there’s no chance of them somehow getting confused.

    Add this new property to **`CardView`**:

    ```swift
    @State private var feedback = UINotificationFeedbackGenerator()
    ```

    Now find the **`self.removal?()`** line in the drag gesture of **`CardView`**, and change that whole closure to this:

    ```swift
    if self.offset.width > 0 {
        self.feedback.notificationOccurred(.success)
    } else {
        self.feedback.notificationOccurred(.error)
    }

    self.removal?()
    ```

    **That alone is enough to get haptics in our app, but there is always the risk that the haptic will be delayed because the Taptic Engine wasn’t ready**. In this case the haptic will still play, but it could be up to maybe half a second late – enough to feel just that little bit disconnected from our user interface.

    **To improve this we need to call `prepare()` on our haptic a little *before* calling** **`play()`**. 

    **It is not enough to call `prepare()` immediately before `play()`:** doing so does *not* give the Taptic Engine enough time to warm up, so you won’t see any reduction in latency. Instead, you should call **`prepare()`** as soon as you know the haptic might be needed.

    Now, there are two helpful implementation details that you should be aware of.

    First, **it’s OK to call `prepare()` then never call `play()` – the system will keep the Taptic Engine ready for a few seconds then just power it down again**. 

    **If you repeatedly call `prepare()` and never call `play()` the system might start ignoring your `prepare()` calls until at least one `play()` has happened.**

    Second, **it’s perfectly allowable to call `prepare()` many times before calling `play()` once** – **`prepare()`** doesn’t pause your app while the Taptic Engine warms up, and also doesn’t have any real performance cost when the system is already prepared.

    Putting these two together, **we’re going to update our drag gesture so that `prepare()` is called whenever the gesture changes. This means it could be called a hundred times before `play()` is finally called, because it will get triggered every time the user moves their finger.**

    So, modify your **`onChanged()`** closure to this:

    ```swift
    .onChanged { offset inself.offset = offset.translation
        self.feedback.prepare()
    }
    ```

    Now go ahead and give the app a try and see what you think – you should be able to feel two very different haptics depending on which direction you swipe.

    Before we wrap up with haptics, there’s one thing I want you to consider. Years ago PepsiCo challenged mall shoppers to the “Pepsi Challenge”: drink a sip of one cola drink and a sip of another, and see which you prefer. The results found that more Americans preferred Pepsi than Coca Cola, despite Coke having a much bigger market share. However, there was a problem: people seemed to pick Pepsi in the test because Pepsi had a sweeter taste, and while that worked well in sip-size amounts it worked *less* well in the sizes of cans and bottles, where people actually preferred Coke.

    The reason I’m saying this is because **we added two haptic notifications to our app that will get played a *lot***. 

    And while you’re testing out in small doses these haptics probably feel great – you’re making your phone buzz, and it can be really delightful. However, **if you’re a serious user of this app then our haptics might hit two problems:**

    1. **The user might find them annoying, because they’ll happen once every two or three seconds depending on how fast they are.**
    2. **Worse, the user might become *desensitized* to them – they lose all usefulness either as a notification or as a little spark of delight.**

    So, now you’ve tried it for yourself I want you to think about how they should be used. If this were my app I would probably keep the failure haptic, but I think the success haptic could go – that one is likely to be triggered the most often, and it means when the failure haptic plays it feels a little more special.

- **Fixing the bugs**

    Our SwiftUI app is looking good so far: we have a stack of cards that can be dragged around to control the app, plus haptic feedback and some accessibility support. But at the same time it’s also pretty full of glitches that are holding it back – some big, some small, but all worth addressing.

    **First, it’s possible to drag cards around when they aren’t at the top. This is confusing for users because they can grab a card they can’t actually see, so this should never be possible.**

    To fix this **we’re going to use `allowsHitTesting()` so that only the last card** – **the one on top – can be dragged around.** Find the **`stacked()`** modifier in **`ContentView`** and add this directly below:

    ```swift
    .allowsHitTesting(index == self.cards.count - 1)
    ```

    **Second, our UI is a bit of a mess when used with VoiceOver.** If you launch it on a real device with VoiceOver enabled, you’ll find that **you can tap on the background image** to get “Background, image” read out, which is pointless. However, things get worse: **make small swipes to the right and VoiceOver will move through all the accessibility elements – it reads out the text from all our cards, even the ones that aren’t visible.**

    **To fix the background image** problem we should make it use a decorative image so it won’t be read out as part of the accessibility layout. Modify the background image to this:

    ```swift
    Image(decorative: "background")
    ```

    **To fix the cards, we need to use an `accessibility(hidden:)` modifier with a similar condition to the `allowsHitTesting()` modifier we added a minute ago.** 

    In this case, **every card that’s at an index less than the top card should be hidden from the accessibility system** because there’s really nothing useful it can do with the card, so add this directly below the **`allowsHitTesting()`** modifier:

    ```swift
    .accessibility(hidden: index < self.cards.count - 1)
    ```

    There’s a third accessibility problem with our app, and it’s the direct result of using gestures to control things. Yes, gestures are great fun to use most of the time, but if you have specific accessibility needs it can be very hard to use them.

    In this app **our gestures are causing multiple problems: it’s not apparent to VoiceOver users how they should control the app**:

    1. **We don’t say that the cards are buttons that can be tapped**.
    2. **When the answer is revealed there is no audible notification of what it was**.
    3. **Users have no way of swiping left or right to move through the cards**.

    It takes very little work to fix these problems, but the pay off is that our app is much more accessible to everyone.

    First, **we need to make it clear that our cards are tappable buttons**. This is as simple as adding **`accessibility(addTraits:)`** with **`.isButton`** to the **`ZStack`** in **`CardView`**. Put this after its **`opacity()`** modifier:

    ```swift
    .accessibility(addTraits: .isButton)
    ```

    Now the system will read “Who played the 13th Doctor in Doctor Who? Button” – an important hint to users that the card can be tapped.

    Second, **we need to help the system to read the answer to the cards as well as the questions.** 

    This is *possible* right now, but only if the user swipes around on the screen – it’s far from obvious. So, **to fix this we’re going to detect whether the user has accessibility enabled on their device, and if so automatically toggle between showing the prompt and showing the answer.** 

    That is, **rather than have the answer appear below the prompt we’ll switch it out and just show the answer, which will cause VoiceOver to read it out immediately**.

    Now, **SwiftUI doesn’t have an environment property that tells us when VoiceOver is running**, but instead **has a general property called `\.accessibilityEnabled`**. This *isn’t* triggered when things like Differentiate Without Color, Reduce Motion, or Reduce Transparency are enabled, and it’s the closest option SwiftUI gives us to “VoiceOver Running”.

    So, add this new property to **`CardView`**:

    ```swift
    @Environment(\.accessibilityEnabled) var accessibilityEnabled
    ```

    Right now our code for displaying the prompt and answer looks like this:

    ```swift
    VStack {
        Text(card.prompt)
            .font(.largeTitle)
            .foregroundColor(.black)

        if isShowingAnswer {
            Text(card.answer)
                .font(.title)
                .foregroundColor(.gray)
        }
    }
    ```

    We’re going to change that so the prompt and answer are shown in a single text view, with **`accessibilityEnabled`** deciding which layout is shown. Amend your code to this:

    ```swift
    VStack {
        if accessibilityEnabled {
            Text(isShowingAnswer ? card.answer : card.prompt)
                .font(.largeTitle)
                .foregroundColor(.black)
        } else {
            Text(card.prompt)
                .font(.largeTitle)
                .foregroundColor(.black)

            if isShowingAnswer {
                Text(card.answer)
                    .font(.title)
                    .foregroundColor(.gray)
            }
        }
    }
    ```

    If you try that out with VoiceOver you’ll hear that it works much better – **as soon as the card is double-tapped the answer is read out.**

    **Third, we need to make it easier for users to mark cards as correct or wrong**, because right now our images just don’t cut it. Not only do they stop users from interacting with our app using tap gestures, but they also get read out as their SF Symbols name – “checkmark, circle, image” – rather than anything useful.

    To fix this **we need to replace the images with buttons that actually remove the cards**. We don’t actually do anything different if the user was correct or wrong – I need to leave *something* for your challenges! – but we can at least remove the top card from the deck. At the same time, we’re going to provide an accessibility label and hint so that users get a better idea of what the buttons do.

    So, replace your current **`HStack`** with those images with this new code:

    ```swift
    HStack {
        Button(action: {
            withAnimation {
                self.removeCard(at: self.cards.count - 1)
            }
        }) {
            Image(systemName: "xmark.circle")
                .padding()
                .background(Color.black.opacity(0.7))
                .clipShape(Circle())
        }
        .accessibility(label: Text("Wrong"))
        .accessibility(hint: Text("Mark your answer as being incorrect."))
        
    		Spacer()

        Button(action: {
            withAnimation {
                self.removeCard(at: self.cards.count - 1)
            }
        }) {
            Image(systemName: "checkmark.circle")
                .padding()
                .background(Color.black.opacity(0.7))
                .clipShape(Circle())
        }
        .accessibility(label: Text("Correct"))
        .accessibility(hint: Text("Mark your answer as being correct."))
    }
    ```

    **Because those buttons remain onscreen even when the last card has been removed, we need to add a `guard` check to the start of `removeCard(at:)` to make sure we don’t try to remove a card that doesn’t exist**. So, put this new line of code at the start of that method:

    ```swift
    guard index >= 0 else { return }
    ```

    Finally, **we can make those buttons visible when either `differentiateWithoutColor` is enabled or when VoiceOver is enabled**. This means adding another **`accessibilityEnabled`** property to **`ContentView`**:

    ```swift
    @Environment(\.accessibilityEnabled) var accessibilityEnabled
    ```

    Then modifying the **`if differentiateWithoutColor {`** condition to this:

    ```swift
    if differentiateWithoutColor || accessibilityEnabled {
    ```

    With these accessibility changes our app works much better for everyone – good job!

    Before we’re done, I’d like to add one tiny extra change. **Right now if you drag an image a little then let go we set its offset back to zero, which causes it to jump back into the center of the screen. If we attach a spring animation to our card, it will slide into the center, which I think is a much clearer indication to our user of what actually happened.**

    To make this happen, add an **`animation()`** modifier to the end of the **`ZStack`** in **`CardView`**, directly after the **`onTapGesture()`**:

    ```swift
    .animation(.spring())
    ```

    Much better!

    **Tip:** If you look carefully, you might notice the card flash red if you drag it a little to the right then release. More on that later!

- **Adding and deleting cards**

    Everything we’ve worked on so far has used a fixed set of sample cards, but of course this app **only becomes useful if users can actually customize the list of cards they see. This means adding a new view that lists all existing cards and lets the user add a new one**, which is all stuff you’ve seen before. However, there’s an interesting catch this time that will require something new to fix, so it’s worth working through this.

    **First we need some state that controls whether our editing screen is visible**. So, add this to **`ContentView`**:

    ```swift
    @State private var showingEditScreen = false
    ```

    Next **we need to add a button to flip that Boolean when tapped**, so find the **`if differentiateWithoutColor || accessibilityEnabled`** condition and put this before it:

    ```swift
    VStack {
        HStack {
            Spacer()

            Button(action: {
                self.showingEditScreen = true
            }) {
                Image(systemName: "plus.circle")
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .clipShape(Circle())
            }
        }

        Spacer()
    }
    .foregroundColor(.white)
    .font(.largeTitle)
    .padding()
    ```

    **We’re going to design a new `EditCards` view to encode and decode a `Card` array to `UserDefaults`**, but before we do that I’d like you to make the **`Card`** struct conform to **`Codable`** like this:

    ```swift
    struct Card: Codable {
    ```

    **Now create a new SwiftUI view called “EditCards”. This needs to:**

    1. Have its own **`Card`** array.
    2. Be wrapped in a **`NavigationView`** so we can add a Done button to dismiss the view.
    3. Have a list showing all existing cards.
    4. Add swipe to delete for those cards.
    5. Have a section at the top of the list so users can add a new card.
    6. Have methods to load and save data from **`UserDefaults`**.

    We’ve looked at literally all that code previously, so I’m not going to explain it again here. I hope you can stop to appreciate how far this means you have come!

    Replace the template **`EditCards`** struct with this:

    ```swift
    struct EditCards: View {
        @Environment(\.presentationMode) var presentationMode
        @State private var cards = [Card]()
        @State private var newPrompt = ""
        @State private var newAnswer = ""

        var body: some View {
            NavigationView {
                List {
                    Section(header: Text("Add new card")) {
                        TextField("Prompt", text: $newPrompt)
                        TextField("Answer", text: $newAnswer)
                        Button("Add card", action: addCard)
                    }

                    Section {
                        ForEach(0..<cards.count, id: \.self) { index in
    												VStack(alignment: .leading) {
                                Text(self.cards[index].prompt)
                                    .font(.headline)
                                Text(self.cards[index].answer)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .onDelete(perform: removeCards)
                    }
                }
                .navigationBarTitle("Edit Cards")
                .navigationBarItems(trailing: Button("Done", action: dismiss))
                .listStyle(GroupedListStyle())
                .onAppear(perform: loadData)
            }
        }

        func dismiss() {
            presentationMode.wrappedValue.dismiss()
        }

        func loadData() {
            if let data = UserDefaults.standard.data(forKey: "Cards") {
                if let decoded = try? JSONDecoder().decode([Card].self, from: data) {
                    self.cards = decoded
                }
            }
        }

        func saveData() {
            if let data = try? JSONEncoder().encode(cards) {
                UserDefaults.standard.set(data, forKey: "Cards")
            }
        }

        func addCard() {
            let trimmedPrompt = newPrompt.trimmingCharacters(in: .whitespaces)
            let trimmedAnswer = newAnswer.trimmingCharacters(in: .whitespaces)
            guard trimmedPrompt.isEmpty == false && trimmedAnswer.isEmpty == false else { return }

            let card = Card(prompt: trimmedPrompt, answer: trimmedAnswer)
            cards.insert(card, at: 0)
            saveData()
        }

        func removeCards(at offsets: IndexSet) {
            cards.remove(atOffsets: offsets)
            saveData()
        }
    }
    ```

    That’s almost all of **`EditCards`** complete, but before we can use it **we need to add some more code to `ContentView` so that it shows the sheet on demand and calls `resetCards()` when dismissed.**

    Add this **`sheet()`** modifier to the end of the outermost **`ZStack`** in **`ContentView`**:

    ```swift
    .sheet(isPresented: $showingEditScreen, onDismiss: resetCards) {
        EditCards()
    }
    ```

    As well as calling **`resetCards()`** when the sheet is dismissed, **we also want to call it when the view first appears**, so add this modifier below the previous one:

    ```swift
    .onAppear(perform: resetCards)
    ```

    So, **when the view is first shown `resetCards()` is called, and when it’s shown after `EditCards` has been dismissed `resetCards()` is also called**. This means **we can ditch our example `cards` data and instead make it an empty array that gets filled at runtime.**

    So, change the **`cards`** property of **`ContentView`** to this:

    ```swift
    @State private var cards = [Card]()
    ```

    **To finish up with `ContentView` we need to make it load that `cards` property on demand.** This starts with the same code we just added in **`EditCard`**, so put this method into **`ContentView`** now:

    ```swift
    func loadData() {
        if let data = UserDefaults.standard.data(forKey: "Cards") {
            if let decoded = try? JSONDecoder().decode([Card].self, from: data) {
                self.cards = decoded
            }
        }
    }
    ```

    And now we can add a call to **`loadData()`** in **`resetCards()`**, so **that we refill the `cards` property with all saved cards when the app launches or when the user edits their cards:**

    ```swift
    func resetCards() {
        timeRemaining = 100
        isActive = true
        loadData()        
    }
    ```

    Now go ahead and run the app. We’ve wiped out our default examples, so you’ll need to press the + icon to add some of your own.

    Even though all of our code is correct, the result is unlikely to be what you expected: **when you press + you see a new screen slide in, and it’s totally blank.** We designed a nice list with two sections, a navigation view, a navigation bar item, and more, but all we’re getting is a blank screen.

    What’s happening here has in fact been happening since our very first project, but it’s possible you haven’t noticed: **when you rotate a `NavigationView` to landscape, you get a blank view.** This isn’t a bug, and in fact it’s SwiftUI trying to be helpful.

    You see, **when running in landscape mode on some iPhones, iOS allows two views to sit side by side, where the left-hand view determines what the right-hand view is showing.** 

    **We can customize how the two views work when moving between portrait and landscape, but SwiftUI’s default is to show only the right-hand view – the detail view – and in our case we don’t actually have one, which is why we see a blank screen.**

    To fix this **we need to tell the `NavigationView` that it should only ever show one view at a time**, which means it won’t try to show a non-existent detail view. Add this modifier to the **`NavigationView`** in **`EditCard`**:

    ```swift
    .navigationViewStyle(StackNavigationViewStyle())
    ```

    Now when you run the app everything should work as intended. Honestly this should really be the default setting, because the current default is thoroughly confusing. Regardless, that’s our app complete – good job!