//
//  EntityA+CoreDataProperties.swift
//  CoreDataTest
//
//  Created by Mathew Miller on 12/5/20.
//
//

import Foundation
import CoreData


extension EntityA {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EntityA> {
        return NSFetchRequest<EntityA>(entityName: "EntityA")
    }

    @NSManaged public var attributeA: String?

}

extension EntityA : Identifiable {

}
