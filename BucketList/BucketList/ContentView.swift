//
//  ContentView.swift
//  BucketList
//
//  Created by Manuel Teixeira on 12/01/2021.
//

import LocalAuthentication
import MapKit
import SwiftUI

struct ContentView: View {
    @State private var isUnlocked = false
    @State private var locations = [CodableMKPointAnnotation]()
    @State private var selectedPlace: MKPointAnnotation?
    @State private var showingPlaceDetails = false
    @State private var showingEditScreen = false

    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showingErrorAlert = false

    var body: some View {
        // Possible swiftUI Bug
        // This binding shouldn't be necessary, we should just need to pass $selectedPlace to MainView
        let selectedPlaceBinding = Binding(
            get: { selectedPlace },
            set: { selectedPlace = $0 }
        )

        ZStack {
            if isUnlocked {
                MainView(
                    locations: $locations,
                    selectedPlace: selectedPlaceBinding,
                    showingPlaceDetails: $showingPlaceDetails,
                    showingEditScreen: $showingEditScreen
                )
                .alert(isPresented: $showingPlaceDetails) {
                    Alert(title: Text(selectedPlace?.title ?? "Unknown"), message: Text(selectedPlace?.subtitle ?? "Missing place information"), primaryButton: .default(Text("OK")), secondaryButton: .default(Text("Edit")) {
                        self.showingEditScreen = true
                    })
                }
            } else {
                Button("Unlock places") {
                    self.authenticate()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .clipShape(Capsule())
                .alert(isPresented: $showingErrorAlert, content: {
                    Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("Ok")))
                })
            }
        }
        .sheet(isPresented: $showingEditScreen, onDismiss: saveData) {
            if self.selectedPlace != nil {
                EditView(placemark: self.selectedPlace!)
            }
        }
        .onAppear(perform: loadData)
    }

    func loadData() {
        let filename = FileManager.getDocumentsDirectory().appendingPathExtension("SavedPlaces")

        do {
            let data = try Data(contentsOf: filename)
            locations = try JSONDecoder().decode([CodableMKPointAnnotation].self, from: data)
        } catch {
            print("Unable to load saved data.")
        }
    }

    func saveData() {
        do {
            let filename = FileManager.getDocumentsDirectory().appendingPathExtension("SavedPlaces")
            let data = try JSONEncoder().encode(locations)
            try data.write(to: filename, options: [.atomicWrite, .completeFileProtection])
        } catch {
            print("Unable to save data")
        }
    }

    func authenticate() {
        let context = LAContext()
        var error: NSError?

        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Please authenticate yourself to unlock your places."

            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, _ in

                DispatchQueue.main.async {
                    if success {
                        self.isUnlocked = true
                    } else {
                        // Error
                        self.alertTitle = "Error"
                        self.alertMessage = "Access denied"
                        self.showingErrorAlert = true
                    }
                }
            }
        } else {
            // No Biometrics
            alertTitle = "Error"
            alertMessage = "No biometrics available"
            showingErrorAlert = true
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
