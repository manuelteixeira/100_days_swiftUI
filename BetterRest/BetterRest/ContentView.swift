//
//  ContentView.swift
//  BetterRest
//
//  Created by Manuel Teixeira on 29/09/2020.
//  Copyright © 2020 Manuel Teixeira. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @State private var wakeUp = Date()
    var body: some View {
        DatePicker("Please select a date", selection: $wakeUp, in: Date()...)
        .labelsHidden()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
