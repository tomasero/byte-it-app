//
//  Command+CoreDataProperties.swift
//  ByteItApp
//
//  Created by Tomás Vega on 6/3/19.
//  Copyright © 2019 fluid. All rights reserved.
//

import Foundation
import CoreData


extension Command {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Command> {
        return NSFetchRequest<Command>(entityName: "Command")
    }
    
    @NSManaged public var name: String?
    @NSManaged public var gesture: Gesture?
    @NSManaged public var action: String?
    @NSManaged public var active: NSNumber?
    
}
