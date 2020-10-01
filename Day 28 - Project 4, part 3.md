# Day 28 - Project 4, part 3

- Challenge

    One of the best ways to learn is to write your own code as often as possible, so here are three ways you should try extending this app to make sure you fully understand what’s going on:

    1. Replace each **`VStack`** in our form with a **`Section`**, where the text view is the title of the section. Do you prefer this layout or the **`VStack`** layout? It’s your app – you choose!

        ```swift
        var body: some View {
            NavigationView {
                Form {
                    Section(header: Text("When do you want to wake up?")) {
                        DatePicker("Please enter a time",
                                   selection: $wakeUp,
                                   displayedComponents: .hourAndMinute)
                            .labelsHidden()
                            .datePickerStyle(WheelDatePickerStyle())
                    }
                    
                    Section(header: Text("Desired amount of sleep")) {
                        Stepper(value: $sleepAmount, in: 4...12, step: 0.25) {
                            Text("\(sleepAmount, specifier: "%g") hours")
                        }
                    }
                    
                    Section(header: Text("Daily coffee intake")) {
                        Stepper(value: $coffeeAmount, in: 1...20) {
                            if coffeeAmount == 1 {
                                Text("1 cup")
                            } else {
                                Text("\(coffeeAmount) cups")
                            }
                        }
                    }
                }.navigationBarTitle("BetterRest")
                .navigationBarItems(trailing:
                    Button(action: calculateBedTime) {
                        Text("Calculate")
                    }
                )
                .alert(isPresented: $showingAlert) { () -> Alert in
                    Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("Ok")))
                }
            }
        }
        ```

    2. Replace the “Number of cups” stepper with a **`Picker`** showing the same range of values.

        ```swift
        Section(header: Text("Daily coffee intake")) {
            Picker("Number of cups", selection: $coffeeAmount) {
                ForEach(1..<21) { number in
                    if number == 1 {
                        Text("1 cup")
                    } else {
                        Text("\(number) cups")
                    }
                }
            }
            .labelsHidden()
        }
        ```

    3. Change the user interface so that it always shows their recommended bedtime using a nice and large font. You should be able to remove the “Calculate” button entirely.

        ```swift
        private var bedTime: String {
            let model = SleepCalculator()
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            do {
                let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
                
                let sleepTime = wakeUp - prediction.actualSleep
                
                let formatter = DateFormatter()
                formatter.timeStyle = .short
                
                return formatter.string(from: sleepTime)
            } catch {
                showingAlert = true
                return "Error"
            }
        }
        ```

        ```swift
        NavigationView {
          VStack {
              Text("You should be in bed by \(bedTime)")
                  .padding()
                  .font(.headline)
        	}
        	...
        }
        ```