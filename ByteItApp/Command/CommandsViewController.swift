//
//  CommandsViewController.swift
//  ByteItApp
//
//  Created by Tomás Vega on 6/3/19.
//  Copyright © 2019 fluid. All rights reserved.
//

import UIKit
import CoreData

class CommandsViewController: UITableViewController {
    
    var gestures = [Gesture]()
    var commands = [Command]()
    var actions = ["play/pause",
                "rewind", "fast-forward",
                "prev", "next",
                "siri",
                "record/stop"]

    override func viewDidLoad() {
        super.viewDidLoad()
        reloadGestures()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return commands.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "commandCell", for: indexPath)
        
        let command = commands[indexPath.row]
        print(command)
        cell.textLabel?.text = command.name
//        cell.switchView.setOn(Bool(truncating: command.active!), animated: false)
        cell.detailTextLabel?.text = command.gesture!.name! + " -> " + command.action!
        
        //        cell.index = indexPath
//        cell.index = command.objectID
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
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
    
    func reloadGestures() {
        gestures = Shared.instance.loadData(entityName: "Gesture") as! [Gesture]
        commands = Shared.instance.loadData(entityName: "Command") as! [Command]
    }
    
    @IBAction func unwindToCommandsViewController(_ segue: UIStoryboardSegue) {
        print("unwind")
    }
    
    @IBAction func saveCommand(_ segue: UIStoryboardSegue) {
        print("saveCommand on Commands")
        
        if let commandVC = segue.source as? CommandViewController {
//            commandVC.saveGesture()
            commandVC.saveCommand()
            reloadGestures()
            tableView.reloadData()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        switch(segue.identifier ?? "") {
        case "AddCommand":
            print("AddCommand")
            
        case "EditCommand":
            guard let commandViewController = segue.destination as? CommandViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedCommandCell = sender as? UITableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedCommandCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedCommand = commands[indexPath.row]
            commandViewController.command = selectedCommand
            
        default:
            fatalError("Unexpected Segue Identifier; \(segue.identifier)")
            
            
        }
    }

}
