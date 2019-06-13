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
    @NSManaged public var actualGesture: String?
    @NSManaged public var time: Date?
    @NSManaged public var correct: NSNumber?
    @NSManaged public var activity: String?
    
    func getTime() -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .short
        let time = formatter.string(from: self.time!)
        return time
    }
    
    func getString() -> String {
        let timeStr = self.getTime().replacingOccurrences(of: " ", with: "")
        let predictedStr = gesture ?? "nil"
        let actualStr = actualGesture ?? "nil"
        let activityStr = activity ?? "nil"
        return "\(timeStr),\(predictedStr),\(correct!),\(actualStr),\(activityStr)"
    }
}
