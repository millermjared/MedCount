//
//  ModelEntity.swift
//  CoreDataTest
//
//  Created by Mathew Miller on 12/5/20.
//

import CoreData

enum ModelConfigurationError: Error {
    case EntityNotDefined
    case EntityCreationError
}

//MARK: Model Entity
protocol ModelEntity {
    static var name: String { get }
    static func entityDescription(in context: NSManagedObjectContext) throws -> NSEntityDescription
    
    //MARK: Streamlined creation and deletion declarations
    static func new(_ context: NSManagedObjectContext) throws -> Self
}

extension ModelEntity {
    static var name: String {
        get {
            return String(describing: self)
        }
    }
    
    static func entityDescription(in context: NSManagedObjectContext) throws -> NSEntityDescription {
        guard let description = NSEntityDescription.entity(forEntityName: name, in: context) else {
            throw ModelConfigurationError.EntityNotDefined
        }
        
        return description
    }
    
    //MARK: Streamlined creation and deletion implementations
    static func new(_ context: NSManagedObjectContext) throws -> Self {
        var modelEntity: Self?
        var configError: ModelConfigurationError?
        context.performAndWait {
            do {
                let description = try entityDescription(in: context)
                modelEntity = NSManagedObject(entity: description, insertInto: context) as? Self
            } catch {
                print(error.localizedDescription)
                configError = ModelConfigurationError.EntityCreationError
            }
        }
        
        if let configError = configError {
            throw configError
        }
        
        guard let result = modelEntity else {
            throw ModelConfigurationError.EntityCreationError
        }
        return result
    }
}

//MARK: Fetchable Model Entity
protocol FetchableModelEntity: NSFetchRequestResult {
    static func fetchedResultsController(in managedObjectContext: NSManagedObjectContext, sortedBy: [(String, Bool)]) throws -> NSFetchedResultsController<Self>
}

extension FetchableModelEntity where Self: NSManagedObject, Self: ModelEntity {
    static func fetchedResultsController(in managedObjectContext: NSManagedObjectContext, sortedBy: [(String, Bool)]) throws -> NSFetchedResultsController<Self> {
                
        let fetchRequest = NSFetchRequest<Self>(entityName: Self.name)
        
        fetchRequest.sortDescriptors = sortedBy.map({ (attributeName, ascending) -> NSSortDescriptor in
            return NSSortDescriptor(key: attributeName, ascending: ascending)
        })
                    
        let result = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        return result
    }
}

