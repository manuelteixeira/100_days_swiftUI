//
//  ContentView.swift
//  Day 19 - Challenge Day
//
//  Created by Manuel Teixeira on 18/09/2020.
//  Copyright © 2020 Manuel Teixeira. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var inputValue = ""
    @State private var inputUnitSelection = 0
    @State private var outputUnitSelection = 0
    
    private let units = ["meters", "kilometers", "feet", "yards", "miles"]
    
    private enum UnitsEnum: String {
        case meters, kilometers, feet, yards, miles
    }
    
    private enum UnitsValues {
        static let meter: Double = 1
        static let kilometer: Double = 1000
        static let feet = 3.2808
        static let yard = 1.0936
        static let mile = 0.00062137
    }

    
    private var finalValue: Double {
        let initialValue = Double(inputValue) ?? 0
        
        let inputUnit = units[inputUnitSelection]
        let outputUnit = units[outputUnitSelection]
        
        guard
            let initialValueUnit = UnitsEnum(rawValue: inputUnit),
            let finalValueUnit = UnitsEnum(rawValue: outputUnit)
        else { return 0 }
        
        let metersValue = convertValueToMeters(value: initialValue, unit: initialValueUnit)
        
        let final = convertMetersTo(unit: finalValueUnit, value: metersValue)
        
        return final
    }
    
    private func convertValueToMeters(value: Double, unit: UnitsEnum) -> Double {
        switch unit {
        case .meters:
            return value
        case .kilometers:
            return value * UnitsValues.kilometer
        case .feet:
            return value / UnitsValues.feet
        case .yards:
            return value / UnitsValues.yard
        case .miles:
            return value / UnitsValues.mile
        default:
            return value
        }
    }

    private func convertMetersTo(unit: UnitsEnum, value: Double) -> Double {
        switch unit {
        case .meters:
            return value
        case .kilometers:
            return value / UnitsValues.kilometer
        case .feet:
            return value * UnitsValues.feet
        case .yards:
            return value * UnitsValues.yard
        case .miles:
            return value * UnitsValues.mile
        default:
            return value
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Input unit")) {
                    Picker("Unit selection", selection: $inputUnitSelection) {
                        ForEach(0 ..< units.count) {
                            Text(self.units[$0])
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section(header: Text("Input value")) {
                    

                    TextField("Value to convert", text: $inputValue)
                }
                
                Section(header: Text("Output unit")) {
                    Picker("Unit selection", selection: $outputUnitSelection) {
                        ForEach(0 ..< units.count) {
                            Text(self.units[$0])
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section(header: Text("Output value")) {
                    Text("\(finalValue, specifier: "%.4f")")
                }
            }
            .navigationBarTitle("Conversion App")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
