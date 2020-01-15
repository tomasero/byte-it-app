//
//  GesturesViewController.swift
//  GestureiOS
//
//  Created by fluid on 11/8/18.
//  Copyright © 2018 fluid. All rights reserved.
//

import UIKit
import CoreData
import MessageUI
import os.log

//Need to save and then check why it is crashing

class GesturesViewController: UITableViewController, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var connLeftBtn: UIBarButtonItem!
    @IBOutlet weak var connRightBtn: UIBarButtonItem!
    var circRightBtn = UIButton()
    var circLeftBtn = UIButton()
    
    var gestures = [Gesture]() //SampleData.generateGesturesData()
    var timer = Timer()
    var lGRUController = Shared.instance.lGRUController
    var rGRUController = Shared.instance.rGRUController

    override func viewDidLoad() {
        super.viewDidLoad()
        lGRUController.tag = 0
        rGRUController.tag = 1
        setupConnectionInterface()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
//       navigationItem.leftBarButtonItem = editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadGestures()
        loadConnectionState()
    }
    
    func reloadGestures() {
        gestures = Shared.instance.loadData(entityName: "Gesture") as! [Gesture]
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
            
            // Delete the row from the data source
            for sample in Array(gestures[indexPath.row].samples) {
                managedContext.delete(sample as NSManagedObject)
            }
            
            managedContext.delete(gestures[indexPath.row] as NSManagedObject)
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
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
            
            
        }
    }
    
    @IBAction func unwindToGesturesViewController(_ segue: UIStoryboardSegue) {
    }
    
//    @IBAction func cancelToGesturesViewController(_ segue: UIStoryboardSegue) {
//    }
    
    @IBAction func saveGestureDetail(_ segue: UIStoryboardSegue) {
        if let gestureDetailsViewController = segue.source as? GestureDetailsViewController {
            if let gesture = gestureDetailsViewController.gesture {
                if let selectedIndexPath = tableView.indexPathForSelectedRow {
                    // Update an existing gesture.
                    print("update existing gesture")
                    gestures[selectedIndexPath.row] = gesture
                    tableView.reloadRows(at: [selectedIndexPath], with: .none)
                } else {
                    // Add a new gesture.
                    print("create new gesture")
                    let newIndexPath = IndexPath(row: gestures.count, section: 0)
                    print("new index path")
                    print(gesture)
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
    
    func getTime(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .short
        let time = formatter.string(from: date)
        return time
    }
    
    func createExportString() -> String {
//        var export: String = NSLocalizedString("name,sensor,samples(name,laccX,laccY,laccZ,lgyrX,lgyrY,lgyrZ,raccX,raccY,raccZ,rgyrX,rgyrY,rgyrZ)\n", comment: "")
//        var export: String = NSLocalizedString("name,sensor,sampleNum,accX,accY,accZ,gyrX,gyrY,gyrZ\n", comment: "")
        var export: String = NSLocalizedString("name,sample,accX,accY,accZ,gyrX,gyrY,gyrZ\n", comment: "")
        for gesture in gestures {
            export += "\(gesture.getString())"
        }
        print("This is what the app will export: \(export)")
        return export
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func exportData(_ sender: Any) {
        
        let emailAlertController = UIAlertController(
            title: "Export files to your email",
            message: "Please enter your email below",
            preferredStyle: UIAlertController.Style.alert)
        
        let sendEmail = UIAlertAction(title: "Send",
                                      style: .default) {
                                        [unowned self] action in
                                        guard let textField = emailAlertController.textFields?.first
                                            else {return}
                                        let email = textField.text!
                                        print("Sending email to", email)
                                        if (MFMailComposeViewController.canSendMail()) {
                                            print("Can send email.")
                                            let mail = MFMailComposeViewController()
                                            mail.mailComposeDelegate = self
                                            let date = self.getTime(date: Date()).replacingOccurrences(of: " ", with: "")
                                            mail.setSubject("GRU Gestures \(date)")
                                            mail.setMessageBody("Attached", isHTML: false)
                                            mail.setToRecipients([email])
                                            let f = "gestures_\(date).csv"
                                            let data = self.createExportString().data(using: .utf8)
                                            mail.addAttachmentData(data!, mimeType: "text/csv", fileName: f)
                                            self.present(mail, animated: true, completion: nil)
                                        }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        emailAlertController.addTextField()
        emailAlertController.textFields?.first?.text = "tomasero@mit.edu"
        emailAlertController.addAction(sendEmail)
        emailAlertController.addAction(cancelAction)
        self.present(emailAlertController, animated: true, completion: nil)
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
            cell.detailTextLabel?.text = "\(sensor) | \(gesture.samples.count) samples"//gesture.value(forKeyPath: "sensor") as? String//gesture.sensor
            return cell
        }
        
        //self.tableView.reloadData()
        return cell
    }

    
}

extension GesturesViewController {
    func loadConnectionState() {
        // to fix
//        let state = gruController.getPeripheralState(tag:)
//        peripheralStateChanged(state: state)
        let gruControllers = [lGRUController, rGRUController]
        for (i, gru) in gruControllers.enumerated() {
            let state = gru.getPeripheralState()
            peripheralStateChanged(tag: i, state: state)
        }
    }
    
    func setupConnectionInterface() {
        circLeftBtn.tag = 0
        circLeftBtn.contentEdgeInsets = .zero
        circLeftBtn.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        circLeftBtn.backgroundColor = UIColor.red
        circLeftBtn.layer.cornerRadius = 20
        circLeftBtn.layer.masksToBounds = true
        circLeftBtn.addTarget(self, action: Selector(("toggleConnect:")), for: .touchUpInside)
        connLeftBtn.customView = circLeftBtn
        circRightBtn.tag = 1
        circRightBtn.contentEdgeInsets = .zero
        circRightBtn.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        circRightBtn.backgroundColor = UIColor.red
        circRightBtn.layer.cornerRadius = 20
        circRightBtn.layer.masksToBounds = true
        circRightBtn.addTarget(self, action: Selector(("toggleConnect:")), for: .touchUpInside)
        connRightBtn.customView = circRightBtn
        stopVBatUpdate()
    }
    
    @objc @IBAction func toggleConnect(_ sender: UIBarButtonItem) {
        print("toggleConnect: ", sender.tag)
        let gruController = [lGRUController, rGRUController][sender.tag]
        let connBtn = [connLeftBtn, connRightBtn][sender.tag]
        let state = gruController.getPeripheralState()
        switch state {
        case "Disconnected":
            gruController.connect()
            connBtn!.customView?.backgroundColor = UIColor.lightGray
        default:
            gruController.disconnect()
        }
    }
    
    func peripheralStateChanged(tag: Int, state: String) {
        print("peripheralStateChanged:", tag, state)
        if state == "Connected" {
            connected(tag: tag)
        } else {
            disconnected(tag: tag)
        }
    }
    
    func disconnected(tag: Int) {
        let connBtn = [connLeftBtn, connRightBtn][tag]
        if connBtn!.customView != nil {
            connBtn!.customView!.backgroundColor = UIColor.red
        }
        stopVBatUpdate()
    }
    
    func connected(tag: Int) {
        let connBtn = [connLeftBtn, connRightBtn][tag]
        if connBtn!.customView != nil {
            connBtn!.customView!.backgroundColor = UIColor.green
        }
        startVBatUpdate()
    }
    
    @objc func updateBattery() {
        let gruControllers = [lGRUController, rGRUController]
        let connBtns = [circLeftBtn, circRightBtn]
        for (i, gru) in gruControllers.enumerated() {
//            print(i)
            let state = gru.getPeripheralState()
//            print(state)
            let vBat = gru.getVBat()
            if state == "Connected" {
                connBtns[i].setTitle(String(vBat) + "%", for: UIControl.State.normal)
            }
        }
    }
    
    func startVBatUpdate() {
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(self.updateBattery), userInfo: nil, repeats: true)
    }
    
    func stopVBatUpdate() {
        let gruControllers = [lGRUController, rGRUController]
        let connBtns = [circLeftBtn, circRightBtn]
        var disconnected = 0
        for (i, gru) in gruControllers.enumerated() {
            let state = gru.getPeripheralState()
            if state == "Disconnected" {
                connBtns[i].setTitle("", for: UIControl.State.normal)
                disconnected += 1
            }
        }
        if disconnected == 2 {
            timer.invalidate()
            timer = Timer()
        }
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




