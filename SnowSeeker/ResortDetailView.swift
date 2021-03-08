//
//  ResortDetailView.swift
//  SnowSeeker
//
//  Created by Manuel Teixeira on 08/03/2021.
//

import SwiftUI

struct ResortDetailView: View {
    let resort: Resort
    
    var size: String {
        switch resort.size {
        case 1:
            return "Small"
        case 2:
            return "Average"
        default:
            return "Large"
        }
    }
    
    var price: String {
        String(repeating: "$", count: resort.price)
    }
    
    var body: some View {
        VStack {
            Text("Size: \(size)")
            Text("Price: \(price)")
        }
    }
}

struct ResortDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ResortDetailView(resort: Resort.example)
    }
}
