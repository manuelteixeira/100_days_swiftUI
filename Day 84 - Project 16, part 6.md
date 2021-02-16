# Day 84 - Project 16, part 6

- **Saving and loading data with UserDefaults**

    This app mostly works, but **it has one fatal flaw: any data we add gets wiped out when the app is relaunched**, which doesn’t make it much use for remembering who we met. 

    **We can fix this by making the `Prospects` initializer able to load data from `UserDefaults`, then write it back when the data changes.**

    This time our data is stored using a slightly easier format: **although the `Prospects` class uses the `@Published` property wrapper, the `people` array inside it is simple enough that it already conforms to `Codable` just by adding the protocol conformance**. So, we can get most of the way to our goal by **making three small changes**:

    1. **Updating the `Prospects` initializer so that it loads its data from `UserDefaults`** where possible.
    2. **Adding a `save()` method** to the same class, **writing the current data *to*** **`UserDefaults`**.
    3. **Calling `save()` when adding a prospect or toggling its `isContacted` property**.

    We’ve looked at the code to do all that previously, so let’s get to it. We already have a simple initializer for **`Prospects`**, so we can update it to use **`UserDefaults`** like this:

    ```swift
    init() {
        if let data = UserDefaults.standard.data(forKey: "SavedData") {
            if let decoded = try? JSONDecoder().decode([Prospect].self, from: data) {
                self.people = decoded
                return}
        }

        self.people = []
    }
    ```

    As for the **`save()`** method, this will do the same thing in reverse – add this:

    ```swift
    func save() {
        if let encoded = try? JSONEncoder().encode(people) {
            UserDefaults.standard.set(encoded, forKey: "SavedData")
        }
    }
    ```

    **Our data is changed in two places, so we need to make both of those call `save()` to make sure the data is always written out**.

    The first is in the **`toggle()`** method of **`Prospects`**, so modify it to this:

    ```swift
    func toggle(_ prospect: Prospect) {
        objectWillChange.send()
        prospect.isContacted.toggle()
        save()
    }
    ```

    The second is in the **`handleScan(result:)`** method of **`ProspectsView`**, where we add new prospects to the array. Find this line:

    ```swift
    self.prospects.people.append(person)
    ```

    And add this directly below:

    ```swift
    self.prospects.save()
    ```

    **If you run the app now you’ll see that any contacts you add will remain there even after you relaunch the app**, so we could easily stop here. 

    **However, this time I want to go a stage further and fix two other problems**:

    1. **We’ve had to hard-code the key name “SavedData” in two places**, which again **might cause problems in the future** if the name changes or needs to be used in more places.
    2. **Having to call `save()` inside `ProspectsView` isn’t good design, partly because our view really shouldn’t know about the internal workings of its model**, but **also because if we have other views working with the data then we might forget to call `save()` there**.

    **To fix the first problem we should create a static property on `Prospects` to contain our save key**, so we use that property rather than a string for **`UserDefaults`**.

    Add this to the **`Prospects`** class:

    ```swift
    static let saveKey = "SavedData"
    ```

    We can then use that rather than a hard-coded string, first by modifying the initializer like this:

    ```swift
    if let data = UserDefaults.standard.data(forKey: Self.saveKey) {
    ```

    And by modifying the **`save()`** method to this:

    ```swift
    UserDefaults.standard.set(encoded, forKey: Self.saveKey)
    ```

    **This approach is much safer in the long term** – it’s far too easy to write “SaveKey” or “savedKey” by accident, and in doing so introduce all sorts of bugs.

    As for the problem of calling **`save()`**, this is actually a deeper problem: **when we write code like `self.prospects.people.append(person)` we’re breaking a software engineering principle known as *encapsulation***. 

    This is the idea that **we should limit how much external objects can read and write values inside a class or a struct, and instead provide methods for reading (getters) and writing (setters) that data.**

    In practical terms, this means **rather than writing `self.prospects.people.append(person)` we’d instead create an `add()` method on the `Prospects` class, so we could write code like this: `self.prospects.add(person)`**. 

    The result would be the same – our code adds a person to the **`people`** array – but **now the implementation is hidden away**. 

    **This means that we could switch the array out to something else and `ProspectsView` wouldn’t break**, but it **also means we can add extra functionality to the `add()` method.**

    So, to solve the second problem we’re going to create an **`add()`** method in **`Prospects`** so that we can internally trigger **`save()`**. Add this now:

    ```swift
    func add(_ prospect: Prospect) {
        people.append(prospect)
        save()
    }
    ```

    Even better, **we can use access control to stop external writes to the `people` array, meaning that our views must use the `add()` method to add prospects**. This is done by changing the definition of the **`people`** property to this:

    ```swift
    @Published private(set) var people: [Prospect]
    ```

    Now that only code inside **`Prospects`** calls the **`save()`** method, we can mark *that* as being private too:

    ```swift
    private func save() {
    ```

    **This helps lock down our code so that we can’t make mistakes by accident** – the compiler simply won’t allow it. In fact, if you try building the code now you’ll see exactly what I mean: **`ProspectsView`** tries to append to the **`people`** array and call **`save()`**, which is no longer allowed.

    To fix that error and get our code compiling cleanly again, replace those two lines with this:

    ```swift
    self.prospects.add(person)
    ```

    Switching away from strings then using encapsulation and access control are simple ways of making our code safer, and are some great steps towards building better software.

- **Posting notifications to the lock screen**

    For the final part of our app, **we’re going to add another button to our context menu, letting users opt to be reminded to contact a particular person**. 

    **This will use iOS’s UserNotifications framework to create a local notification**, and we’ll conditionally include it in the context menu with a simple **`if`** check – SwiftUI is smart enough to add the context menu button if the test passes.

    Much more interesting is how we schedule the local notifications. Remember, **the first time we try this we need to use `requestAuthorization()` to explicitly ask for permission to show a notification on the lock screen, but we also need to be careful subsequent times because the user can retroactively change their mind and disable notifications.**

    **One option is to call `requestAuthorization()` *every time we want to post a notification***, and honestly that works great: the first time it will show an alert, and all other times it will immediately return success or failure based on the previous response.

    **However, in the interests of completion I want to show you a more powerful alternative: we can request the current authorization settings, and use that to determine whether we should schedule a notification or request permission**. 

    **The reason it’s helpful to use *this* approach rather than just requesting permission repeatedly, is that the settings object handed back to us includes properties such as `alertSetting` to check whether we can show an alert or not** – **the user might have restricted this so all we can do is display a numbered badge on our icon.**

    So, **we’re going to call `getNotificationSettings()` to read whether notifications are currently allowed**. 

    If they are, we’ll show a notification. If they *aren’t*, we’ll request permissions, and if *that* comes back successfully then we’ll also show a notification. **Rather than repeat the code to schedule a notification, we’ll put it inside a closure that can be called in either scenario.**

    Start by adding this import near the top of ProspectsView.swift:

    ```swift
    import UserNotifications
    ```

    Now add this method to the **`ProspectsView`** struct:

    ```swift
    func addNotification(for prospect: Prospect) {
        let center = UNUserNotificationCenter.current()

        let addRequest = {
            let content = UNMutableNotificationContent()
            content.title = "Contact \(prospect.name)"
            content.subtitle = prospect.emailAddress
            content.sound = UNNotificationSound.default
    				var dateComponents = DateComponents()
            dateComponents.hour = 9
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            center.add(request)
        }

        // more code to come
    }
    ```

    **That puts all the code to create a notification for the current prospect into a closure, which we can call whenever we need**. 

    Notice that I’ve used **`UNCalendarNotificationTrigger`** for the trigger, which lets us specify a custom **`DateComponents`** instance. I set it to have an hour component of 9, which means it will trigger the next time 9am comes about.

    **Tip:** For testing purposes, I recommend you comment out that trigger code and replace it with the following, which shows the alert five seconds from now:

    ```swift
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
    ```

    For the second part of that method we’re going to use both **`getNotificationSettings()`** and **`requestAuthorization()`** together, to make sure we only schedule notifications when allowed. This will use the **`addRequest`** closure we defined above, because the same code can be used if we have permission already or if we ask and have been granted permission.

    Replace the **`// more code to come`** comment with this:

    ```
    center.getNotificationSettings { settings inif settings.authorizationStatus == .authorized {
            addRequest()
        } else {
            center.requestAuthorization(options: [.alert, .badge, .sound]) { success, error inif success {
                    addRequest()
                } else {
                    print("D'oh")
                }
            }
        }
    }
    ```

    That’s all the code we need to schedule a notification for a particular prospect, so all that remains is to add an extra button to our context menu – add this below the previous button:

    ```
    if !prospect.isContacted {
        Button("Remind Me") {
            self.addNotification(for: prospect)
        }
    }
    ```

    That completes the current step, and completes our project too – try running it now and you should find that you can add new prospects, then press and hold to either mark them as contacted, or to schedule a contact reminder.

    Good job!