//
//  Minder+CoreDataClass.swift
//  ByteItApp
//
//  Created by Shardul Sapkota on 7/9/19.
//  Copyright © 2019 fluid. All rights reserved.
//
//

import Foundation
import CoreData

@objc(Minder)
public class Minder: NSManagedObject {
    
}

extension Minder {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Minder> {
        return NSFetchRequest<Minder>(entityName: "Minder")
    }
    
    @NSManaged public var minderOn: Bool
    @NSManaged public var moment: Moment
    @NSManaged public var minderText: String?
    
}

