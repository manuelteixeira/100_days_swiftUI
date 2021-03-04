//
//  ContentView.swift
//  Projects 16-18
//
//  Created by Manuel Teixeira on 04/03/2021.
//

import SwiftUI

struct ContentView: View {
    let diceSides = ["4", "6", "8", "10", "12", "20", "100"]
    @State private var sideSelection = "4"
    
    var body: some View {
        TabView {
            VStack(spacing: 16) {
                Picker("Number of sides", selection: $sideSelection) {
                    ForEach(diceSides, id: \.self) {
                        Text("\($0) sided")
                    }
                }
                .pickerStyle(MenuPickerStyle())

                DiceView(sideNumber: Int(sideSelection) ?? 10)
            }
            .tabItem {
                Image(systemName: "cube.fill")
                Text("Roll the dice")
            }

            ResultsView()
                .tabItem {
                    Image(systemName: "list.number")
                    Text("Previous results")
                }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
