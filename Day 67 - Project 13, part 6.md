# Day 67 - Project 13, part 6

- Challenge

    1. Try making the Save button show an error if there was no image in the image view.

        ```swift
        guard let processedImage = self.processedImage else {
            showingSaveError = true
            return
        }
        ```

        ```swift
        .alert(isPresented: $showingSaveError) {
        	Alert(title: Text("Save Error"), message: Text("No image selected, please select one image"), dismissButton: .default(Text("Ok")))
        }
        ```

    2. Make the Change Filter button change its title to show the name of the currently selected filter.

        ```swift
        Button("\(currentFilter.name)") {
            self.showingFilterSheet = true
        }
        ```

    3. Experiment with having more than one slider, to control each of the input keys you care about. For example, you might have one for radius and one for intensity.

        ```swift
        let radius = Binding<Double>(
        	  get: {
              self.filterRadius
            },
            set: {
                self.filterRadius = $0
                self.applyProcessing()
            }
        )

        let scale = Binding<Double>(
            get: {
                self.filterScale
            },
            set: {
                self.filterScale = $0
                self.applyProcessing()
            }
        )
        ```

        ```swift
        HStack {
            Text("Radius")
            Slider(value: radius, in: 0.0...100, step: 10)
        }

        HStack {
            Text("Scale")
            Slider(value: scale, in: 0.0...100, step: 10)
        }
        ```

        ```swift
        if inputKeys.contains(kCIInputRadiusKey) {
            currentFilter.setValue(filterRadius, forKey: kCIInputRadiusKey)
        }

        if inputKeys.contains(kCIInputScaleKey) {
        	  currentFilter.setValue(filterScale, forKey: kCIInputScaleKey)
        }
        ```