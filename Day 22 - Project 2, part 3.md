# Day 22 - Project 2, part 3

- **Challenge**

    1. Add an **`@State`** property to store the user’s score, modify it when they get an answer right or wrong, then display it in the alert.

        ```swift
        func flagTapped(_ number: Int) {
            if number == correctAnswer {
                scoreTitle = "Correct"
                score += 1
            } else {
                scoreTitle = "Wrong"
                score -= 1
            }
            
            showingScore = true
        }
        ```

        ```swift
        .alert(isPresented: $showingScore) {
            Alert(title: Text(scoreTitle), message: Text("Your question is ???. Your score is \(score)"), dismissButton: .default(Text("Continue"), action: {
                self.askQuestion()
            }))
        }
        ```

    2. Show the player’s current score in a label directly below the flags.

        ```swift
        Text("Your current score is \(score)")
          .foregroundColor(.white)
          .fontWeight(.semibold)
        ```

    3. When someone chooses the wrong flag, tell them their mistake in your alert message – something like “Wrong! That’s the flag of France,” for example.

        ```swift
        func flagTapped(_ number: Int) {
            if number == correctAnswer {
                scoreTitle = "Correct"
                score += 1
                alertMessage = "Your score is \(score)."
            } else {
                scoreTitle = "Wrong"
                score -= 1
                alertMessage = "That's the flag of \(countries[number]).\nYour score is \(score)."
            }
            
            showingScore = true
        }
        ```

        ```swift
        .alert(isPresented: $showingScore) {
            Alert(title: Text(scoreTitle), message: Text(alertMessage), dismissButton: .default(Text("Continue"), action: {
                self.askQuestion()
            }))
        }
        ```