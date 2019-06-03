//
//  ClassifiedGesture.swift
//  GestureiOS
//
//  Created by Tomás Vega on 5/20/19.
//  Copyright © 2019 fluid. All rights reserved.
//

import Foundation
import UIKit
import CoreData

struct ClassifiedGesturee: CustomStringConvertible {
    let gestureClass: String
    let time: String
    let correct: Bool
    var description: String {
        return time + " " + gestureClass + " correct: " + (correct ? "YES" : "NO")
    }
}
class Shared {
    private init() { }
    static let instance = Shared()
    var gestures: [ClassifiedGesturee] = []
    var gruController: GRUController = GRUController()
    let activities = ["still", "walking", "running", "biking"]
    
    func getVC(name: String) -> UIViewController? {
        let children = UIApplication.shared.windows[0].rootViewController?.children
        for chichildren in children! {
            for child in chichildren.children {
                let vcName = NSStringFromClass(child.classForCoder).components(separatedBy: ".").last!
                if vcName == name {
                    print("found")
                    print(child)
                    return child
                }
            }
        }
        return nil
    }
    
//    func loadData(entityName: String) -> [NSFetchRequestResult] {
//        guard let appDelegate =
//            UIApplication.shared.delegate as? AppDelegate else {
//                return
//        }
//        let managedContext =
//            appDelegate.persistentContainer.viewContext
//        let fetchRequest =
//            NSFetchRequest<NSManagedObject>(entityName: "ClassifiedGesture")
//        do {
//            classifiedGestures = try managedContext.fetch(fetchRequest) as! [ClassifiedGesture]
//            classifiedGestures.reverse()
//        } catch let error as NSError {
//            print("Could not fetch. \(error), \(error.userInfo)")
//        }
//    }
}
