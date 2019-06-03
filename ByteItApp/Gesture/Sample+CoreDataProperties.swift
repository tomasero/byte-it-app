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
    
    @NSManaged public var accX: Array<Float>?
    @NSManaged public var accY: Array<Float>?
    @NSManaged public var accZ: Array<Float>?
    @NSManaged public var gyrX: Array<Float>?
    @NSManaged public var gyrY: Array<Float>?
    @NSManaged public var gyrZ: Array<Float>?
    
}
