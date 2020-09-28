//
//  ContentView.swift
//  Projects 1-3
//
//  Created by Manuel Teixeira on 28/09/2020.
//  Copyright © 2020 Manuel Teixeira. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    let options = ["✊", "🤚", "✌️"]
    let maxRounds = 10
    
    @State private var currentChoice = Int.random(in: 0 ..< 3)
    @State private var playerShouldWin = Bool.random()
    @State private var score = 0
    @State private var round = 0
    @State private var isGameOver = false
    
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [.orange, .red]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Text("Your current score is \(score)")
                    .padding()
                    .foregroundColor(.white)
                
                if playerShouldWin {
                    Text("You should win")
                        .foregroundColor(.white)
                        .font(.largeTitle)
                } else {
                    Text("You should lose")
                        .foregroundColor(.white)
                        .font(.largeTitle)
                }
                
                Text(options[currentChoice])
                    .font(.system(size: 60))
                    .shadow(radius: 10)
                
                Spacer()
                
                VStack {
                    ForEach(options, id: \.self) { option in
                        Button(action: {
                            self.tapMove(move: option)
                        }) {
                            Text(option)
                                .font(.system(size: 100))
                        }
                        .shadow(radius: 10)
                    }
                }
                
                .alert(isPresented: $isGameOver) {
                    Alert(title: Text("Game over"),
                          message: Text("Your score is \(score)"),
                          dismissButton: .default(Text("Ok")) {
                            
                            self.resetGame()
                    })
                }
                
            }
        }
        
    }
    
    func resetGame() {
        currentChoice = Int.random(in: 0 ..< 3)
        playerShouldWin = Bool.random()
        round = 0
        score = 0
    }
    
    func startGame() {
        currentChoice = Int.random(in: 0 ..< 3)
        playerShouldWin = Bool.random()
    }
    
    func tapMove(move: String) {
        
        switch move {
        case "✊":
            if playerShouldWin && options[currentChoice] == "✌️" {
                score += 1
            } else if !playerShouldWin && options[currentChoice] == "🤚" {
                score += 1
            } else {
                score -= 1
            }
            
            round += 1
        case "🤚":
            if playerShouldWin && options[currentChoice] == "✊" {
                score += 1
            } else if !playerShouldWin && options[currentChoice] == "✌️" {
                score += 1
            } else {
                score -= 1
            }
            
            round += 1
        case "✌️":
            if playerShouldWin && options[currentChoice] == "🤚" {
                score += 1
            } else if !playerShouldWin && options[currentChoice] == "✊" {
                score += 1
            } else {
                score -= 1
            }
            
            round += 1
        default:
            break
        }
        
        if round >= maxRounds {
            isGameOver = true
        } else {
            startGame()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
