//
//  ClassifyViewController.swift
//  GestureiOS
//
//  Created by Tomás Vega on 5/19/19.
//  Copyright © 2019 fluid. All rights reserved.
//

import UIKit
import CoreData
import MessageUI

class ClassifyViewController: UITableViewController, MFMailComposeViewControllerDelegate {
    @IBOutlet weak var classifyBtn: UIBarButtonItem!
    @IBOutlet weak var testBtn: UIBarButtonItem!

    @IBOutlet weak var connLeftBtn: UIBarButtonItem!
    @IBOutlet weak var connRightBtn: UIBarButtonItem!
    var circRightBtn = UIButton()
    var circLeftBtn = UIButton()

    
    let classifier = Shared.instance.classifier
    var classifiedGestures = [ClassifiedGesture]()
    var gestures = [Gesture]()
    var timer = Timer()
    var lGRUController = Shared.instance.lGRUController
    var rGRUController = Shared.instance.rGRUController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.classifier.configure()
        lGRUController.tag = 0
        rGRUController.tag = 1
        setupConnectionInterface()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reloadGestures()
        loadConnectionState()
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
        
        if predictedLabel == "None" {
            return;
        }
        
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
        classifiedGesture.activity = Shared.instance.activities[0]
        
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
//        addRandomClassifiedGesture()
//        self.tableView.reloadData()
        if sender.title == "Test" {
            train()
            classifier.startRecording()
            sender.title = "Testing"
        } else {
            let lbl = classifier.doPrediction()
            addClassifiedGesture(predictedLabel: lbl)
            sender.title = "Test"
        }
    }


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
            self.classifier.stopTrain()
        } else {
            train()
            btn = getButton(item: UIBarButtonItem.SystemItem.pause)
            //now doing real time classification
            self.classifier.runRealTime()
            
        }
        classifying = !classifying
        navigationItem.rightBarButtonItems?[0] = btn
    }
    
    func train() {
        let gestureClasses = gestures
        if gestureClasses.count == 0 {
            let alert = UIAlertController(title: "No gestures available", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
            return
        }
        var n=0
        for gesture in self.gestures {
            let gestureName = gesture.name
            let samples = gesture.samples
            for sample in samples {
                let currentSample = SampleData(number: 0)
                currentSample.accX = sample.accX!.map {Float($0)}
                currentSample.accY = sample.accY!.map {Float($0)}
                currentSample.accZ = sample.accZ!.map {Float($0)}
                currentSample.gyrX = sample.gyrX!.map {Float($0)}
                currentSample.gyrY = sample.gyrY!.map {Float($0)}
                currentSample.gyrZ = sample.gyrZ!.map {Float($0)}
                
                self.classifier.stepTrain(gesture: gestureName!, count: n, sample: currentSample)
                n+=1
            }
        }
        self.classifier.finalTrain()
    }
    
    func getButton(item: UIBarButtonItem.SystemItem) -> UIBarButtonItem {
        return UIBarButtonItem(barButtonSystemItem: item, target: self, action: Selector(("toggleClassify:")))
    }
    

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
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
            

            managedContext.delete(classifiedGestures[indexPath.row] as NSManagedObject)
            classifiedGestures.remove(at: indexPath.row)
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
        classifiedGestures = Shared.instance.loadData(entityName: "ClassifiedGesture") as! [ClassifiedGesture]
        classifiedGestures.reverse()
        gestures = Shared.instance.loadData(entityName: "Gesture") as! [Gesture]
    }
    
    func createExportString() -> String {
        var export: String = NSLocalizedString("time,gesture,correct,actual,activity\n", comment: "")
        for gesture in classifiedGestures {
            export += "\(gesture.getString())\n"
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
                                            mail.setSubject("GRU Classified Gestures \(date)")
                                            mail.setMessageBody("Attached", isHTML: false)
                                            mail.setToRecipients([email])
                                            let f = "classified_\(date).txt"
                                            let data = self.createExportString().data(using: .utf8)
                                            mail.addAttachmentData(data!, mimeType: "text/txt", fileName: f)
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



extension ClassifyViewController {
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
