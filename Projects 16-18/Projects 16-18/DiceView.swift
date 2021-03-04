//
//  DiceView.swift
//  Projects 16-18
//
//  Created by Manuel Teixeira on 04/03/2021.
//

import SwiftUI

struct DiceView: View {
    var sideNumber: Int
    @State private var randomNumber = 1
    @Environment(\.managedObjectContext) var managedObjectContext

    var body: some View {
        ScrollViewReader { scrollView in
            VStack(spacing: 16) {
                ScrollView(.horizontal) {
                    HStack(spacing: 10) {
                        ForEach(0 ..< sideNumber, id: \.self) { index in

                            Text("\(index + 1)")
                                .font(randomNumber == index ? .largeTitle : .headline)
                                .padding(.horizontal, 20)
                                .id(index)
                                .border(randomNumber == index ? Color.blue : Color.clear, width: 2)
                                .cornerRadius(4)
                        }
                    }
                }
                .padding(.vertical, 4)
                .padding(.horizontal, 16)

                Button(action: {
                    rollDice()
                    withAnimation {
                        scrollView.scrollTo(randomNumber, anchor: .center)
                    }
                }, label: {
                    Text("🎲")
                        .font(.system(size: 70))
                })
            }
        }
    }

    func rollDice() {
        randomNumber = generateRandomNumber()
    }

    func generateRandomNumber() -> Int {
        let random = Int.random(in: 1 ... sideNumber)
        save(random)
        // we need the index
        return random - 1
    }
    
    func save(_ value: Int) {
        let result = Results(context: managedObjectContext)
        result.value = Int16(value)
        result.dateAdded = Date()
        
        do {
            try managedObjectContext.save()
        } catch {
            print(error.localizedDescription)
        }
    }
}

struct DiceView_Previews: PreviewProvider {
    static var previews: some View {
        DiceView(sideNumber: 10)
    }
}
