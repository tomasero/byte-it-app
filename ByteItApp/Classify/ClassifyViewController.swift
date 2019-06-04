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
    @IBOutlet weak var connectBtn: UIBarButtonItem!
    @IBOutlet weak var batBtn: UIBarButtonItem!
    
    let classifier = Shared.instance.classifier
    var classifiedGestures = [ClassifiedGesture]()
    var gestures = [Gesture]()
    var gruController = Shared.instance.gruController
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.classifier.configure()
        batBtn.tintColor = UIColor.black
        
        let circBtn = UIButton()
        circBtn.contentEdgeInsets = .zero
        circBtn.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        print(connectBtn.width)
        circBtn.backgroundColor = UIColor.red
        circBtn.layer.cornerRadius = 20
        circBtn.layer.masksToBounds = true
        
        circBtn.addTarget(self, action: Selector(("toggleConnect:")), for: .touchUpInside)
        connectBtn.customView = circBtn
        stopVBatUpdate()
        
//        let vc = UIApplication.shared.keyWindow!.rootViewController as! ViewController
        
//        vc.peripheralStateChanged(state: "Connected")

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //1
        print("hello")
        reloadGestures()
//        tableView.reloadData()
    }
    
    var isConnected = false
    
    @objc @IBAction func toggleConnect(_ sender: UIBarButtonItem) {
        print("toggleConnect")
        if gruController.getPeripheralState() == "Disconnected" {
            gruController.connect()
            // disconnet
            connectBtn.customView?.backgroundColor = UIColor.lightGray
        } else {
            gruController.disconnect()
//            connectBtn.customView?.backgroundColor = UIColor.green
            // connect
        }
//        isConnected = !isConnected
    }
    
    func peripheralStateChanged(state: String) {
        if state == "Connected" {
            connected()
        } else {
            disconnected()
        }
    }
    
    func disconnected() {
        if connectBtn.customView != nil {
            connectBtn.customView!.backgroundColor = UIColor.red
        }
        
//        self.connectBtn.setTitle("Connect", for: .normal)
        stopVBatUpdate()
    }
    
    func connected() {
        if connectBtn.customView != nil {
            connectBtn.customView!.backgroundColor = UIColor.green
        }
//        self.connectBtn.setTitle("Disconnect", for: .normal)
        startVBatUpdate()
    }
    
    @objc func updateBattery() {
        let vBat = gruController.getVBat()
        batBtn.title = String(vBat) + "%"
    }
    
    func startVBatUpdate() {
        timer.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(self.updateBattery), userInfo: nil, repeats: true)
    }
    
    func stopVBatUpdate() {
        timer.invalidate()
        timer = Timer()
        batBtn.title = "0%"
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
        addRandomClassifiedGesture()
//        self.tableView.reloadData()
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
            let gestureClasses = gestures
            if gestureClasses.count == 0 {
                let alert = UIAlertController(title: "No gestures available", message: "", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
                return
            }
            btn = getButton(item: UIBarButtonItem.SystemItem.pause)
            // training...
            var n=0
            for gesture in self.gestures {
                let gestureName = gesture.name
                var samples = gesture.samples
                
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
            //now doing real time classification
            self.classifier.runRealTime()
            
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
        classifiedGestures = Shared.instance.loadData(entityName: "ClassifiedGesture") as! [ClassifiedGesture]
        classifiedGestures.reverse()
        gestures = Shared.instance.loadData(entityName: "Gesture") as! [Gesture]
    }
}
