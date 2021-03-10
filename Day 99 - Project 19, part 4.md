# Day 99 - Project 19, part 4

- Challenge

    1. Add a photo credit over the **`ResortView`** image. The data is already loaded from the JSON for this purpose, so you just need to make it look good in the UI.

        ```swift
        ZStack(alignment: .bottomTrailing) {
            Image(decorative: resort.id)
                .resizable()
                .scaledToFit()
            
            Text("Photo by \(resort.imageCredit)")
                .font(.caption)
                .foregroundColor(.white)
                .shadow(radius: 5)
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.black.opacity(0.5))
                )
                .padding(.bottom, 8)
                .padding(.trailing, 8)
        }
        ```

    2. Fill in the loading and saving methods for **`Favorites`**.

        ```swift
        func save() {
            if let data = try? JSONEncoder().encode(resorts) {
                UserDefaults.standard.set(data, forKey: saveKey)
            }
        }

        func load() {
            if let data = UserDefaults.standard.object(forKey: saveKey) as? Data {
                do {
                    resorts = try JSONDecoder().decode(Set<String>.self, from: data)
                } catch {
                    print("Couldn't decode")
                }
            }
        }
        ```

    3. For a real challenge, let the user sort and filter the resorts in **`ContentView`**. For sorting use default, alphabetical, and country, and for filtering let them select country, size, or price.

        ```swift
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
        ```