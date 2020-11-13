//
//  ContentView.swift
//  Projects 7-9
//
//  Created by Manuel Teixeira on 13/11/2020.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        
        let activityList = UserDefaults.loadData()
        ActivityListView(activityList: activityList)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
