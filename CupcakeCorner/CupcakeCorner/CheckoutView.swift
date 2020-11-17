//
//  CheckoutView.swift
//  CupcakeCorner
//
//  Created by Manuel Teixeira on 17/11/2020.
//

import SwiftUI

struct CheckoutView: View {
    @ObservedObject var order: Order

    var body: some View {
        GeometryReader { geo in
            ScrollView {
                VStack {
                    Image("cupcakes")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.size.width)
                    
                    Text("Your total is $\(self.order.cost, specifier: "%2.f")")
                        .font(.title)
                    
                    Button("Place order") {
                        
                    }
                    .padding()
                }
            }
        }
    }
}

struct CheckoutView_Previews: PreviewProvider {
    static var previews: some View {
        CheckoutView(order: Order())
    }
}
