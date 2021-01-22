//
//  ContentView.swift
//  Accessibility
//
//  Created by Manuel Teixeira on 22/01/2021.
//

import SwiftUI

struct ContentView: View {
    let pictures = [
        "jf-martin-CEdOBTu62Hk-unsplash",
        "jisun-han-1zR1oFosotw-unsplash",
        "thijs-kennis-hlq_0U41MkI-unsplash"
    ]
    
    let labels = [
        "Windows on brick building",
        "Graffiti",
        "Snow landscape"
    ]
    
    @State private var selectedPicture = Int.random(in: 0...2)
    @State private var estimate = 25.0
    @State private var rating = 3
    
    var body: some View {
        Image(pictures[selectedPicture])
            .resizable()
            .scaledToFit()
            .accessibility(label: Text(labels[selectedPicture]))
            .accessibility(addTraits: .isButton)
            .accessibilityRemoveTraits(.isImage)
            .onTapGesture {
                self.selectedPicture = Int.random(in: 0...2)
            }
            
        VStack {
            Text("Your score is")
            Text("1000")
                .font(.title)
        }
        .accessibilityElement(children: .ignore)
        .accessibility(label: Text("Your score is 1000"))
        
        Slider(value: $estimate, in: 0...50)
            .padding()
            .accessibility(value: Text("\(Int(estimate))"))
        
        Stepper("Rate our service: \(rating)/5", value: $rating, in: 1...5)
            .accessibility(value: Text("\(rating) out of 5"))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
