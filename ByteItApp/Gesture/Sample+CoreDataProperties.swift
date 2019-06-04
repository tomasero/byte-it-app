//
//  Sample+CoreDataProperties.swift
//  ByteItApp
//
//  Created by Tomás Vega on 6/3/19.
//  Copyright © 2019 fluid. All rights reserved.
//

import Foundation
import CoreData


extension Sample {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Sample> {
        return NSFetchRequest<Sample>(entityName: "Sample")
    }
    
    @NSManaged public var name: String?
    @NSManaged public var accX: [Double]?
    @NSManaged public var accY: [Double]?
    @NSManaged public var accZ: [Double]?
    @NSManaged public var gyrX: [Double]?
    @NSManaged public var gyrY: [Double]?
    @NSManaged public var gyrZ: [Double]?
    
}
