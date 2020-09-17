# Day 18 - Project 1, part three

- **Challenges**

    1. Add a header to the third section, saying “Amount per person”

        ```swift
        Section(header: Text("Amount per person")) {
            Text("$\(totalPerPerson, specifier: "%.2f")")
        }
        ```

    2. Add another section showing the total amount for the check – i.e., the original amount plus tip value, without dividing by the number of people.

        ```swift
        var totalAmountWithTip: Double {
            let tipSelection = Double(tipPercentages[tipPercentage])
            let orderAmount = Double(checkAmount) ?? 0
            
            let tipValue = orderAmount / 100 * tipSelection
            let grandTotal = orderAmount + tipValue
            
            return grandTotal
        }

        var totalPerPerson: Double {
            let peopleCount = Double(numberOfPeople + 2)
            
            let grandTotal = totalAmountWithTip
            let amountPerPerson = grandTotal / peopleCount
            
            return amountPerPerson
        }
        ```

        ```swift
        Section(header: Text("Amount and tip")) {
            Text("$\(totalAmountWithTip, specifier: "%.2f")")
        }
        ```

    3. Change the “Number of people” picker to be a text field, making sure to use the correct keyboard type.

        ```swift
        @State private var checkAmount = ""
        @State private var numberOfPeople = ""
        @State private var tipPercentage = 2

        let tipPercentages = [10, 15, 20, 25, 0]

        var totalAmountWithTip: Double {
            let tipSelection = Double(tipPercentages[tipPercentage])
            let orderAmount = Double(checkAmount) ?? 0
            
            let tipValue = orderAmount / 100 * tipSelection
            let grandTotal = orderAmount + tipValue
            
            return grandTotal
        }

        var totalPerPerson: Double {
            let peopleCount = Double(numberOfPeople) ?? 1
            
            let grandTotal = totalAmountWithTip
            let amountPerPerson = grandTotal / peopleCount
            
            return amountPerPerson
        }
        ```

        ```swift
        Section {
            TextField("Amount", text: $checkAmount)
                .keyboardType(.decimalPad)
            
            TextField("Number of people", text: $numberOfPeople)
                .keyboardType(.numberPad)
        }
        ```