//
//  ModelEntity.swift
//  CoreDataTest
//
//  Created by Mathew Miller on 12/5/20.
//

import CoreData

enum ModelConfigurationError: Error {
    case EntityNotDefined
}

protocol ModelEntity {
    static var name: String { get }
    static func entityDescription(in context: NSManagedObjectContext) throws -> NSEntityDescription
}

extension ModelEntity {
    static func entityDescription(in context: NSManagedObjectContext) throws -> NSEntityDescription {
        guard let description = NSEntityDescription.entity(forEntityName: name, in: context) else {
            throw ModelConfigurationError.EntityNotDefined
        }
        
        return description
    }    
}
