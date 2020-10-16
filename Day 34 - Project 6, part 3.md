# Day 34 - Project 6, part 3

- Challenge

    Go back to the Guess the Flag project and add some animation:

    1. When you tap the correct flag, make it spin around 360 degrees on the Y axis.

        ```swift
        @State private var animationAmount = [0.0, 0.0, 0.0]
        ```

        ```swift
        ForEach(0 ..< 3) { number in
            Button(action: {
                let isCorrect = self.flagTapped(number)
                
                if isCorrect {
                    withAnimation {
                        self.animationAmount[number] += 360
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
        }
        ```

        ```swift
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
        ```

    2. Make the other two buttons fade out to 25% opacity.

        ```swift
        @State private var opacityAmount = [1.0, 1.0, 1.0]
        ```

        ```swift
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
        }
        ```

        ```swift
        func askQuestion() {
            countries.shuffle()
            correctAnswer = Int.random(in: 0 ... 2)
            resetAnimations()
        }

        func resetAnimations() {
            opacityAmount = [1.0, 1.0, 1.0]
        }
        ```

    3. And if you tap on the wrong flag? Well, that’s down to you – get creative!

        ```swift
        @State private var degreesAnimation = [0.0, 0.0, 0.0]
        @State private var offsetAnimation = [0.0, 0.0, 0.0]
        ```

        ```swift
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
        ```

        ```swift
        func resetAnimations() {
            opacityAmount = [1.0, 1.0, 1.0]
            offsetAnimation = [0.0, 0.0, 0.0]
            degreesAnimation = [0.0, 0.0, 0.0]
        }
        ```