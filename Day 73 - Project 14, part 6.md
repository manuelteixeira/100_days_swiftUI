# Day 73 - Project 14, part 6

- Challenge

    1. Our + button is rather hard to tap. Try moving all its modifiers to the image inside the button – what difference does it make, and can you think why?

        ```swift
        Button(action: {
            let newLocation = CodableMKPointAnnotation()
            newLocation.coordinate = self.centerCoordinate
            newLocation.title = "Example location"
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
        ```

    2. Having a complex **`if`** condition in the middle of **`ContentView`** isn’t easy to read – can you rewrite it so that the **`MapView`**, **`Circle`**, and **`Button`** are part of their own view? This might take more work than you think!

        ```swift
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
                    } else {
                        Button("Unlock places") {
                            self.authenticate()
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                    }
                }
        	//...
        }
        ```

        ```swift
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
        				//...
        				}
        		}
        }
        ```

    3. Our app silently fails when errors occur during biometric authentication. Add code to show those errors in an alert, but be careful: you can only add one **`alert()`** modifier to each view.

        ```swift
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
        ```

        **Note**: if either one of the **`.alert`** is on the **`ZStack`** it won't work.