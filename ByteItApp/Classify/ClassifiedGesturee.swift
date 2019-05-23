//
//  ClassifiedGesture.swift
//  GestureiOS
//
//  Created by Tomás Vega on 5/20/19.
//  Copyright © 2019 fluid. All rights reserved.
//

import Foundation

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
}
