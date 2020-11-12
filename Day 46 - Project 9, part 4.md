# Day 46 - Project 9, part 4

- Challenge

    1. Create an **`Arrow`** shape made from a rectangle and a triangle – having it point straight up is fine.

        ```swift
        struct Arrow: Shape {
            func path(in rect: CGRect) -> Path {
                var path = Path()

                path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
                path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
                path.addLine(to: CGPoint(x: rect.maxX + 50, y: rect.midY))
                path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
                path.addLine(to: CGPoint(x: rect.minX - 50, y: rect.midY))
                path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
                path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))

                return path
            }
        }

        struct ContentView: View {
            var body: some View {
                Arrow()
                    .stroke(lineWidth: 1)
                    .frame(width: 200, height: 500)
            }
        }
        ```

    2. Make the line thickness of your **`Arrow`** shape animatable.

        ```swift
        struct ContentView: View {
            @State private var lineWidth: CGFloat = 1
            var body: some View {
                VStack {
                    Arrow()
                        .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                        .frame(width: 200, height: 500)
                        .padding(.top)
                    
                    Spacer()

                    Button("Tap me") {
                        withAnimation {
                            lineWidth += 10
                        }
                    }
                    .padding()
                }
            }
        }
        ```

    3. Create a **`ColorCyclingRectangle`** shape that is the rectangular cousin of **`ColorCyclingCircle`**, allowing us to control the position of the gradient using a property.

        ```swift
        struct ColorCyclingRectangle: View {
            var amount = 0.0
            var steps = 100
            var startPoint: UnitPoint = .top
            var endPoint: UnitPoint = .bottom

            var body: some View {
                ZStack {
                    ForEach(0 ..< steps) { value in
                        Rectangle()
                            .inset(by: CGFloat(value))
                            .strokeBorder(LinearGradient(gradient: Gradient(colors: [
                                self.color(for: value, brightness: 1),
                                self.color(for: value, brightness: 0.5)
                            ]), startPoint: startPoint, endPoint: endPoint), lineWidth: 2)
                    }
                }
                .drawingGroup()
            }

            func color(for value: Int, brightness: Double) -> Color {
                var targetHue = Double(value) / Double(steps) + amount

                if targetHue > 1 {
                    targetHue -= 1
                }

                return Color(hue: targetHue, saturation: 1, brightness: brightness)
            }
        }

        struct ContentView: View {
            @State private var colorCycle = 0.0
            
            var body: some View {
                VStack {
                    ColorCyclingRectangle(amount: self.colorCycle, startPoint: .center, endPoint: .leading)
                        .frame(width: 200, height: 300)
                    
                    Slider(value: $colorCycle)
                }
            }
        }
        ```