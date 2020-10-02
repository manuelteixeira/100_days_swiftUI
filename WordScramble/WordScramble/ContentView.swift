//
//  ContentView.swift
//  WordScramble
//
//  Created by Manuel Teixeira on 02/10/2020.
//  Copyright © 2020 Manuel Teixeira. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        let input = """
                    a
                    b
                    c
                    """
        let letters = input.components(separatedBy: "\n")
        
        List(0..<5, id: \.self) {
            Text("Dynamic row \($0)")
        }
        .listStyle(GroupedListStyle())
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
