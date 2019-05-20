//
//  GestureData+CoreDataProperties.swift
//  GestureiOS
//
//  Created by fluid on 11/25/18.
//  Copyright © 2018 fluid. All rights reserved.
//
//

import Foundation
import CoreData


extension GestureData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<GestureData> {
        return NSFetchRequest<GestureData>(entityName: "GestureData")
    }

    @NSManaged public var fileName: String?
    @NSManaged public var gesture: Gesture?

}
