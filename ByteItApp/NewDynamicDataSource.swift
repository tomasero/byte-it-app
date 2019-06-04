//
//  NewDynamicDataSource.swift
//  ByteItApp
//
//  Created by Tomás Vega on 6/3/19.
//  Copyright © 2019 fluid. All rights reserved.
//

import UIKit
import CoreData

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
    
    // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {

            guard let appDelegate =
                UIApplication.shared.delegate as? AppDelegate else {
                    return
            }
            
            let managedContext =
                appDelegate.persistentContainer.viewContext
            
            managedContext.delete(samples[indexPath.row] as NSManagedObject)
            samples.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            do {
                try managedContext.save()

            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }

        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

}
