# Day 38 - Project 7, part 3

- Challenge

    1. Add an Edit/Done button to **`ContentView`** so users can delete rows more easily.

        ```swift
        var body: some View {
            NavigationView {
                List {
                    ForEach(expenses.items) { item in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(item.name)
                                    .font(.headline)
                                Text(item.type)
                            }

                            Spacer()
                            Text("$\(item.amount)")
                        }
                    }
                    .onDelete(perform: removeItems)
                }
                .navigationBarTitle("iExpense")
                .navigationBarItems(leading:
                    EditButton()
                    , trailing:
                    Button(action: {
                        self.showingAddExpense = true
                    }, label: {
                        Image(systemName: "plus")
                    }
                    )
                )
            }
            .sheet(isPresented: $showingAddExpense) {
                AddView(expenses: self.expenses)
            }
        }
        ```

    2. Modify the expense amounts in **`ContentView`** to contain some styling depending on their value – expenses under $10 should have one style, expenses under $100 another, and expenses over $100 a third style. What those styles are depend on you.

        ```swift
        ForEach(expenses.items) { item in
            HStack {
                VStack(alignment: .leading) {
                    Text(item.name)
                        .font(.headline)
                    Text(item.type)
                }

                Spacer()
                Text("$\(item.amount)")
                    .font(self.fontStyle(for: item.amount))
                    .foregroundColor(self.fontColor(for: item.amount))
            }
        }
        ```

        ```swift
        func fontStyle(for amount: Int) -> Font {
            switch amount {
            case 0 ... 10:
                return .caption
            case 11 ... 100:
                return .body
            default:
                return .headline
            }
        }

        func fontColor(for amount: Int) -> Color {
            switch amount {
            case 0 ... 10:
                return .gray
            case 11 ... 100:
                return .black
            default:
                return .red
            }
        }
        ```

    3. Add some validation to the Save button in **`AddView`**. If you enter “fish” or another thing that can’t be converted to an integer, show an alert telling users what the problem is.

        ```swift
        var body: some View {
            NavigationView {
                Form {
                    TextField("Name", text: $name)

                    Picker("Type", selection: $type) {
                        ForEach(Self.types, id: \.self) {
                            Text($0)
                        }
                    }

                    TextField("Amount", text: $amount)
                        .keyboardType(.numberPad)
                }
                .navigationBarTitle("Add new expense")
                .navigationBarItems(trailing:
                    Button("Save") {
                        if let actualAmount = Int(self.amount) {
                            let item = ExpenseItem(name: self.name, type: self.type, amount: actualAmount)
                            self.expenses.items.append(item)
                            self.presentationMode.wrappedValue.dismiss()
                        } else {
                            self.isAlertShowing = true
                        }
                    }
                )
            }
            .alert(isPresented: $isAlertShowing) { () -> Alert in
                Alert(title: Text("Incorrect input"), message: Text("Please insert a valid number"), dismissButton: .default(Text("Ok")))
            }
        }
        ```