//
//  DataSource.swift
//  GestureiOS
//
//  Created by fluid on 11/20/18.
//  Copyright © 2018 fluid. All rights reserved.
//

import UIKit

class StaticDataSource: NSObject, UITableViewDataSource, UITableViewDelegate {
    
    var sampleFileNames = [String]()
    
    override init(){
        super.init()
    }
    
    func setData(sampleFileNames:[String]){
        self.sampleFileNames = sampleFileNames
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sampleFileNames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        
        // Configure the cell...
        
        return cell
    }
    
     func numberOfSections(in tableView: UITableView) -> Int {
            // #warning Incomplete implementation, return the number of sections
            return 3
        }
    
    
    
//    var items : [String] = ["GRE Test Structure ","GRE Score "]
    
//    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
//
//        return 1;
//    }
//
//    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 2;
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as? UITableViewCell
//        cell.textLabel?.text = items[indexPath.row]
//        return cell
//    }
}
