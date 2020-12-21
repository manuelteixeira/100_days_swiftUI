//
//  DetailView.swift
//  Projects 10-12
//
//  Created by Manuel Teixeira on 15/12/2020.
//

import CoreData
import SwiftUI

struct DetailView: View {
    @Environment(\.managedObjectContext) var moc

    var user: User

    var body: some View {
        VStack {
            Form {
                Section(header: Text("Personal details")) {
                    Text(user.wrappedName)
                    Text("\(user.age)")
                    Text(user.wrappedEmail)
                    Text(user.wrappedAddress)
                }

                Section(header: Text("Bio")) {
                    Text(user.wrappedCompany)
                    Text(user.wrappedAbout)
                    Text(user.formattedDate)
                }

                Section(header: Text("Tags")) {
                    ScrollView(.horizontal) {
                        HStack {
                            ForEach(user.wrappedTags, id: \.self) {
                                Text($0)
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                    .padding(10)
                                    .background(Color.blue)
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                        }
                    }
                }

                Section(header: Text("Friends")) {
                    ForEach(user.wrappedFriends, id: \.id) { friend in
                        NavigationLink(destination: FriendDetailView(friend: friend)) {
                            Text(friend.wrappedName)
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .padding(10)
                                .background(Color.green)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                }
            }
        }.navigationTitle("Details")
    }
}

struct DetailView_Previews: PreviewProvider {
    static let moc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)

    static var previews: some View {
        let user = User(context: moc)
        user.id = "ID"
        user.isActive = true
        user.name = "Test name"
        user.age = 30
        user.company = "Test company"
        user.email = "mail@mail.com"
        user.address = "Test address"
        user.about = "Test about"
        user.registered = Date()
        user.tags = ["Test tags", "test tags1", "Test tags", "test tags1", "Test tags", "test tags1"]
        
        let friend = Friend(context: moc)
        friend.id = "id"
        friend.name = "name"
        user.friends = [friend]

        return DetailView(user: user)
    }
}
