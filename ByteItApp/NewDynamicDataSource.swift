//
//  NewDynamicDataSource.swift
//  ByteItApp
//
//  Created by Tomás Vega on 6/3/19.
//  Copyright © 2019 fluid. All rights reserved.
//

import UIKit

class NewDynamicDataSource: NSObject,UITableViewDataSource,UITableViewDelegate {

    var samples: [Sample] = [Sample]()
    
    override init(){
        super.init()
    }
    
    func setData(samples: [Sample]){
        self.samples = samples
    }
    
    func getData() -> [Sample] {
        return self.samples
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return samples.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = (samples[indexPath.row] as Sample).name
        return cell
    }
    
//    // Override to support editing the table view.
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//
//
//            let fileManager = FileManager.default
//            do {
//                let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create: true)
//                let fileURL = documentDirectory.appendingPathComponent(self.sampleFileNames[indexPath.row]).appendingPathExtension("txt")
//                print("Deleting File at File Path: \(fileURL.path)")
//
//                try fileManager.removeItem(atPath: fileURL.path)
//
//                print("File successfully deleted")
//
//            } catch {
//                print(error)
//            }
//
//
//            sampleFileNames.remove(at: indexPath.row)
//
//            tableView.deleteRows(at: [indexPath], with: .fade)
//
//
//        } else if editingStyle == .insert {
//            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
//        }
//    }
    
//    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        // Return false if you do not want the specified item to be editable.
//        return true
//    }
//    
}
