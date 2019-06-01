//
//  ClassifiedGesture.swift
//  GestureiOS
//
//  Created by Tomás Vega on 5/20/19.
//  Copyright © 2019 fluid. All rights reserved.
//

import Foundation
import UIKit

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
}
