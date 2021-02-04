//
//  PersonUploadPhotoView.swift
//  Projects 13-15
//
//  Created by Manuel Teixeira on 02/02/2021.
//

import MapKit
import SwiftUI

struct PersonUploadPhotoView: View {
    enum SegmentedControl: Int {
        case photo = 0
        case map = 1
    }

    @Binding var people: People

    @State private var name = ""
    @State private var inputImage: UIImage?
    @State private var image: Image?
    @State private var isShowingImagePicker = false
    @State private var isShowingMap = SegmentedControl.photo
    @State private var locationAnnotation = MKPointAnnotation()
    @Environment(\.presentationMode) var presentationMode

    let locationFetcher = LocationFetcher()

    var body: some View {
        VStack {
            Form {
                Picker("Map", selection: $isShowingMap) {
                    Text("Photo").tag(SegmentedControl.photo)
                    Text("Map").tag(SegmentedControl.map)
                }
                .pickerStyle(SegmentedPickerStyle())

                if isShowingMap == SegmentedControl.photo {
                    Section(header: Text("Photo")) {
                        if let image = image {
                            image
                                .resizable()
                                .scaledToFit()
                        } else {
                            Button("Add photo") {
                                isShowingImagePicker = true
                            }
                        }
                    }
                } else {
                    Section(header: Text("Map")) {
                        MapView(location: $locationAnnotation)
                            .frame(height: 300)

                        Button("Use location") {
                            if let location = locationFetcher.lastKnownLocation {
                                let annotation = MKPointAnnotation()
                                annotation.coordinate = location
                                locationAnnotation = annotation
                            }
                        }
                    }
                }

                Section(header: Text("Details")) {
                    TextField("Name", text: $name)
                }

                Button("Save") {
                    save()
                }.disabled(name.isEmpty)
            }
        }
        .sheet(isPresented: $isShowingImagePicker, onDismiss: loadImage) {
            ImagePicker(image: $inputImage)
        }
        .onAppear(perform: {
            locationFetcher.start()
        })
    }

    func loadImage() {
        guard let inputImage = inputImage else { return }
        image = Image(uiImage: inputImage)
    }

    func save() {
        if let jpegData = inputImage?.jpegData(compressionQuality: 0.8) {
            let person = Person(
                id: UUID().uuidString,
                name: name,
                photo: jpegData,
                latitude: locationAnnotation.coordinate.latitude,
                longitude: locationAnnotation.coordinate.longitude)
            people.persons.append(person)

            let url = FileManager.getDocumentsDirectory().appendingPathComponent("people")

            do {
                if let data = try? JSONEncoder().encode(people) {
                    try data.write(to: url)
                    presentationMode.wrappedValue.dismiss()
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }
}

struct PersonUploadPhotoView_Previews: PreviewProvider {
    static var previews: some View {
        PersonUploadPhotoView(people: .constant(People.mock))
    }
}
