//
//  ContentView.swift
//  Flashzilla
//
//  Created by Manuel Teixeira on 18/02/2021.
//

import SwiftUI

extension View {
    func stacked(at position: Int, in total: Int) -> some View {
        let offset = CGFloat(total - position)
        return self.offset(CGSize(width: 0, height: offset * 10))
    }
}

enum SheetType {
    case edit, settings
}

struct ContentView: View {
    @Environment(\.accessibilityDifferentiateWithoutColor) var differentianteWithoutColor
    @Environment(\.accessibilityEnabled) var accessibilityEnabled
    @StateObject var settings = UserSettings()

    @State private var cards = [Card]()

    @State private var isActive = true

    @State private var timeRemaining = 100
    @State private var showingSheet = false
    @State private var sheetType = SheetType.edit
    @State private var showingEndTimerMessage = false

    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            Image(decorative: "background")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
            VStack {
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
                ZStack {
                    ForEach(0 ..< cards.count, id: \.self) { index in
                        CardView(card: cards[index]) { response in
                            withAnimation {
                                if settings.isGoBackToStack {
                                    switch response {
                                    case .correct:
                                        removeCard(at: index)
                                    case .wrong:
                                        returnToStack(from: index)
                                    }
                                } else {
                                    removeCard(at: index)
                                }
                            }
                        }
                        .stacked(at: index, in: cards.count)
                        .allowsHitTesting(index == cards.count - 1)
                        .accessibility(hidden: index < cards.count - 1)
                    }
                }
                .allowsHitTesting(timeRemaining > 0)

                if cards.isEmpty {
                    Button("Start again", action: resetCards)
                        .padding()
                        .background(Color.white)
                        .foregroundColor(.black)
                        .clipShape(Capsule())
                }
            }

            VStack {
                HStack {
                    Spacer()

                    Button(action: {
                        showingSheet = true
                        sheetType = .edit
                    }) {
                        Image(systemName: "plus.circle")
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .clipShape(Circle())
                    }

                    Button(action: {
                        showingSheet = true
                        sheetType = .settings
                    }) {
                        Image(systemName: "gearshape")
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

            if differentianteWithoutColor || accessibilityEnabled {
                VStack {
                    Spacer()

                    HStack {
                        Button(action: {
                            withAnimation {
                                removeCard(at: cards.count - 1)
                            }
                        }) {
                            Image(systemName: "xmark.circle")
                                .padding()
                                .background(Color.black.opacity(0.7))
                                .clipShape(Circle())
                        }
                        .accessibility(label: Text("Wrong"))
                        .accessibility(hint: Text("Mark your answer as being incorrect"))

                        Spacer()

                        Button(action: {
                            withAnimation {
                                removeCard(at: cards.count - 1)
                            }
                        }) {
                            Image(systemName: "checkmark.circle")
                                .padding()
                                .background(Color.black.opacity(0.7))
                                .clipShape(Circle())
                        }
                        .accessibility(label: Text("Correct"))
                        .accessibility(hint: Text("Mark your answer as being correct"))
                    }
                    .foregroundColor(.white)
                    .font(.largeTitle)
                    .padding()
                }
            }
        }
        .onReceive(timer) { _ in
            guard isActive else { return }

            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                showingEndTimerMessage = true
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            isActive = false
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            if cards.isEmpty == false {
                isActive = true
            }
        }
        .sheet(isPresented: $showingSheet, onDismiss: {
            if sheetType == .edit {
                resetCards()
            }
        }, content: {
            switch sheetType {
            case .edit:
                EditCards()
            case .settings:
                SettingsView()
                    .environmentObject(settings)
            }
        })
        .onAppear(perform: resetCards)
    }

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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            cards.insert(card, at: 0)
        }
    }

    func resetCards() {
        cards = [Card]()
        timeRemaining = 100
        showingEndTimerMessage = false
        isActive = true
        loadData()
    }

    func loadData() {
        if let data = UserDefaults.standard.data(forKey: "Cards") {
            if let decoded = try? JSONDecoder().decode([Card].self, from: data) {
                cards = decoded
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
