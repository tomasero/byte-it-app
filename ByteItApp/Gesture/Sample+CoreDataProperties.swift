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
    @NSManaged public var laccX: [Double]?
    @NSManaged public var laccY: [Double]?
    @NSManaged public var laccZ: [Double]?
    @NSManaged public var lgyrX: [Double]?
    @NSManaged public var lgyrY: [Double]?
    @NSManaged public var lgyrZ: [Double]?
    @NSManaged public var raccX: [Double]?
    @NSManaged public var raccY: [Double]?
    @NSManaged public var raccZ: [Double]?
    @NSManaged public var rgyrX: [Double]?
    @NSManaged public var rgyrY: [Double]?
    @NSManaged public var rgyrZ: [Double]?
    
    @NSManaged public var gesture: Gesture
    
    func normalizeVals() {
        let maxAccX: Double = self.laccX!.max()!
        self.laccX = self.laccX!.map{$0/maxAccX}
        
        let maxAccY = self.laccY!.max()!
        self.laccY = self.laccY!.map{$0/maxAccY}
        
        let maxAccZ = self.laccZ!.max()!
        self.laccZ = self.laccZ!.map{$0/maxAccZ}
    }
    
    func getString() -> String{
        var str = name!
        let atts = [laccX, laccY, laccZ, lgyrX, lgyrY, lgyrZ, raccX, raccY, raccZ, rgyrX, rgyrY, rgyrZ]
        for att in atts {
            let stringArray = att!.map { String($0) }
            let string = stringArray.joined(separator: "|")
            str += ",\(string)"
        }
        return str
    }
}
