//
//  ContentView.swift
//  ViewAndModifiers
//
//  Created by Manuel Teixeira on 24/09/2020.
//  Copyright © 2020 Manuel Teixeira. All rights reserved.
//

import SwiftUI

struct BigTitle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.largeTitle)
            .foregroundColor(.blue)
    }
}

extension View {
    func bigTitle() -> some View {
        return self.modifier(BigTitle())
    }
}

struct ContentView: View {
    var body: some View {
        Text("Hello world")
            .bigTitle()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
