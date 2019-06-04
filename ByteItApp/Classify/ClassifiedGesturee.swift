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

//class Sample {
//
//    var number:Int = 0
//    init(number:Int) {
//        self.number = number
//    }
//
//    var accX = Array<Float>()
//    var accY = Array<Float>()
//    var accZ = Array<Float>()
//    var gyrX = Array<Float>()
//    var gyrY = Array<Float>()
//    var gyrZ = Array<Float>()
//
//    func normalizeVals() {
//        let maxAccX = self.accX.max()
//        self.accX = self.accX.map{$0/maxAccX!}
//
//        let maxAccY = self.accY.max()
//        self.accY = self.accY.map{$0/maxAccY!}
//
//        let maxAccZ = self.accZ.max()
//        self.accZ = self.accZ.map{$0/maxAccZ!}
//
//        //        let maxGyrX = self.gyrX.max()
//        //        self.gyrX = self.gyrX.map{$0/maxGyrX!}
//        //
//        //        let maxGyrY = self.gyrY.max()
//        //        self.gyrY = self.gyrY.map{$0/maxGyrY!}
//        //
//        //        let maxGyrZ = self.gyrZ.max()
//        //        self.gyrZ = self.gyrZ.map{$0/maxGyrZ!}
//    }
//}

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
    
    func loadData(entityName: String) -> [NSManagedObject]? {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return nil
        }
        let managedContext =
            appDelegate.persistentContainer.viewContext
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: entityName)
        do {
            let dataArray = try managedContext.fetch(fetchRequest)
            return dataArray
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        return nil
    }
}
