//
//  ContentView.swift
//  GuessTheFlag
//
//  Created by Manuel Teixeira on 21/09/2020.
//  Copyright © 2020 Manuel Teixeira. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var countries = ["Estonia", "France", "Germany", "Ireland", "Italy", "Nigeria", "Poland", "Russia", "Spain", "UK", "US"].shuffled()

    @State private var correctAnswer = Int.random(in: 0 ... 2)

    @State private var showingScore = false
    @State private var scoreTitle = ""
    @State private var score = 0
    @State private var alertMessage = ""

    @State private var animationAmount = [0.0, 0.0, 0.0]
    @State private var opacityAmount = [1.0, 1.0, 1.0]
    @State private var degreesAnimation = [0.0, 0.0, 0.0]
    @State private var offsetAnimation = [0.0, 0.0, 0.0]

    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [.blue, .black]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 30) {
                VStack {
                    Text("Tap the flag of")
                        .foregroundColor(.white)
                    Text(countries[correctAnswer])
                        .foregroundColor(.white)
                        .font(.largeTitle)
                        .fontWeight(.black)
                }

                ForEach(0 ..< 3) { number in
                    Button(action: {
                        let isCorrect = self.flagTapped(number)

                        if isCorrect {
                            withAnimation {
                                self.animationAmount[number] += 360

                                for (index, _) in self.opacityAmount.enumerated() {
                                    if index != number {
                                        self.opacityAmount[index] = 0.25
                                    }
                                }
                            }
                        } else {
                            withAnimation {
                                self.degreesAnimation[number] = 90.0
                                self.offsetAnimation[number] = 1000
                            }
                        }
                    }) {
                        Image(self.countries[number])
                            .renderingMode(.original)
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(Color.black, lineWidth: 1))
                            .shadow(color: Color.black, radius: 2)
                    }
                    .rotation3DEffect(.degrees(self.animationAmount[number]), axis: (x: 0, y: 1, z: 0))
                    .opacity(self.opacityAmount[number])
                    .animation(.default)
                    .rotationEffect(.degrees(-self.degreesAnimation[number]), anchor: .topTrailing)
                    .animation(
                        Animation.interpolatingSpring(stiffness: 50, damping: 10)
                    )
                    .offset(CGSize(
                        width: 0,
                        height: self.offsetAnimation[number])
                    )
                }

                Text("Your current score is \(score)")
                    .foregroundColor(.white)
                    .fontWeight(.semibold)

                Spacer()
            }
        }

        .alert(isPresented: $showingScore) {
            Alert(title: Text(scoreTitle), message: Text(alertMessage), dismissButton: .default(Text("Continue"), action: {
                self.askQuestion()
            }))
        }
    }

    func flagTapped(_ number: Int) -> Bool {
        if number == correctAnswer {
            scoreTitle = "Correct"
            score += 1
            alertMessage = "Your score is \(score)."
            showingScore = true
            return true
        } else {
            scoreTitle = "Wrong"
            score -= 1
            alertMessage = "That's the flag of \(countries[number]).\nYour score is \(score)."
            showingScore = true
            return false
        }
    }

    func askQuestion() {
        countries.shuffle()
        correctAnswer = Int.random(in: 0 ... 2)
        resetAnimations()
    }

    func resetAnimations() {
        opacityAmount = [1.0, 1.0, 1.0]
        offsetAnimation = [0.0, 0.0, 0.0]
        degreesAnimation = [0.0, 0.0, 0.0]
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
