# Day 52 - Project 10, part 4

- Challenge
    1. Our address fields are currently considered valid if they contain anything, even if it’s just only whitespace. Improve the validation to make sure a string of pure whitespace is invalid.

        ```swift
        var hasValidAddress: Bool {
            if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                streetAddress.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                city.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                zip.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return false
            }

            return true
        }
        ```

    2. If our call to **`placeOrder()`** fails – for example if there is no internet connection – show an informative alert for the user. To test this, just disable WiFi on your Mac so the simulator has no connection either.

        ```swift
        @State private var alertTitle = ""
        @State private var alertMessage = ""
        @State private var showingAlert = false

        var body: some View {
            GeometryReader { geo in
                ScrollView {
                    VStack {
                        Image("cupcakes")
                            .resizable()
                            .scaledToFit()
                            .frame(width: geo.size.width)

                        Text("Your total is $\(self.order.cost, specifier: "%2.f")")
                            .font(.title)

                        Button("Place order") {
                            placeOrder()
                        }
                        .padding()
                    }
                }
            }
            .alert(isPresented: $showingAlert) {
                Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("Ok")))
            }
        }
        ```

        ```swift
        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data else {
                self.alertTitle = "Error"
                self.alertMessage = "No data in response\n \(error?.localizedDescription ?? "Unknown error")"
                self.showingAlert = true
                return
            }
            
            if let decodedOrder = try? JSONDecoder().decode(Order.self, from: data) {
                self.alertTitle = "Thank you"
                self.alertMessage = "Your order for \(decodedOrder.quantity) x \(Order.types[decodedOrder.type].lowercased()) cupcakes is on its way"
                self.showingAlert = true
            } else {
                print("Invalid response on server")
            }
        }.resume()
        ```

    3. For a more challenging task, see if you can convert our data model from a class to a struct, then create an **`ObservableObject`** class wrapper around it that gets passed around. This will result in your class having one **`@Published`** property, which is the data struct inside it, and should make supporting **`Codable`** on the struct much easier.

        ```swift
        class OrderWrapper: ObservableObject, Codable {
            enum CodingKeys: CodingKey {
                case order
            }

            @Published var order = Order()
            
            init() { }
                
            required init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                
                order = try container.decode(Order.self, forKey: .order)
            }
            
            func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
                
                try container.encode(order, forKey: .order)
            }
        }

        struct Order: Codable {
            static let types = ["Vanilla", "Strawberry", "Chocolate", "Rainbow"]

            var type = 0
            var quantity = 3

            var specialRequestEnabled = false {
                didSet {
                    if specialRequestEnabled == false {
                        extraFrosting = false
                        addSprinkles = false
                    }
                }
            }

            var extraFrosting = false
            var addSprinkles = false

            var name = ""
            var streetAddress = ""
            var city = ""
            var zip = ""

            var hasValidAddress: Bool {
                if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                    streetAddress.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                    city.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                    zip.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    return false
                }

                return true
            }

            var cost: Double {
                var cost = Double(quantity) * 2
                cost += Double(type) / 2

                if extraFrosting {
                    cost += Double(quantity)
                }

                if addSprinkles {
                    cost += Double(quantity) / 2
                }

                return cost
            }
        }
        ```

        ```swift
        struct ContentView: View {
            @ObservedObject var orderWrapper = OrderWrapper()
        		
        		...
        }
        ```