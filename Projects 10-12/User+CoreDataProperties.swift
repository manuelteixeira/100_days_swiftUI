//
//  User+CoreDataProperties.swift
//  Projects 10-12
//
//  Created by Manuel Teixeira on 21/12/2020.
//
//

import CoreData
import Foundation

extension User {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<User> {
        return NSFetchRequest<User>(entityName: "User")
    }

    @NSManaged public var id: String?
    @NSManaged public var isActive: Bool
    @NSManaged public var name: String?
    @NSManaged public var age: Int16
    @NSManaged public var company: String?
    @NSManaged public var email: String?
    @NSManaged public var address: String?
    @NSManaged public var about: String?
    @NSManaged public var registered: Date?
    @NSManaged public var tags: [String]?
    @NSManaged public var friends: NSSet?

    public var formattedDate: String {
        guard let date = registered else { return "Invalid date" }
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .medium

        return formatter.string(from: date)
    }

    public var wrappedName: String {
        name ?? "Unknown name"
    }

    public var wrappedCompany: String {
        company ?? "Unknown company"
    }

    public var wrappedEmail: String {
        email ?? "Unknown email"
    }

    public var wrappedAddress: String {
        address ?? "Unknown address"
    }

    public var wrappedAbout: String {
        about ?? "Unknown about"
    }
    
    public var wrappedTags: [String] {
        tags ?? []
    }
    
    public var wrappedFriends: [Friend] {
        let friendsArray = friends as? Set<Friend> ?? []
        return friendsArray.sorted {
            $0.wrappedName < $1.wrappedName
        }
    }
}

// MARK: Generated accessors for friends

extension User {
    @objc(addFriendsObject:)
    @NSManaged public func addToFriends(_ value: Friend)

    @objc(removeFriendsObject:)
    @NSManaged public func removeFromFriends(_ value: Friend)

    @objc(addFriends:)
    @NSManaged public func addToFriends(_ values: NSSet)

    @objc(removeFriends:)
    @NSManaged public func removeFromFriends(_ values: NSSet)
}

extension User: Identifiable {
}

extension User: Decodable {
    enum CodingKeys: CodingKey {
        case id
        case isActive
        case name
        case age
        case company
        case email
        case address
        case about
        case registered
        case tags
        case friends
    }
}
