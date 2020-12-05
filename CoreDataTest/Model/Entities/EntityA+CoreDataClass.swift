//
//  EntityA+CoreDataClass.swift
//  CoreDataTest
//
//  Created by Mathew Miller on 12/5/20.
//
//

import Foundation
import CoreData

@objc(EntityA)
public class EntityA: NSManagedObject, ModelEntity {
    static var name = "EntityA"
}
