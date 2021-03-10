//
//  ContentView.swift
//  SnowSeeker
//
//  Created by Manuel Teixeira on 05/03/2021.
//

import SwiftUI

enum SortFilters {
    case `default`, name, country
}

enum Filter {
    case country, size, price
}

struct ContentView: View {
    @ObservedObject var favorites = Favorites()
    @State private var sortBy: SortFilters = .default
    @State private var showFilters = false
    @State private var showSortFilters = false

    @State private var countryFilter = ""
    @State private var sizeFilter = "Small"
    @State private var priceFilter = "$$"

    @State var resorts: [Resort] = Bundle.main.decode("resorts.json")

    var sortedResorts: [Resort] {
        resorts.sorted {
            switch sortBy {
            case .name:
                return $0.name < $1.name
            case .country:
                return $0.country < $1.country
            case .default:
                return true
            }
        }
    }

    var filteredResorts: [Resort] {
        if countryFilter.isEmpty {
            return sortedResorts
        } else {
            return sortedResorts.filter({
                $0.country == countryFilter &&
                    $0.size == getSize(from: sizeFilter) &&
                    $0.price == getPrice(from: priceFilter)
            })
        }
    }

    func getSize(from sizeFilter: String) -> Int {
        switch sizeFilter {
        case "Small":
            return 1
        case "Average":
            return 2
        default:
            return 3
        }
    }

    func getPrice(from priceFilter: String) -> Int {
        priceFilter.count
    }

    var body: some View {
        NavigationView {
            List(filteredResorts) { resort in
                NavigationLink(
                    destination: ResortView(resort: resort)) {
                    Image(resort.country)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 40, height: 25)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.black, lineWidth: 1)
                        )

                    VStack(alignment: .leading) {
                        Text(resort.name)
                            .font(.headline)

                        Text("\(resort.runs) runs")
                            .foregroundColor(.secondary)
                    }
                    .layoutPriority(1)

                    if favorites.contains(resort) {
                        Spacer()
                        Image(systemName: "heart.fill")
                            .accessibility(label: Text("This is a favorite resort"))
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationBarTitle("Resorts")
            .navigationBarItems(trailing:
                HStack(spacing: 16) {
                    Button(action: {
                        showFilters = true
                    }, label: {
                        Image(systemName: "line.horizontal.3.decrease.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                    })
                        .sheet(isPresented: $showFilters) {
                            FilterView(
                                resorts: $resorts,
                                countryFilter: $countryFilter,
                                sizeFilter: $sizeFilter,
                                priceFilter: $priceFilter
                            )
                        }

                    Button(action: {
                        showSortFilters = true
                    }, label: {
                        Image(systemName: "arrow.up.arrow.down.circle.fill")
                            .resizable()
                            .frame(width: 30, height: 30)
                    })
                        .actionSheet(isPresented: $showSortFilters) {
                            ActionSheet(title: Text("Choose a filter"), buttons: [
                                .default(Text("default")) { sortBy = .default },
                                .default(Text("name")) { sortBy = .name },
                                .default(Text("country")) { sortBy = .country },
                                .cancel()
                            ])
                        }
                }
            )

            WelcomeView()
        }
        .environmentObject(favorites)
    }
}

extension ContentView {
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
