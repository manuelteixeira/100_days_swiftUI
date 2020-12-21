//
//  FriendDetailView.swift
//  Projects 10-12
//
//  Created by Manuel Teixeira on 15/12/2020.
//

import CoreData
import SwiftUI

struct FriendDetailView: View {
    @Environment(\.managedObjectContext) var moc

    var friend: Friend

    var body: some View {
        VStack {
            Form {
                Section(header: Text("Personal details")) {
                    Text(friend.wrappedName)
                        .font(.headline)
                }
            }
        }.navigationTitle("Friend Details")
    }
}

struct FriendDetailView_Previews: PreviewProvider {
    static let moc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)

    static var previews: some View {
        let friend = Friend(context: moc)
        friend.id = "ID"
        friend.name = "Name"

        return FriendDetailView(friend: friend)
    }
}
