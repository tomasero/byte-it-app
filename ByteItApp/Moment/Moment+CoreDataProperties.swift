//
//  Moment+CoreDataProperties.swift
//  GestureiOS
//
//  Created by Tomás Vega on 1/17/19.
//  Copyright © 2019 fluid. All rights reserved.
//

import Foundation
import CoreData


extension Moment {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Moment> {
        return NSFetchRequest<Moment>(entityName: "Moment")
    }
    
    @NSManaged public var name: String?
    @NSManaged public var time: Date?
    @NSManaged public var person: String?
    @NSManaged public var place: String?
    @NSManaged public var lon: NSNumber?
    @NSManaged public var lat: NSNumber?
    
}
