//
//  PersonUploadPhotoView.swift
//  Projects 13-15
//
//  Created by Manuel Teixeira on 02/02/2021.
//

import SwiftUI

struct PersonUploadPhotoView: View {
    @Binding var people: People
    
    @State private var name = ""
    @State private var inputImage: UIImage?
    @State private var image: Image?
    @State private var isShowingImagePicker = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
            Form {
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
    }
    
    func loadImage() {
        guard let inputImage = inputImage else { return }
        image = Image(uiImage: inputImage)
    }
    
    func save() {
        if let jpegData = inputImage?.jpegData(compressionQuality: 0.8) {
            let person = Person(id: UUID().uuidString, name: name, photo: jpegData)
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
        PersonUploadPhotoView(people: .constant(People(persons: [Person(id: UUID().uuidString, name: "Hello", photo: Data())])))
    }
}
