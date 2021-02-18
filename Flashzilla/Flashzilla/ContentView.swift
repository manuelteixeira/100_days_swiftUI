//
//  ContentView.swift
//  Flashzilla
//
//  Created by Manuel Teixeira on 18/02/2021.
//

import CoreHaptics
import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Text("Hello")
            
            Spacer()
                .frame(height: 100)
            
            Text("World")
        }
        .contentShape(Rectangle())
        .onTapGesture {
            print("Tapped")
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
