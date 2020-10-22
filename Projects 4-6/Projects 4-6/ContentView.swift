//
//  ContentView.swift
//  Projects 4-6
//
//  Created by Manuel Teixeira on 22/10/2020.
//  Copyright © 2020 Manuel Teixeira. All rights reserved.
//

import SwiftUI

//struct SettingsView: View {
//    var body: some View {
//        Form {
//            Section(header: Text("Choose the multiplication table")) {
//                HStack {
//                    Stepper("Choose the multiplication table", value: $multiplicationTable, in: 1 ... 12)
//                        .labelsHidden()
//
//                    Spacer()
//
//                    Text("Multiplication table: \(multiplicationTable)")
//                }
//            }
//
//            Section(header: Text("How many questions you want?")) {
//                Picker("How many questions you want?", selection: $questionsNumber) {
//                    Text("5")
//                    Text("10")
//                    Text("20")
//                    Text("All")
//                }
//                .labelsHidden()
//                .pickerStyle(WheelPickerStyle())
//            }
//
//            Button(action: {
//                self.generateRandomQuestions()
//            }) {
//                Text("Start game")
//            }
//        }
//    }
//}

//struct GameView: View {
//    var body: some View {
//        VStack {
//            Text("What is \(currentQuestion)?")
//                .font(.largeTitle)
//
//            TextField("Write here your anwser", text: $answer, onCommit: checkAnswer)
//                .font(.largeTitle)
//                .padding()
//
//            Text("Your score is \(score)")
//        }
//    }
//}

struct ContentView: View {
    @State private var multiplicationTable = 1
    @State private var questionsNumber = "5"

    @State private var answer = ""
    @State private var randomQuestions = [String]()
    @State private var score = 0
    @State private var isEndGame = false
    @State private var currentQuestion = ""

    var body: some View {
        Group {
            Form {
                Section(header: Text("Choose the multiplication table")) {
                    HStack {
                        Stepper("Choose the multiplication table", value: $multiplicationTable, in: 1 ... 12)
                            .labelsHidden()

                        Spacer()

                        Text("Multiplication table: \(multiplicationTable)")
                    }
                }

                Section(header: Text("How many questions you want?")) {
                    Picker("How many questions you want?", selection: $questionsNumber) {
                        Text("5")
                        Text("10")
                        Text("20")
                        Text("All")
                    }
                    .labelsHidden()
                    .pickerStyle(WheelPickerStyle())
                }

                Button(action: {
                    self.generateRandomQuestions()
                }) {
                    Text("Start game")
                }
            }

            VStack {
                Text("What is \(currentQuestion)?")
                    .font(.largeTitle)
                
                TextField("Write here your anwser", text: $answer, onCommit: checkAnswer)
                    .font(.largeTitle)
                    .padding()
                
                Text("Your score is \(score)")
            }
        }
    }

    func generateRandomQuestions() {
        if questionsNumber == "All" {
            for i in 1 ... multiplicationTable {
                for j in 0 ... 10 {
                    randomQuestions.append(String("\(i)x\(j)"))
                }
            }
        } else {
            guard let questions = Int(questionsNumber) else { return }

            for _ in 0 ..< questions {
                let randomTable = Int.random(in: 1 ... multiplicationTable)
                let randomNumber = Int.random(in: 1 ... 10)
                randomQuestions.append(String("\(randomTable)x\(randomNumber)"))
            }
        }

        randomQuestions.shuffle()
        nextQuestion()
    }

    func checkAnswer() {
        guard let answerNumber = Int(answer) else { return }

        let questionNumbers = currentQuestion.components(separatedBy: "x")
        guard
            let firstNumber = Int(questionNumbers[0]),
            let secondNumber = Int(questionNumbers[1])
        else { return }

        if firstNumber * secondNumber == answerNumber {
            score += 1
        }

        nextQuestion()
    }

    func nextQuestion() {
        answer = ""
        
        if randomQuestions.isEmpty {
            endGame()
        } else {
            guard let question = randomQuestions.popLast() else { return }
            currentQuestion = question
        }
    }

    func endGame() {
        isEndGame = true
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
