//
//  Gesture+CoreDataProperties.swift
//  GestureiOS
//
//  Created by fluid on 11/26/18.
//  Copyright © 2018 fluid. All rights reserved.
//
//

import Foundation
import CoreData


extension Gesture {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Gesture> {
        return NSFetchRequest<Gesture>(entityName: "Gesture")
    }

    @NSManaged public var name: String?
    @NSManaged public var sensor: String?
    @NSManaged public var fileName: [String]?
    @NSManaged public var uniqueFileCount: [String:Int]?
    @NSManaged public var uniqueFileName: [String:String]?
    @NSManaged public var samples: Set<Sample>
    @NSManaged public var commands: Set<Command>

    func getString() -> String{
//        var export: String = NSLocalizedString("name,sensor,samples(name, accx, accy, accz, gyrx, gyry, gyrz)\n", comment: "")
        var export = ""
//        var header = "\(name!),\(sensor!),"
//        var header = "\(name!),"
        for sample in Array(samples) {
            export += "\(sample.getString())"
        }
        return export
    }
}
