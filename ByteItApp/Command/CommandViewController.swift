//
//  CommandViewController.swift
//  ByteItApp
//
//  Created by Tomás Vega on 6/3/19.
//  Copyright © 2019 fluid. All rights reserved.
//

import UIKit
import CoreData

class CommandViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    var command: Command?
    var actions: [String] = []
    var gestures: [Gesture] = [Gesture]()
    @IBOutlet weak var actionPicker: UIPickerView!
    @IBOutlet weak var gesturePicker: UIPickerView!
    @IBOutlet weak var commandNameTxt: UITextField!
    @IBOutlet weak var activeSwitch: UISwitch!
    var isNew = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let commandsVC = Shared.instance.getVC(name: "CommandsViewController") as! CommandsViewController
        actions = commandsVC.actions
        gestures = Shared.instance.loadData(entityName: "Gesture") as! [Gesture]
        
        if let command = command {
            commandNameTxt.text = command.name
            activeSwitch.isOn = Bool(truncating: command.active!)
            isNew = false
        }
        
        actionPicker.delegate = self
        actionPicker.dataSource = self
        gesturePicker.delegate = self
        gesturePicker.dataSource = self
        
        let actionIndex:Int = actions.index(where: { (action) -> Bool in
            action == command?.action
        }) ?? 0
        
        //        let index = gestures.firstIndex(of: classifiedGesture?.gesture)
        actionPicker.selectRow(actionIndex, inComponent: 0, animated: false)
        
        let gestureIndex:Int = gestures.index(where: { (gesture) -> Bool in
            gesture == command?.gesture
        }) ?? 0
        
        gesturePicker.selectRow(gestureIndex, inComponent: 0, animated: false)
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.hideKeyboardWhenTappedAround()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if indexPath.section == 0 {
//            commandNameTxt.becomeFirstResponder()
//        }
//    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 0 {
            return actions.count
        } else {
            return gestures.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 0 {
            return actions[row].capitalized
        } else {
            return gestures[row].name!.capitalized
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //        classifiedGesture?.actualGesture = gestures[row].name
    }
    
    func saveCommand() {
        print("saveCommand")
        let action = actions[actionPicker.selectedRow(inComponent: 0)]
        let gesture = gestures[gesturePicker.selectedRow(inComponent: 0)]
        let active = activeSwitch.isOn
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        let managedContext =
            appDelegate.persistentContainer.viewContext
        if self.isNew {
            print("isNew")
            let entity =
                NSEntityDescription.entity(forEntityName: "Command",
                                           in: managedContext)!
            
            self.command = Command(entity: entity,
                                   insertInto: managedContext)
            self.command?.name = commandNameTxt.text
            self.command?.action = action
            self.command?.gesture = gesture
            self.command?.active = active as NSNumber
            //            self.gesture?.samples = Set(samples)
        } else{
            if let id = self.command?.objectID {
                do {
                    try self.command = managedContext.existingObject(with: id) as? Command
                    self.command?.name = commandNameTxt.text
                    self.command?.action = action
                    self.command?.gesture = gesture
                    self.command?.active = active as NSNumber
                } catch {
                    print("Error loading and editing existing CoreData object")
                }
            }
        }
        
        do {
            print("Saving")
            try managedContext.save()
            print("Saved")
            
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    @IBAction func cancelCommand(_ sender: Any) {
        print("cancelCommand")
        performSegue(withIdentifier: "unwindToClassifiedGesturesViewController", sender: self)
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CommandViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

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

}
