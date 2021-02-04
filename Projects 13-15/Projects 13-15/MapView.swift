//
//  MapView.swift
//  Projects 13-15
//
//  Created by Manuel Teixeira on 04/02/2021.
//

import MapKit
import SwiftUI

struct MapView: UIViewRepresentable {
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView

        init(_ parent: MapView) {
            self.parent = parent
        }
    }

    @Binding var location: MKPointAnnotation

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        return mapView
    }

    func updateUIView(_ view: MKMapView, context: Context) {
        view.addAnnotation(location)
        view.centerCoordinate = location.coordinate
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
}
