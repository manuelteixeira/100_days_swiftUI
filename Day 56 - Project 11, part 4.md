# Day 56 - Project 11, part 4

- Challenge

    1. Right now it’s possible to select no genre for books, which causes a problem for the detail view. Please fix this, either by forcing a default, validating the form, or showing a default picture for unknown genres – you can choose.

        ```swift
        Section {
            Button("Save") {
                let newBook = Book(context: self.moc)
                
                newBook.title = self.title
                newBook.author = self.author
                newBook.rating = Int16(self.rating)
                newBook.genre = self.genre
                newBook.review = self.review
                
                try? self.moc.save()
                
                self.presentationMode.wrappedValue.dismiss()
            }
        }
        .disabled(genre.isEmpty)
        ```

    2. Modify **`ContentView`** so that books rated as 1 star have their name shown in red.

        ```swift
        Text(book.title ?? "Unknown title")
        	.font(.headline)
        	.foregroundColor(book.rating == minimumRating ? Color.red : Color.black)
        ```

    3. Add a new “date” attribute to the Book entity, assigning **`Date()`** to it so it gets the current date and time, then format that nicely somewhere in **`DetailView`**.

        ```swift
        Button("Save") {
            let newBook = Book(context: self.moc)
            
            newBook.title = self.title
            newBook.author = self.author
            newBook.rating = Int16(self.rating)
            newBook.genre = self.genre
            newBook.review = self.review
            newBook.date = Date()
            
            try? self.moc.save()
            
            self.presentationMode.wrappedValue.dismiss()
        }
        ```

        ```swift
        var formattedDate: String {
            guard let date = book.date else { return "Invalid date" }
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .short
            
            return dateFormatter.string(from: date)
        }
        ```

        ```swift
        Text(formattedDate)
            .font(.caption)
            .padding()
        ```