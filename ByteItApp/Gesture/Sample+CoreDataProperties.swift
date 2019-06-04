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
    
    @NSManaged public var gesture: Gesture
    
    func normalizeVals() {
        let maxAccX: Double = self.accX!.max()!
        self.accX = self.accX!.map{$0/maxAccX}
        
        let maxAccY = self.accY!.max()!
        self.accY = self.accY!.map{$0/maxAccY}
        
        let maxAccZ = self.accZ!.max()!
        self.accZ = self.accZ!.map{$0/maxAccZ}
    }
}
