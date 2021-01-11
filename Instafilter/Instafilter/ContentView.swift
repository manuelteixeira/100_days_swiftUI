//
//  ContentView.swift
//  Instafilter
//
//  Created by Manuel Teixeira on 04/01/2021.
//

import CoreImage
import CoreImage.CIFilterBuiltins
import SwiftUI

struct ContentView: View {
    @State private var image: Image?
    @State private var filterIntensity = 0.5
    @State private var filterRadius = 100.0
    @State private var filterScale = 10.0

    @State private var showingFilterSheet = false
    @State private var showingImagePicker = false
    @State private var showingSaveError = false
    @State private var inputImage: UIImage?
    @State private var processedImage: UIImage?

    @State var currentFilter: CIFilter = CIFilter.sepiaTone()
    let context = CIContext()

    var body: some View {
        let intensity = Binding<Double>(
            get: {
                self.filterIntensity
            },
            set: {
                self.filterIntensity = $0
                self.applyProcessing()
            }
        )

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

        return NavigationView {
            VStack {
                ZStack {
                    Rectangle()
                        .fill(Color.secondary)

                    if image != nil {
                        image?
                            .resizable()
                            .scaledToFit()
                    } else {
                        Text("Tap to select a picture")
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                }
                .onTapGesture {
                    self.showingImagePicker = true
                }

                HStack {
                    Text("Intensity")
                    Slider(value: intensity)
                }

                HStack {
                    Text("Radius")
                    Slider(value: radius, in: 0.0...100, step: 10)
                }

                HStack {
                    Text("Scale")
                    Slider(value: scale, in: 0.0...100, step: 10)
                }
                .padding(.vertical)

                HStack {
                    Button("\(currentFilter.name)") {
                        self.showingFilterSheet = true
                    }

                    Spacer()

                    Button("Save") {
                        guard let processedImage = self.processedImage else {
                            showingSaveError = true
                            return
                        }

                        let imageSaver = ImageSaver()
                        imageSaver.successHandler = {
                            print("Success")
                        }

                        imageSaver.errorHandler = {
                            print("Error \($0.localizedDescription)")
                        }

                        imageSaver.writeToPhotoAlbum(image: processedImage)
                    }
                }
            }
            .padding([.horizontal, .bottom])
            .navigationBarTitle("Instafilter")
            .sheet(isPresented: $showingImagePicker, onDismiss: loadImage) {
                ImagePicker(image: self.$inputImage)
            }
            .actionSheet(isPresented: $showingFilterSheet) {
                ActionSheet(title: Text("Select a filter"), buttons: [
                    .default(Text("Crystallize")) {
                        self.setFilter(CIFilter.crystallize())
                    },
                    .default(Text("Edges")) {
                        self.setFilter(CIFilter.edges())
                    },
                    .default(Text("Gaussian Blur")) {
                        self.setFilter(CIFilter.gaussianBlur())
                    },
                    .default(Text("Pixellate")) {
                        self.setFilter(CIFilter.pixellate())
                    },
                    .default(Text("Sepia tone")) {
                        self.setFilter(CIFilter.sepiaTone())
                    },
                    .default(Text("Unsharp Mask")) {
                        self.setFilter(CIFilter.unsharpMask())
                    },
                    .default(Text("Vignette")) {
                        self.setFilter(CIFilter.vignette())
                    },
                    .cancel()
                ])
            }
            .alert(isPresented: $showingSaveError) {
                Alert(title: Text("Save Error"), message: Text("No image selected, please select one image"), dismissButton: .default(Text("Ok")))
            }
        }
    }

    func loadImage() {
        guard let inputImage = inputImage else { return }

        let beginImage = CIImage(image: inputImage)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
        applyProcessing()
    }

    func applyProcessing() {
        let inputKeys = currentFilter.inputKeys
        if inputKeys.contains(kCIInputIntensityKey) {
            currentFilter.setValue(filterIntensity, forKey: kCIInputIntensityKey)
        }

        if inputKeys.contains(kCIInputRadiusKey) {
            currentFilter.setValue(filterRadius, forKey: kCIInputRadiusKey)
        }

        if inputKeys.contains(kCIInputScaleKey) {
            currentFilter.setValue(filterScale, forKey: kCIInputScaleKey)
        }

        guard let outputImage = currentFilter.outputImage else { return }

        if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            let uiImage = UIImage(cgImage: cgimg)
            image = Image(uiImage: uiImage)
            processedImage = uiImage
        }
    }

    func setFilter(_ filter: CIFilter) {
        currentFilter = filter
        loadImage()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
