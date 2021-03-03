# Day 94 - Project 18, part three

- Challenge
    1. Change project 8 (Moonshot) so that when you scroll down in **`MissionView`** the mission badge image gets smaller. It doesn’t need to shrink away to nothing – going down to maybe 80% is fine.

        ```swift
        GeometryReader { geo in
            VStack {
                Image(self.mission.image)
                    .resizable()
                    .scaledToFit()
                    .padding(.top)
                    .frame(maxWidth: geo.frame(in: .global).maxY)
                
                Text(self.mission.formattedLaunchDate)
                    .font(.caption)
            }
            .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
        }
        ```

    2. Change project 5 (Word Scramble) so that words towards the bottom of the list slide in from the right as you scroll. Ideally at least the top 8-10 words should all be positioned normally, but after that they should be offset increasingly to the right.

        ```swift
        GeometryReader { fullView in
            List(usedWords, id: \.self) { word in
                GeometryReader { geo in
                    Text("\(geo.frame(in: .global).maxY)")
                    HStack {
                        Image(systemName: "\(word.count).circle")
                        Text(word)
                    }
                    .offset(x: max(0, (geo.frame(in: .global).maxY - 850)))
                    .accessibilityElement(children: .ignore)
                    .accessibility(label: Text("\(word), \(word.count) letters"))
                    .frame(width: geo.size.width, height: geo.size.height, alignment: .center)
                }
            }
        }
        ```

    3. For a real challenge make the letter count images in project 5 change color as you scroll. For the best effect, you should create colors using the **`Color(red:green:blue:)`** initializer, feeding in values for whichever of red, green, and blue you want to modify. The values to input can be figured out using the row’s current position divided by maximum position, which should give you values in the range 0 to 1.

        ```swift
        fileprivate func getForegroundColor(for index: Int, scrollValue: CGFloat) -> Color {
            let colorHue = Double(index) / Double(usedWords.count) + Double(scrollValue / 1000)
            
            let color = Color(hue: colorHue, saturation: 0.7, brightness: 0.7)

            return color
        }
        ```

        ```php
        HStack {
            Image(systemName: "\(usedWords[index].count).circle")
                .foregroundColor(getForegroundColor(for: index, scrollValue: geo.frame(in: .global).minY))
            Text(usedWords[index])
        }
        ```