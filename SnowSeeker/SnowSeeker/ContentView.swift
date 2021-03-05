//
//  ContentView.swift
//  SnowSeeker
//
//  Created by Manuel Teixeira on 05/03/2021.
//

import SwiftUI

struct UserView: View {
    var body: some View {
        Group {
            Text("Name: Paul")
            Text("Country: England")
            Text("Pets: X, Y, Z")
        }
    }
}

struct ContentView: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    
    var body: some View {
        Group {
            if sizeClass == .compact {
                VStack(content: UserView.init)
            } else {
                HStack(content: UserView.init)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
