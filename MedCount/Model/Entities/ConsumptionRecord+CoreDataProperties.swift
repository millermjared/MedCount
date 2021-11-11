//
//  ConsumptionRecord+CoreDataProperties.swift
//  
//
//  Created by Mathew Miller on 10/29/21.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension ConsumptionRecord {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ConsumptionRecord> {
        return NSFetchRequest<ConsumptionRecord>(entityName: "ConsumptionRecord")
    }

    @NSManaged public var amount: Float
    @NSManaged public var date: Date?
    @NSManaged public var prescription: Prescription?

}

extension ConsumptionRecord : Identifiable {

}
