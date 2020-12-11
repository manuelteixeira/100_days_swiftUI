//
//  Singer+CoreDataProperties.swift
//  CoreDataProject
//
//  Created by Manuel Teixeira on 11/12/2020.
//
//

import Foundation
import CoreData


extension Singer {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Singer> {
        return NSFetchRequest<Singer>(entityName: "Singer")
    }

    @NSManaged public var firstName: String?
    @NSManaged public var lastName: String?

    public var wrappedFirstName: String {
        firstName ?? "Unknown first name"
    }
    
    public var wrappedLastName: String {
        lastName ?? "Unknown last name"
    }
}

extension Singer : Identifiable {

}
