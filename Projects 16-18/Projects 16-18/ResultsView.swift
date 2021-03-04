//
//  ResultsView.swift
//  Projects 16-18
//
//  Created by Manuel Teixeira on 04/03/2021.
//

import SwiftUI

struct ResultsView: View {
    @FetchRequest(
        entity: Results.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Results.dateAdded, ascending: false)
        ]
    ) var results : FetchedResults<Results>
    
    var body: some View {
        NavigationView {
            List(results, id: \.self) {
                Text("\($0.value)")
            }
            .navigationBarTitle("Previous results")
        }
    }
}

struct ResultsView_Previews: PreviewProvider {
    static var previews: some View {
        ResultsView()
    }
}
