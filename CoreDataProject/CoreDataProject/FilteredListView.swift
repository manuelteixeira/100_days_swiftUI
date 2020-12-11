//
//  FilteredListView.swift
//  CoreDataProject
//
//  Created by Manuel Teixeira on 11/12/2020.
//

import CoreData
import SwiftUI

struct FilteredListView<T: NSManagedObject, Content: View>: View {
    var fetchRequest: FetchRequest<T>
    var singers: FetchedResults<T> { fetchRequest.wrappedValue }

    // this is our content closure; we'll call this once for each item in the list
    let content: (T) -> Content

    var body: some View {
        List(fetchRequest.wrappedValue, id: \.self) { singer in
            self.content(singer)
        }
    }

    init(filterKey: String, filterValue: String, sortDescriptors: [NSSortDescriptor], predicate: FilteredListPredicate, @ViewBuilder content: @escaping (T) -> Content) {
        fetchRequest = FetchRequest<T>(
            entity: T.entity(),
            sortDescriptors: sortDescriptors,
            predicate: NSPredicate(format: "%K \(predicate.rawValue) %@", filterKey, filterValue)
        )
        self.content = content
    }
}

enum FilteredListPredicate: String {
    case beginsWith = "BEGINSWITH"
    case contains = "CONTAINS"
}
