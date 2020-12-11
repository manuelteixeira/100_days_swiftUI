# Day 59 - Project 12, part 3

- Challenges

    1. Make it accept an array of **`NSSortDescriptor`** objects to get used in its fetch request.

        ```swift
        @State private var sortAscending = true
        ```

        ```swift
        Button("Sort \(sortAscending ? "descending" : "ascending")") {
            self.sortAscending.toggle()
        }
        ```

        ```swift
        init(filterKey: String, filterValue: String, sortDescriptors: [NSSortDescriptor], @ViewBuilder content: @escaping (T) -> Content) {
            fetchRequest = FetchRequest<T>(
                entity: T.entity(),
                sortDescriptors: sortDescriptors,
                predicate: NSPredicate(format: "%K BEGINSWITH %@", filterKey, filterValue)
            )
            self.content = content
        }
        ```

        ```swift
        let sortDescriptor = NSSortDescriptor(keyPath: \Singer.lastName, ascending: sortAscending)
                    
        FilteredListView(filterKey: "lastName", filterValue: lastNameFilter, sortDescriptors: [sortDescriptor]) { (singer: Singer) in
            Text("\(singer.wrappedFirstName) \(singer.wrappedLastName)")
        }
        ```

    2. Make it accept a string parameter that controls which predicate is applied. You can use Swift’s string interpolation to place this in the predicate.

        ```swift
        init(filterKey: String, filterValue: String, sortDescriptors: [NSSortDescriptor], predicate: String, @ViewBuilder content: @escaping (T) -> Content) {
            fetchRequest = FetchRequest<T>(
                entity: T.entity(),
                sortDescriptors: sortDescriptors,
                predicate: NSPredicate(format: "%K \(predicate) %@", filterKey, filterValue)
            )
            self.content = content
        }
        ```

    3. Modify the predicate string parameter to be an enum such as **`.beginsWith`**, then make that enum get resolved to a string inside the initializer.

        ```swift
        init(filterKey: String, filterValue: String, sortDescriptors: [NSSortDescriptor], predicate: FilteredListPredicate, @ViewBuilder content: @escaping (T) -> Content) {
            fetchRequest = FetchRequest<T>(
                entity: T.entity(),
                sortDescriptors: sortDescriptors,
                predicate: NSPredicate(format: "%K \(predicate.rawValue) %@", filterKey, filterValue)
            )
            self.content = content
        }
        ```

        ```swift
        enum FilteredListPredicate: String {
            case beginsWith = "BEGINSWITH"
            case contains = "CONTAINS"
        }
        ```

        ```swift
        FilteredListView(filterKey: "lastName", filterValue: lastNameFilter, sortDescriptors: [sortDescriptor], predicate: .contains) { (singer: Singer) in
            Text("\(singer.wrappedFirstName) \(singer.wrappedLastName)")
        }
        ```