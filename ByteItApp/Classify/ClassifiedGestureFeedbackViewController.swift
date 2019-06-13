//  ClassifiedGestureFeedbackViewController.swift
//  ByteItApp
//
//  Created by Tomás Vega on 5/23/19.
//  Copyright © 2019 fluid. All rights reserved.
//

import UIKit
import CoreData

class ClassifiedGestureFeedbackViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    @IBOutlet weak var doneBtn: UIBarButtonItem!
    @IBOutlet weak var gesturePicker: UIPickerView!
    @IBOutlet weak var activityPicker: UIPickerView!
    var classifiedGesture: ClassifiedGesture?
    var gestures = [Gesture]()
    let switchView = UISwitch(frame: .zero)
    let activities = Shared.instance.activities
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 0 {
            return gestures.count
        } else {
            return activities.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 0 {
            return gestures[row].name
        } else {
            return activities[row].capitalized
        }
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        classifiedGesture?.actualGesture = gestures[row].name
    }
    
    
    @IBOutlet weak var classifiedGestureCell: UITableViewCell!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let gesture = classifiedGesture {
            classifiedGestureCell.textLabel?.text = gesture.gesture
            classifiedGestureCell.detailTextLabel?.text = gesture.getTime()
            switchView.isOn = Bool(truncating: gesture.correct!)
            if switchView.isOn {
                gesturePicker.isUserInteractionEnabled = false
                gesturePicker.alpha = 0.5
            } else {
                gesturePicker.isUserInteractionEnabled = true
                gesturePicker.alpha = 1
            }
//            classifiedGestureCell.index = gesture.objectID
//            classifiedGestureCell.automaticSave = true
        }
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        let managedContext =
            appDelegate.persistentContainer.viewContext
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Gesture")
        do {
            gestures = try managedContext.fetch(fetchRequest) as! [Gesture]
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        gesturePicker.delegate = self
        gesturePicker.dataSource = self
        activityPicker.delegate = self
        activityPicker.dataSource = self
        
        let gestureIndex:Int = gestures.index(where: { (gesture) -> Bool in
            gesture.name == classifiedGesture?.actualGesture
        }) ?? 0
        
//        let index = gestures.firstIndex(of: classifiedGesture?.gesture)
        gesturePicker.selectRow(gestureIndex, inComponent: 0, animated: false)
        
        let activityIndex:Int = activities.index(where: { (activity) -> Bool in
            activity == classifiedGesture?.activity
        }) ?? 0
        
        activityPicker.selectRow(activityIndex, inComponent: 0, animated: false)
        
        switchView.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
        classifiedGestureCell.accessoryView = switchView
    }
    
    @objc func valueChanged(sender: UISwitch) {
        if sender.isOn {
            gesturePicker.isUserInteractionEnabled = false
            gesturePicker.alpha = 0.5
        } else {
            gesturePicker.isUserInteractionEnabled = true
            gesturePicker.alpha = 1
        }
        
    }
    
    

    // MARK: - Table view data source
    
//    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        // use the row to get the selected row from the picker view
//        // using the row extract the value from your datasource (array[row])
//        classifiedGesture?.actualGesture = gestures[row].name
//    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }
    
    @IBAction func cancelGestureFeedback(_ sender: Any) {
        performSegue(withIdentifier: "unwindToClassifiedGesturesViewController", sender: self)
    }

    func saveGesture() {
        print("saving")
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        let managedContext =
            appDelegate.persistentContainer.viewContext
        do {
            let gesture = try managedContext.existingObject(with: classifiedGesture!.objectID) as? ClassifiedGesture
//            classifiedGesture?.actualGesture = gesture?.name
//            classifiedGesture?.actualGesture = gesturePicker.
            gesture?.correct = switchView.isOn as NSNumber
            if switchView.isOn {
                gesture?.actualGesture = "nil"
            } else {
                gesture?.actualGesture = (gestures[gesturePicker.selectedRow(inComponent: 0)] as Gesture).name
            }
            gesture?.activity = activities[activityPicker.selectedRow(inComponent: 0)]
        } catch {
            print("Error loading and editing existing CoreData object")
        }
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
//        dismiss(animated: true, completion: <#T##(() -> Void)?##(() -> Void)?##() -> Void#>)
//        performSegue(withIdentifier: "saveClassifiedGesture", sender: self)
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
