//
//  ClassifyViewController.swift
//  GestureiOS
//
//  Created by Tomás Vega on 5/19/19.
//  Copyright © 2019 fluid. All rights reserved.
//

import UIKit

class ClassifyViewController: UITableViewController {
    @IBOutlet weak var classifyBtn: UIBarButtonItem!
    @IBOutlet weak var testBtn: UIBarButtonItem!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TableCellID")
        Shared.instance.gestures = []

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
        return Shared.instance.gestures.count
    }
    
    func getTime() -> String {
        let currentDateTime = Date()
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .short
        let time = formatter.string(from: currentDateTime)
        return time
    }
    
    func addClassifiedGesture() {
        let gestureClasses = ["left", "right", "front", "none"]
        let number = Int.random(in: 0 ..< gestureClasses.count)
        let gesture = gestureClasses[number]
        let time = getTime()
//        let gestureElem = [gesture, time, "false"]
        let gestureElem = ClassifiedGesture(gestureClass: gesture, time: time, correct: false)
        Shared.instance.gestures.insert(gestureElem, at: 0)
        print(Shared.instance.gestures)
    }
    
    @IBAction func testAddGesture(_ sender: UIBarButtonItem) {
        addClassifiedGesture()
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "gestureCell", for: indexPath) as! ClassifiedGestureTableViewCell
        
        let gesture = Shared.instance.gestures[indexPath.row]
        print(gesture)
        cell.textLabel?.text = gesture.gestureClass
        cell.detailTextLabel?.text = gesture.time
        cell.selectionStyle = .none
        cell.switchView.setOn(gesture.correct, animated: false)
        cell.index = indexPath
//        theCell.switchView.setOn(theCell.state, animated: false)
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

}
