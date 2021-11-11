//
//  Prescription+CoreDataProperties.swift
//  
//
//  Created by Mathew Miller on 10/29/21.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension Prescription {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Prescription> {
        return NSFetchRequest<Prescription>(entityName: "Prescription")
    }
    
    @NSManaged public var name: String?
    @NSManaged public var mg: Float
    @NSManaged public var ml: Float
    @NSManaged public var tablet: Float
    @NSManaged public var deliveryType: Int
    @NSManaged public var patient: Patient?
    @NSManaged public var consumptionRecords: Set<ConsumptionRecord>?

}

extension Prescription : Identifiable {

}
