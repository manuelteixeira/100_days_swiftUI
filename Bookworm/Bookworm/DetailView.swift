//
//  Detail.swift
//  Bookworm
//
//  Created by Manuel Teixeira on 03/12/2020.
//

import CoreData
import SwiftUI

struct DetailView: View {
    @Environment(\.managedObjectContext) var moc
    @Environment(\.presentationMode) var presentationMode
    @State private var showingDeleteAlert = false

    let book: Book
    
    var formattedDate: String {
        guard let date = book.date else { return "Invalid date" }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        
        return dateFormatter.string(from: date)
    }

    var body: some View {
        GeometryReader { geometry in
            VStack {
                ZStack(alignment: .bottomTrailing) {
                    Image(self.book.genre ?? "Fantasy")
                        .frame(maxWidth: geometry.size.width)

                    Text(self.book.genre?.uppercased() ?? "FANTASY")
                        .font(.caption)
                        .fontWeight(.black)
                        .padding(8)
                        .foregroundColor(.white)
                        .background(Color.black.opacity(0.75))
                        .clipShape(Capsule())
                        .offset(x: -5, y: -5)
                }

                Text(self.book.author ?? "Unknown author")
                    .font(.title)
                    .foregroundColor(.secondary)

                Text(self.book.review ?? "No review")
                    .padding()

                RatingView(rating: .constant(Int(self.book.rating)))
                    .font(.largeTitle)
                
                Text(formattedDate)
                    .font(.caption)
                    .padding()

                Spacer()
            }
        }
        .navigationBarTitle(Text(book.title ?? "Unknown Book"), displayMode: .inline)
        .alert(isPresented: $showingDeleteAlert) {
            Alert(title: Text("Delete book"), message: Text("Are you sure?"), primaryButton: .destructive(Text("delete")) {
                self.deleteBook()
            }, secondaryButton: .cancel())
        }
        .navigationBarItems(trailing: Button(action: {
            self.showingDeleteAlert = true
        }) {
            Image(systemName: "trash")
        })
    }

    func deleteBook() {
        moc.delete(book)

        try? self.moc.save()

        presentationMode.wrappedValue.dismiss()
    }
}

struct DetailView_Previews: PreviewProvider {
    static let moc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)

    static var previews: some View {
        let book = Book(context: moc)
        book.title = "Test book"
        book.author = "Test author"
        book.genre = "Fantasy"
        book.rating = 4
        book.review = "This was a great book."
        book.date = Date()
        return DetailView(book: book)
    }
}
