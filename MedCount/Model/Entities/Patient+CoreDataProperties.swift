//
//  Patient+CoreDataProperties.swift
//  
//
//  Created by Mathew Miller on 10/29/21.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension Patient {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Patient> {
        return NSFetchRequest<Patient>(entityName: "Patient")
    }

    @NSManaged public var name: String?
    @NSManaged public var mrnNumber: String?
    @NSManaged public var gender: String?
    @NSManaged public var address: String?
    @NSManaged public var telephone: String?
    @NSManaged public var birthdate: Date?
    @NSManaged public var diagnosis: String?
    @NSManaged public var lastVisit: Date?
    @NSManaged public var nextVisit: Date?
    @NSManaged public var prescriptions: Set<Prescription>?

}

extension Patient : Identifiable {

}
