# Day 31 - Project 5, part 3

- Challenge

    1. Disallow answers that are shorter than three letters or are just our start word. For the three-letter check, the easiest thing to do is put a check into **`isReal()`** that returns false if the word length is under three letters. For the second part, just compare the start word against their input word and return false if they are the same.

        ```swift
        func isReal(word: String) -> Bool {
        	  guard word.count > 3 else { return false }
        	  
        	  let checker = UITextChecker()
        	  let range = NSRange(location: 0, length: word.utf16.count)
        	  
        	  let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
        	  
        	  return misspelledRange.location == NSNotFound
        }
        ```

        ```swift
        func isDifferent(word: String) -> Bool {
            return word != rootWord
        }
        ```

    2. Add a left bar button item that calls **`startGame()`**, so users can restart with a new word whenever they want to.

        ```swift
        .navigationBarItems(trailing:
            Button(action: startGame) {
                Text("New word")
            }
        )
        ```

    3. Put a text view below the **`List`** so you can track and show the player’s score for a given root word. How you calculate score is down to you, but something involving number of words and their letter count would be reasonable.

        ```swift
        Text("Your score is \(score)")
          .font(.headline)
        ```

        ```swift
        func updateScore(word: String) {
            score += 1 + word.count
        }
        ```