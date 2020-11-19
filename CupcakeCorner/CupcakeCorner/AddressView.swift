//
//  AddressView.swift
//  CupcakeCorner
//
//  Created by Manuel Teixeira on 17/11/2020.
//

import SwiftUI

struct AddressView: View {
    @ObservedObject var orderWrapper: OrderWrapper

    var body: some View {
        Form {
            Section {
                TextField("Name", text: $orderWrapper.order.name)
                TextField("Street address", text: $orderWrapper.order.streetAddress)
                TextField("City", text: $orderWrapper.order.city)
                TextField("Zip", text: $orderWrapper.order.zip)
            }

            Section {
                NavigationLink(destination: CheckoutView(orderWrapper: orderWrapper)) {
                    Text("Check out")
                }
            }.disabled(!orderWrapper.order.hasValidAddress)
        }
    }
}

struct AddressView_Previews: PreviewProvider {
    static var previews: some View {
        AddressView(orderWrapper: OrderWrapper())
    }
}
