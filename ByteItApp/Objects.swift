//
//  Objects.swift
//  GestureiOS
//
//  Created by Tomás Vega on 1/16/19.
//  Copyright © 2019 fluid. All rights reserved.
//

import UIKit

class Place: NSObject {
    var name: String
    var lon: Double
    var lat: Double
    init(name: String, lon: Double, lat: Double) {
        self.name = name
        self.lon = lon
        self.lat = lat
    }
}
