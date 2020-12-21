//
//  Friend+CoreDataProperties.swift
//  Projects 10-12
//
//  Created by Manuel Teixeira on 21/12/2020.
//
//

import Foundation
import CoreData


extension Friend {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Friend> {
        return NSFetchRequest<Friend>(entityName: "Friend")
    }

    @NSManaged public var id: String?
    @NSManaged public var name: String?
    @NSManaged public var user: User?

    public var wrappedName: String {
        return name ?? "unknown name"
    }
}

extension Friend : Identifiable {

}

extension Friend: Decodable {
    enum CodingKeys: CodingKey {
        case id
        case name
    }
}
