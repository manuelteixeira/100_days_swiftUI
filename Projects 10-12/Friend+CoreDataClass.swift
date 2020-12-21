//
//  Friend+CoreDataClass.swift
//  Projects 10-12
//
//  Created by Manuel Teixeira on 21/12/2020.
//
//

import Foundation
import CoreData

@objc(Friend)
public class Friend: NSManagedObject {

    public required convenience init(from decoder: Decoder) throws {
        guard let context = decoder.userInfo[CodingUserInfoKey.context!] as? NSManagedObjectContext else { throw ManagedObjectError.decodeContextError }

        guard let entity = NSEntityDescription.entity(forEntityName: "Friend", in: context) else { throw ManagedObjectError.decodeEntityError }

        self.init(entity: entity, insertInto: context)

        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decodeIfPresent(String.self, forKey: .id)
        name = try container.decodeIfPresent(String.self, forKey: .name)
    }
}
