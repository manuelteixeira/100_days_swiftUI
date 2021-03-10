//
//  ResortView.swift
//  SnowSeeker
//
//  Created by Manuel Teixeira on 08/03/2021.
//

import SwiftUI

struct ResortView: View {
    @Environment(\.horizontalSizeClass) var sizeClass
    @EnvironmentObject var favorites: Favorites
    @State private var selectedFacility: Facility?

    let resort: Resort

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
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

                Group {
                    HStack {
                        if sizeClass == .compact {
                            Spacer()

                            VStack {
                                ResortDetailView(resort: resort)
                            }

                            VStack {
                                SkiDetailsView(resort: resort)
                            }

                            Spacer()
                        } else {
                            ResortDetailView(resort: resort)
                            Spacer()
                                .frame(height: 0)
                            SkiDetailsView(resort: resort)
                        }
                    }
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .padding(.top)

                    Text(resort.description)
                        .padding(.vertical)

                    Text("Facilities")
                        .font(.headline)

                    HStack {
                        ForEach(resort.facilityTypes) { facility in
                            facility.icon
                                .font(.title)
                                .onTapGesture {
                                    selectedFacility = facility
                                }
                        }
                    }
                    .padding(.vertical)
                }
                .padding(.horizontal)
                
                Button(favorites.contains(resort) ? "Remove from favorites": "Add to favorites") {
                    if favorites.contains(resort) {
                        favorites.remove(resort)
                    } else {
                        favorites.add(resort)
                    }
                }
                .padding()
            }
        }
        .navigationBarTitle(Text("\(resort.name), \(resort.country)"), displayMode: .inline)
        .alert(item: $selectedFacility) { facility in
            facility.alert
        }
    }
}

struct ResortView_Previews: PreviewProvider {
    static var previews: some View {
        let favorites = Favorites()

        ResortView(resort: Resort.example)
            .environmentObject(favorites)
    }
}
