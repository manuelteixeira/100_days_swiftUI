//
//  ContentView.swift
//  GuessTheFlag
//
//  Created by Manuel Teixeira on 21/09/2020.
//  Copyright © 2020 Manuel Teixeira. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var showingAlert = false
    
    var body: some View {
        Button("Show Alert") {
            self.showingAlert = true
        }
        .alert(isPresented: $showingAlert) {
            Alert(title: Text("Hello"), message: Text("This is some detail message"), dismissButton: .default(Text("Ok")))
        }
   }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
