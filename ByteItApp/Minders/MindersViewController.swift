//
//  MindersViewController.swift
//  ByteItApp
//
//  Created by Shardul Sapkota on 6/3/19.
//  Copyright © 2019 fluid. All rights reserved.
//

import UIKit
import CoreData
import os.log


protocol isAbleToReceiveMindersForMindersVC {
    func pass(minder: Minder)
}


class MindersViewController: UITableViewController, isAbleToReceiveMindersForMindersVC {
    
    var delegate: isAbleToReceiveMindersForMindersVC?
    var minders: [Minder] = []
    
    func pass(minder: Minder) {
    
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            // Update an existing gesture.
            minders[selectedIndexPath.row] = minder
            tableView.reloadRows(at: [selectedIndexPath], with: .none)
        } else {
            // Add a new gesture.
            let newIndexPath = IndexPath(row: minders.count, section: 0)
            
            minders.append(minder)
            tableView.insertRows(at: [newIndexPath], with: .automatic)
            self.tableView.reloadData()
        }
    }
    
    
   

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func cancelToMindersViewController(_ segue: UIStoryboardSegue) {
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
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
            NSFetchRequest<NSManagedObject>(entityName: "Minder")
        
        //3
        do {
            minders = try managedContext.fetch(fetchRequest) as! [Minder]
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return minders.count
    }
    
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        // #warning Incomplete implementation, return the number of sections
//        return 1
//    }
    
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //        print(moments)
//        print(indexPath.row)
        let minder = minders[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = minder.moment.name
        cell.detailTextLabel?.text = minder.minderText

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
            
            managedContext.delete(minders[indexPath.row] as NSManagedObject)
            
            // Delete the row from the data source
            minders.remove(at: indexPath.row)
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
    
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
            
        case "AddMinder":
            os_log("Adding a new gesture.", log: OSLog.default, type: .debug)
            let nav = segue.destination as! UINavigationController
            let minderVC = nav.topViewController as! MinderDetailsViewController
            minderVC.delegate = self
            
        case "EditMinder":
            print("Editing a new minder")
            guard let minderDetailsViewController = segue.destination as? MinderDetailsViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedMinderCell = sender as? MinderTableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedMinderCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedMinder = minders[indexPath.row]
            minderDetailsViewController.minder = selectedMinder
            
        default:
            fatalError("Unexpected Segue Identifier; \(segue.identifier)")
            
            
        }
    }
    



}



/*
 
 
 //
 //  GesturesViewController.swift
 //  GestureiOS
 //
 //  Created by fluid on 11/8/18.
 //  Copyright © 2018 fluid. All rights reserved.
 //
 
 import UIKit
 import CoreData
 import os.log
 
 //Need to save and then check why it is crashing
 
 class GesturesViewController: UITableViewController {
 
 var gestures = [Gesture]() //SampleData.generateGesturesData()
 
 override func viewDidLoad() {
 super.viewDidLoad()
 
 // Uncomment the following line to preserve selection between presentations
 // self.clearsSelectionOnViewWillAppear = false
 
 // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
 navigationItem.leftBarButtonItem = editButtonItem
 }
 
 override func viewWillAppear(_ animated: Bool) {
 super.viewWillAppear(animated)
 
 //1
 guard let appDelegate =
 UIApplication.shared.delegate as? AppDelegate else {
 return
 }
 
 let managedContext =
 appDelegate.persistentContainer.viewContext
 
 //2
 let fetchRequest =
 NSFetchRequest<NSManagedObject>(entityName: "Gesture")
 
 //3
 do {
 gestures = try managedContext.fetch(fetchRequest) as! [Gesture]
 } catch let error as NSError {
 print("Could not fetch. \(error), \(error.userInfo)")
 }
 }
 
 // MARK: - Table view data source
 
 override func didReceiveMemoryWarning() {
 super.didReceiveMemoryWarning()
 // Dispose of any resources that can be recreated.
 }
 
 //    override func tableView(_ tableView: UITableView,
 //                            commit editingStyle: UITableViewCell.EditingStyle,
 //                            forRowAt indexPath: IndexPath) {
 //       gestures.remove(at: indexPath.row)
 //
 //        let indexPaths = [indexPath]
 //        tableView.deleteRows(at: indexPaths, with: .automatic)
 //    }
 
 
 override func numberOfSections(in tableView: UITableView) -> Int {
 // #warning Incomplete implementation, return the number of sections
 return 1
 }
 
 
 // Override to support conditional editing of the table view.
 override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
 // Return false if you do not want the specified item to be editable.
 return true
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
 
 managedContext.delete(gestures[indexPath.row] as NSManagedObject)
 
 // Delete the row from the data source
 gestures.remove(at: indexPath.row)
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
 
 
 /*  // MARK: - Navigation
 func prepare(for segue: UIStoryboardSegue, sender: Any?, cellForRowAt indexPath: IndexPath)  {
 if segue.identifier == "EditGesture",
 let gestureDetailsViewController = segue.destination as? GestureDetailsViewController {
 gestureDetailsViewController.gesture = Gesture(name: gestures[indexPath.row].name, sensor: gestures[indexPath.row].sensor)
 //gestureDetailsViewController.` = gestures[indexPath.row].name
 //gestureDetailsViewController.sensor = "gestures[indexPath.row].sensor"
 }
 }
 */
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 
 super.prepare(for: segue, sender: sender)
 
 switch(segue.identifier ?? "") {
 
 case "AddGesture":
 os_log("Adding a new gesture.", log: OSLog.default, type: .debug)
 
 case "EditGesture":
 guard let gestureDetailsViewController = segue.destination as? GestureDetailsViewController else {
 fatalError("Unexpected destination: \(segue.destination)")
 }
 
 guard let selectedGestureCell = sender as? GestureTableViewCell else {
 fatalError("Unexpected sender: \(String(describing: sender))")
 }
 
 guard let indexPath = tableView.indexPath(for: selectedGestureCell) else {
 fatalError("The selected cell is not being displayed by the table")
 }
 
 let selectedGesture = gestures[indexPath.row]
 gestureDetailsViewController.gesture = selectedGesture
 
 default:
 fatalError("Unexpected Segue Identifier; \(segue.identifier)")
 
 
 }
 }
 
 @IBAction func cancelToGesturesViewController(_ segue: UIStoryboardSegue) {
 }
 
 @IBAction func saveGestureDetail(_ segue: UIStoryboardSegue) {
 if let gestureDetailsViewController = segue.source as? GestureDetailsViewController {
 if let gesture = gestureDetailsViewController.gesture {
 
 if let selectedIndexPath = tableView.indexPathForSelectedRow {
 // Update an existing gesture.
 gestures[selectedIndexPath.row] = gesture
 tableView.reloadRows(at: [selectedIndexPath], with: .none)
 }
 else {
 // Add a new gesture.
 let newIndexPath = IndexPath(row: gestures.count, section: 0)
 
 gestures.append(gesture)
 tableView.insertRows(at: [newIndexPath], with: .automatic)
 self.tableView.reloadData()
 }
 }
 }
 
 //
 //        // add the new player to the players array
 //        gestures.append(gesture)
 //
 //        // update the tableView
 //        let indexPath = IndexPath(row: gestures.count - 1, section: 0)
 //        tableView.insertRows(at: [indexPath], with: .automatic)
 //    }
 
 }
 }
 
 
 
 extension GesturesViewController{
 override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
 // #warning Incomplete implementation, return the number of rows
 return gestures.count
 }
 
 
 override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
 
 let cellIdentifier = "GestureCell"
 
 guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? GestureTableViewCell  else {
 fatalError("The dequeued cell is not an instance of GestureTableViewCell.")
 }
 
 // Configure the cell...
 
 let gesture = gestures[indexPath.row]
 
 if let name = gesture.name,
 let sensor = gesture.sensor{
 cell.textLabel?.text = name //gesture.value(forKeyPath: "name") as? String
 cell.detailTextLabel?.text = sensor//gesture.value(forKeyPath: "sensor") as? String//gesture.sensor
 return cell
 }
 
 //self.tableView.reloadData()
 return cell
 }
 
 
 }
 
 
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
 
 
 // MARK: - Navigation
 
 
 
 

 
 
 */
