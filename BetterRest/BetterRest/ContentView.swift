//
//  ContentView.swift
//  BetterRest
//
//  Created by Manuel Teixeira on 29/09/2020.
//  Copyright © 2020 Manuel Teixeira. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var wakeUp = defaultWakeTime
    @State private var sleepAmount = 8.0
    @State private var coffeeAmount = 1
    
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingAlert = false
    
    var body: some View {
        NavigationView {
            VStack {
                Text("You should be in bed by \(bedTime)")
                    .padding()
                    .font(.headline)
                
                Form {
                    Section(header: Text("When do you want to wake up?")) {
                        DatePicker("Please enter a time",
                                   selection: $wakeUp,
                                   displayedComponents: .hourAndMinute)
                            .labelsHidden()
                            .datePickerStyle(WheelDatePickerStyle())
                    }
                    
                    Section(header: Text("Desired amount of sleep")) {
                        Stepper(value: $sleepAmount, in: 4...12, step: 0.25) {
                            Text("\(sleepAmount, specifier: "%g") hours")
                        }
                        .accessibility(value: Text("\(sleepAmount, specifier: "%g") hours with a minimum of 4 hours and a maximum of 12 hours."))
                    }
                    
                    Section(header: Text("Daily coffee intake")) {
                        Picker("Number of cups", selection: $coffeeAmount) {
                            ForEach(1..<21) { number in
                                if number == 1 {
                                    Text("1 cup")
                                } else {
                                    Text("\(number) cups")
                                }
                            }
                        }
                        .labelsHidden()
                    }
                }
                .navigationBarTitle("BetterRest")
                .alert(isPresented: $showingAlert) { () -> Alert in
                    Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("Ok")))
                }
            }
        }
    }
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 7
        components.minute = 0
        
        return Calendar.current.date(from: components) ?? Date()
    }
    
    private var bedTime: String {
        let model = SleepCalculator()
        
        let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
        
        let hour = (components.hour ?? 0) * 60 * 60
        let minute = (components.minute ?? 0) * 60
        
        do {
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            
            let formatter = DateFormatter()
            formatter.timeStyle = .short
            
            return formatter.string(from: sleepTime)
        } catch {
            showingAlert = true
            return "Error"
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
