# Day 24 - Project 3, part 2

- Challenge

    1. Create a custom **`ViewModifier`** (and accompanying **`View`** extension) that makes a view have a large, blue font suitable for prominent titles in a view.

        ```swift
        struct BigTitle: ViewModifier {
            func body(content: Content) -> some View {
                content
                    .font(.largeTitle)
                    .foregroundColor(.blue)
            }
        }

        extension View {
            func bigTitle() -> some View {
                return self.modifier(BigTitle())
            }
        }

        struct ContentView: View {
            var body: some View {
                Text("Hello world")
                    .bigTitle()
            }
        }
        ```

    2. Go back to project 1 and use a conditional modifier to change the total amount text view to red if the user selects a 0% tip.

        ```swift
        Section(header: Text("Amount per person")) {
            Text("$\(totalPerPerson, specifier: "%.2f")")
                .foregroundColor(tipPercentages[tipPercentage] == 0 ? .red : .black)
        }
                        
        Section(header: Text("Amount and tip")) {
            Text("$\(totalAmountWithTip, specifier: "%.2f")")
                .foregroundColor(tipPercentages[tipPercentage] == 0 ? .red : .black)
        }
        ```

    3. Go back to project 2 and create a **`FlagImage()`** view that renders one flag image using the specific set of modifiers we had.

        ```swift
        struct FlagImage: View {
            var country: String
            
            var body: some View {
                Image(country)
                    .renderingMode(.original)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Color.black, lineWidth: 1))
                    .shadow(color: Color.black, radius: 2)
            }
        }
        ```

        ```swift
        ForEach(0 ..< 3) { number in
            Button(action: {
                self.flagTapped(number)
            }) {
                FlagImage(country: self.countries[number])
            }
        }
        ```