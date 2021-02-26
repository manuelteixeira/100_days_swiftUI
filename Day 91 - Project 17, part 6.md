# Day 91 - Project 17, part 6

- Challenge

    1. Make something interesting for when the timer runs out. At the very least make some text appear, but you should also try designing a custom haptic using Core Haptics.

        ```swift
        if showingEndTimerMessage {
            Text("Time has ended")
                .font(.largeTitle)
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 5)
                .background(
                    Capsule()
                        .fill(Color.black)
                        .opacity(0.75)
                )
        } else {
            Text("Time: \(timeRemaining)")
                .font(.largeTitle)
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 5)
                .background(
                    Capsule()
                        .fill(Color.black)
                        .opacity(0.75)
                )
        }
        ```

    2. Add a settings screen that has a single option: when you get an answer one wrong that card goes back into the array so the user can try it again.

        ```swift
        class UserSettings: ObservableObject {
            @Published var isGoBackToStack = false
        }

        struct SettingsView: View {
            @Environment(\.presentationMode) var presentationMode
            @EnvironmentObject var settings: UserSettings

            var body: some View {
                NavigationView {
                    List {
                        Section(header: Text("cards options")) {
                            Toggle("Go back to stack if wrong", isOn: $settings.isGoBackToStack)
                        }
                    }
                    .listStyle(GroupedListStyle())
                    .navigationBarTitle("Settings")
                    .navigationBarItems(trailing: Button("Done", action: dismiss))
                }
            }
            
            func dismiss() {
                presentationMode.wrappedValue.dismiss()
            }
        }

        struct SettingsView_Previews: PreviewProvider {
            static var previews: some View {
                SettingsView()
            }
        }
        ```

        ```swift
        .gesture(
            DragGesture()
                .onChanged { gesture in
                    offset = gesture.translation
                    feedback.prepare()
                }
                .onEnded { _ in
                    if abs(offset.width) > 100 {
                        if offset.width > 0 {
                            feedback.notificationOccurred(.success)
                            removal?(.correct)
                        } else {
                            feedback.notificationOccurred(.error)
                            removal?(.wrong)
                        }
                        

                    } else {
                        offset = .zero
                    }
                }
        )
        ```

        ```swift
        func removeCard(at index: Int) {
            guard index >= 0 else { return }

            cards.remove(at: index)

            if cards.isEmpty {
                isActive = false
            }
        }

        func returnToStack(from index: Int) {
            let card = cards[index]
            removeCard(at: index)
        		// For some reason I couldn't understand we can't add a card immediatly
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                cards.insert(card, at: 0)
            }
        }
        ```

    3. If you drag a card to the right but not far enough to remove it, then release, you see it turn red as it slides back to the center. Why does this happen and how can you fix it? (Tip: use a custom modifier for this to avoid cluttering your body property.)

        ```swift
        func setColor(for offset: CGSize) -> Color {
            if offset.width > 0 {
                return .green
            }
            
            if offset.width < 0 {
                return .red
            }
            
            return .white
        }
        ```

        ```swift
        .background(
            differentiateWithoutColor
                ? nil
                : RoundedRectangle(cornerRadius: 25, style: .continuous)
                .fill(setColor(for: offset))
        )
        ```