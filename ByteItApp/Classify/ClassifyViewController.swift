//
//  ClassifyViewController.swift
//  GestureiOS
//
//  Created by Tomás Vega on 5/19/19.
//  Copyright © 2019 fluid. All rights reserved.
//

import UIKit
import CoreData

class ClassifyViewController: UITableViewController {
    @IBOutlet weak var classifyBtn: UIBarButtonItem!
    @IBOutlet weak var testBtn: UIBarButtonItem!
    
    var classifiedGestures = [ClassifiedGesture]()
    var gestures = [Gesture]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TableCellID")
//        Shared.instance.gestures = []
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //1
        print("hello")
        reloadGestures()
//        tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
//        return Shared.instance.gestures.count
        return classifiedGestures.count
    }
    
    func getTime(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .short
        let time = formatter.string(from: date)
        return time
    }
    
    func addRandomClassifiedGesture() {
        let gestureClasses = gestures
        if gestureClasses.count == 0 {
            let alert = UIAlertController(title: "No gestures available", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
        let number = Int.random(in: 0 ..< gestureClasses.count)
        let gesture = gestureClasses[number]
        //        let time = getTime(date: Date())
        //        let gestureElem = [gesture, time, "false"]
        //        let gestureElem = ClassifiedGesturee(gestureClass: gesture, time: time, correct: false)
        //        Shared.instance.gestures.insert(gestureElem, at: 0)
        //        print(Shared.instance.gestures)
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        let entity =
            NSEntityDescription.entity(forEntityName: "ClassifiedGesture",
                                       in: managedContext)!
        
        let classifiedGesture = ClassifiedGesture(entity: entity,
                                                  insertInto: managedContext)
        
        classifiedGesture.gesture = gesture.name
        classifiedGesture.time = Date()
        classifiedGesture.correct = true
        
        do {
            try managedContext.save()
            
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
        let newIndexPath = IndexPath(row: 0, section: 0)
        classifiedGestures.insert(classifiedGesture, at: 0)
        tableView.insertRows(at: [newIndexPath], with: .automatic)
    }
    
    func addClassifiedGesture(predictedLabel: String) {
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        let entity =
            NSEntityDescription.entity(forEntityName: "ClassifiedGesture",
                                       in: managedContext)!
        
        let classifiedGesture = ClassifiedGesture(entity: entity,
                               insertInto: managedContext)
        
        classifiedGesture.gesture = predictedLabel
        classifiedGesture.time = Date()
        classifiedGesture.correct = true
        
        do {
            try managedContext.save()
            
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
        let newIndexPath = IndexPath(row: 0, section: 0)
        classifiedGestures.insert(classifiedGesture, at: 0)
        tableView.insertRows(at: [newIndexPath], with: .automatic)
    }
    
    @IBAction func testAddGesture(_ sender: UIBarButtonItem) {
        addRandomClassifiedGesture()
//        self.tableView.reloadData()
    }
    
    
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "gestureCell", for: indexPath) as! ClassifiedGestureTableViewCell
//
//        let gesture = Shared.instance.gestures[indexPath.row]
//        print(gesture)
//        cell.textLabel?.text = gesture.gestureClass
//        cell.detailTextLabel?.text = gesture.time
//        cell.selectionStyle = .none
//        cell.switchView.setOn(gesture.correct, animated: false)
//        cell.index = indexPath
//        return cell
//    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "gestureCell", for: indexPath) as! ClassifiedGestureTableViewCell
        
        let gesture = classifiedGestures[indexPath.row]
        print(gesture)
        cell.textLabel?.text = gesture.gesture
        cell.switchView.setOn(Bool(truncating: gesture.correct!), animated: false)
        if cell.switchView.isOn {
            cell.detailTextLabel?.text = getTime(date: gesture.time!)
        } else {
            let actualGesture = gesture.actualGesture ?? "nil"
            cell.detailTextLabel?.text = getTime(date: gesture.time!) + " | " + actualGesture
        }
        
//        cell.index = indexPath
        cell.index = gesture.objectID
        cell.automaticSave = true
        return cell
    }
    
    var classifying: Bool = false
    @IBAction @objc func toggleClassify(_ sender: AnyObject) {
        print("toggleClassify")
        var btn: UIBarButtonItem
        if classifying {
            btn = getButton(item: UIBarButtonItem.SystemItem.play)
            // stop classifying
        } else {
            let gestureClasses = gestures
            if gestureClasses.count == 0 {
                let alert = UIAlertController(title: "No gestures available", message: "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
                return
            }
            btn = getButton(item: UIBarButtonItem.SystemItem.pause)
            // start classifying continuous
        }
        classifying = !classifying
        navigationItem.rightBarButtonItems?[0] = btn
    }
    
    func getButton(item: UIBarButtonItem.SystemItem) -> UIBarButtonItem {
        return UIBarButtonItem(barButtonSystemItem: item, target: self, action: Selector(("toggleClassify:")))
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        super.prepare(for: segue, sender: sender)
        switch(segue.identifier ?? "") {
        case "GestureFeedback":
            guard let classifiedGestureFeedbackViewController = segue.destination as? ClassifiedGestureFeedbackViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            guard let selectedClassifiedGestureCell = sender as? ClassifiedGestureTableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            guard let indexPath = tableView.indexPath(for: selectedClassifiedGestureCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            let selectedGesture = classifiedGestures[indexPath.row]
            classifiedGestureFeedbackViewController.classifiedGesture = selectedGesture
            
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
            
        }
    }
    
    @IBAction func unwindToClassifiedGesturesViewController(_ segue: UIStoryboardSegue) {
        print("unwind")
    }
    
    @IBAction func saveClassifiedGesture(_ segue: UIStoryboardSegue) {
        print("saveClassifiedGestures")
        
        if let classifiedGestureFeedback = segue.source as? ClassifiedGestureFeedbackViewController {
            classifiedGestureFeedback.saveGesture()
            reloadGestures()
            tableView.reloadData()
        
        }
//        if let gestureDetailsViewController = segue.source as? GestureDetailsViewController {
//            if let gesture = gestureDetailsViewController.gesture {
//
//                if let selectedIndexPath = tableView.indexPathForSelectedRow {
//                    // Update an existing gesture.
//                    gestures[selectedIndexPath.row] = gesture
//                    tableView.reloadRows(at: [selectedIndexPath], with: .none)
//                }
//                else {
//                    // Add a new gesture.
//                    let newIndexPath = IndexPath(row: gestures.count, section: 0)
//
//                    gestures.append(gesture)
//                    tableView.insertRows(at: [newIndexPath], with: .automatic)
//                    self.tableView.reloadData()
//                }
//            }
//        }
    }
    
    func reloadGestures() {
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        let managedContext =
            appDelegate.persistentContainer.viewContext
        var fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "ClassifiedGesture")
        do {
            classifiedGestures = try managedContext.fetch(fetchRequest) as! [ClassifiedGesture]
            classifiedGestures.reverse()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Gesture")
        do {
            gestures = try managedContext.fetch(fetchRequest) as! [Gesture]
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
}
