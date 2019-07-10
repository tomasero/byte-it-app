//
//  MomentsViewController.swift
//  GestureiOS
//
//  Created by Tomás Vega on 1/14/19.
//  Copyright © 2019 fluid. All rights reserved.
//

import UIKit
import CoreData
import os.log

protocol isAbleToReceiveMoment {
    func pass(moment: Moment)
}

class MomentsViewController: UITableViewController, isAbleToReceiveMoment {
    
    var delegate: isAbleToReceiveMoment?
    var moments: [Moment] = []
    

    
    func pass(moment: Moment) {
        print("Moments of success")
        print(moment)
//        moments.append(moment)s

        print("moments")
        print(moments)
        
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            // Update an existing gesture.
            moments[selectedIndexPath.row] = moment
            tableView.reloadRows(at: [selectedIndexPath], with: .none)
        } else {
            // Add a new gesture.
            let newIndexPath = IndexPath(row: moments.count, section: 0)
            
            moments.append(moment)
            tableView.insertRows(at: [newIndexPath], with: .automatic)
            self.tableView.reloadData()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        navigationItem.leftBarButtonItem = editButtonItem
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        print("viewWillAppear")
        super.viewWillAppear(animated)
        self.tableView.reloadData()
        //1
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        //2
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Moment")
        
        //3
        do {
            moments = try managedContext.fetch(fetchRequest) as! [Moment]
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }

    // MARK: - Table view data source

//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 1
//    }

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return moments.count
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    @IBAction func cancelToMomentsViewController(_ segue: UIStoryboardSegue) {
    }
//    
//    @IBAction func saveMomentDetail(_ segue: UIStoryboardSegue) {
//        if let momentDetailsViewController = segue.source as? MomentViewController {
//            if let moment = momentDetailsViewController.moment {
//                
//                if let selectedIndexPath = tableView.indexPathForSelectedRow {
//                    // Update an existing gesture.
//                    moments[selectedIndexPath.row] = moment
//                    tableView.reloadRows(at: [selectedIndexPath], with: .none)
//                }
//                else {
//                    // Add a new gesture.
//                    let newIndexPath = IndexPath(row: moments.count, section: 0)
//                    
//                    moments.append(moment)
//                    tableView.insertRows(at: [newIndexPath], with: .automatic)
//                    self.tableView.reloadData()
//                }
//            }
//        }
//    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        print(moments)
//        print(indexPath.row)
        let moment = moments[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
//        cell.textLabel?.text = moments[indexPath.row].name
        cell.textLabel?.text = moment.value(forKeyPath: "name") as? String
        let date = moment.value(forKey: "time") as? Date
        let place = moment.value(forKeyPath: "place") as? String
        let placeName = place ?? "None"
        let time = date?.description ?? "None"
        let tb = moment.value(forKey: "timeBool") as? Bool
        let pb = moment.value(forKey: "placeBool") as? Bool
        let timeBool = tb ?? true
        let placeBool = pb ?? true
        if timeBool && placeBool{
                cell.detailTextLabel?.text = placeName + " | " + time
        } else if timeBool{
            cell.detailTextLabel?.text = time
        } else if placeBool{
            cell.detailTextLabel?.text = placeName
        } else {
          cell.detailTextLabel?.text = ""
        }
        return cell
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //Delete from CoreData
            
            guard let appDelegate =
                UIApplication.shared.delegate as? AppDelegate else {
                    return
            }
            
            let managedContext =
                appDelegate.persistentContainer.viewContext
            
            managedContext.delete(moments[indexPath.row] as NSManagedObject)
            
            // Delete the row from the data source
            moments.remove(at: indexPath.row)
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

    
//    @IBAction func saveMoment(_ segue: UIStoryboardSegue) {
//
//        self.moments.append(nameToSave)
//        self.tableView.reloadData()
//        present(alert, animated: true)
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        switch(segue.identifier ?? "") {
        case "AddMoment":
            print ("it is show modal")
            let nav = segue.destination as! UINavigationController
            let momentVC = nav.topViewController as! MomentDetailsViewController
            momentVC.delegate = self
//            momentVC.momentName = place
            
        case "EditMoment":
            guard let momentViewController = segue.destination as? MomentDetailsViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedMomentCell = sender as? MomentTableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }

            guard let indexPath = tableView.indexPath(for: selectedMomentCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedMoment = moments[indexPath.row]
            momentViewController.moment = selectedMoment
            
        default:
            fatalError("Unexpected Segue Identifier; \(segue.identifier)")
            
            
        }
    }


    /*
     Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
         Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

