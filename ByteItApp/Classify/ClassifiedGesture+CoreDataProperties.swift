//
//  ClassifiedGesture+CoreDataProperties.swift
//  ByteItApp
//
//  Created by Tomás Vega on 5/22/19.
//  Copyright © 2019 fluid. All rights reserved.
//

import Foundation
import CoreData


extension ClassifiedGesture {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ClassifiedGesture> {
        return NSFetchRequest<ClassifiedGesture>(entityName: "ClassifiedGesture")
    }
    
    @NSManaged public var gesture: String?
    @NSManaged public var time: Date?
    @NSManaged public var correct: NSNumber?
    
}
