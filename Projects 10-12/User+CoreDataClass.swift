//
//  User+CoreDataClass.swift
//  Projects 10-12
//
//  Created by Manuel Teixeira on 21/12/2020.
//
//

import Foundation
import CoreData

@objc(User)
public class User: NSManagedObject {
    public required convenience init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.context!] as? NSManagedObjectContext else { throw ManagedObjectError.decodeContextError }

        guard let entity = NSEntityDescription.entity(forEntityName: "User", in: context) else { throw ManagedObjectError.decodeEntityError }

        self.init(entity: entity, insertInto: context)

        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decodeIfPresent(String.self, forKey: .id)
        isActive = try container.decodeIfPresent(Bool.self, forKey: .isActive) ?? false
        name = try container.decodeIfPresent(String.self, forKey: .name)
        age = try container.decodeIfPresent(Int16.self, forKey: .age) ?? 0
        company = try container.decodeIfPresent(String.self, forKey: .company)
        email = try container.decodeIfPresent(String.self, forKey: .email)
        address = try container.decodeIfPresent(String.self, forKey: .address)
        about = try container.decodeIfPresent(String.self, forKey: .about)
        registered = try container.decodeIfPresent(Date.self, forKey: .registered)
        tags = try container.decodeIfPresent([String].self, forKey: .tags)

        let friendArray = try container.decode([Friend].self, forKey: .friends)
        friends = NSSet(array: friendArray)
    }
}
