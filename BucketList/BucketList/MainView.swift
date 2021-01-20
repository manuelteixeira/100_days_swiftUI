//
//  MainView.swift
//  BucketList
//
//  Created by Manuel Teixeira on 20/01/2021.
//

import SwiftUI
import MapKit

struct MainView: View {
    @State private var centerCoordinate = CLLocationCoordinate2D()
    
    @Binding var locations: [CodableMKPointAnnotation]
    @Binding var selectedPlace: MKPointAnnotation?
    @Binding var showingPlaceDetails: Bool
    @Binding var showingEditScreen: Bool
    
    var body: some View {
        Group {
            MapView(centerCoordinate: $centerCoordinate, selectedPlace: $selectedPlace, showingPlaceDetails: $showingPlaceDetails, annotations: locations)
                .edgesIgnoringSafeArea(.all)
            
            Circle()
                .fill(Color.blue)
                .opacity(0.3)
                .frame(width: 32, height: 32)
            
            VStack {
                Spacer()
                
                HStack {
                    Spacer()
                    
                    Button(action: {
                        let newLocation = CodableMKPointAnnotation()
                        newLocation.coordinate = self.centerCoordinate
                        newLocation.title = "Example location"
                        newLocation.subtitle = "Example subtitle"
                        self.locations.append(newLocation)
                        
                        self.selectedPlace = newLocation
                        self.showingEditScreen = true
                    }) {
                        Image(systemName: "plus")
                            .padding()
                            .background(Color.black.opacity(0.75))
                            .foregroundColor(.white)
                            .font(.title)
                            .clipShape(Circle())
                            .padding(.trailing)
                    }
                }
            }            
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        let locations = [CodableMKPointAnnotation]()
        let selectedPlace = MKPointAnnotation.example
        let showingPlaceDetails = false
        let showingEditScreen = false
        
        
        MainView(locations: .constant(locations), selectedPlace: .constant(selectedPlace), showingPlaceDetails: .constant(showingPlaceDetails), showingEditScreen: .constant(showingEditScreen))
    }
}
