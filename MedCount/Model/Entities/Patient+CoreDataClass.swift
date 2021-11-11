//
//  Patient+CoreDataClass.swift
//  
//
//  Created by Mathew Miller on 10/29/21.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


public final class Patient: NSManagedObject, ModelEntity, FetchableModelEntity {

    public var age: Int {
        
        let ageValue = Calendar(identifier: .gregorian).dateComponents([.year], from: birthdate ?? Date(), to: Date())
        return ageValue.year ?? 0
    }
    
}
