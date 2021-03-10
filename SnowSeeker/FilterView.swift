//
//  FilterView.swift
//  SnowSeeker
//
//  Created by Manuel Teixeira on 10/03/2021.
//

import SwiftUI

struct FilterView: View {
    @Binding var resorts: [Resort]
    @Binding var countryFilter: String
    @Binding var sizeFilter: String
    @Binding var priceFilter: String

    var resortsCountries: [String] {
        let countriesArray = resorts.map { $0.country }
        return Array(Set(countriesArray))
    }
    
    var resortsSize: [String] {
        return ["Small", "Average", "Large"]
    }

//    var resortsSize: [String] {
//        let sizeArray = resorts.map { resort -> String in
//            switch resort.size {
//            case 1:
//                return "Small"
//            case 2:
//                return "Average"
//            default:
//                return "Large"
//            }
//        }
//        return Array(Set(sizeArray))
//    }

    var resortsPrice: [String] {
        let priceArray = resorts.map { String(repeating: "$", count: $0.price) }
        return Array(Set(priceArray))
    }

    var body: some View {
        VStack {
            List {
                Section(header: Text("Country")) {
                    Picker("Country", selection: $countryFilter) {
                        ForEach(resortsCountries, id: \.self) {
                            Text($0)
                        }
                    }
                }

                Section(header: Text("Size")) {
                    Picker("Size", selection: $sizeFilter) {
                        ForEach(resortsSize, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                Section(header: Text("Price")) {
                    Picker("Price", selection: $priceFilter) {
                        ForEach(resortsPrice, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
            }
        }
    }
}

struct FilterView_Previews: PreviewProvider {
    static var previews: some View {
        FilterView(
            resorts: .constant(Resort.allResorts),
            countryFilter: .constant("France"),
            sizeFilter: .constant("Small"),
            priceFilter: .constant("$$")
        )
    }
}
