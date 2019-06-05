//
//  GestureDetailsViewController.swift
//  GestureiOS
//
//  Created by shardul sapkota on 11/8/18.
//  Copyright © 2018 fluid. All rights reserved.
//

import UIKit
import os.log
import CoreMotion
import CoreData
import MessageUI


class GestureDetailsViewController: UITableViewController, UITextFieldDelegate, MFMailComposeViewControllerDelegate {
    
    var gesture: Gesture?
    let motion = CMMotionManager()
    var timer: Timer = Timer()
    var isNew = true
    var sensorData = [String]()
    var sampleFileNames: [String] = ["TestData"]//[String]()
    var nameToSave: String = ""
    var samples: [Sample] = [Sample]()
    var fileNameCount: [String: Int] = [:]
    var fileNameToUniqueName: [String: String] = [:]
    var gruController = Shared.instance.gruController
    var sampleDict: [String: [Double]] = [
        "accX": [Double](),
        "accY": [Double](),
        "accZ": [Double](),
        "gyrX": [Double](),
        "gyrY": [Double](),
        "gyrZ": [Double]()
    ]
  
    func newSampleDict() -> [String: [Double]] {
        return [
            "accX": [Double](),
            "accY": [Double](),
            "accZ": [Double](),
            "gyrX": [Double](),
            "gyrY": [Double](),
            "gyrZ": [Double]()
        ]
    }
    
    var sensor: String = "Accelerometer" {
        didSet {
            detailLabel.text = sensor
        }
    }
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var saveGesture: UIBarButtonItem!
    @IBOutlet weak var sampleTableView: UITableView!
    
//    var dataSource = DynamicDataSource()
    var dataSource = NewDynamicDataSource()
    
    var appDelegate: AppDelegate?
    var managedContext: NSManagedObjectContext?
    
    override func viewDidLoad() {
        
        appDelegate = UIApplication.shared.delegate as? AppDelegate
        managedContext =
            appDelegate!.persistentContainer.viewContext
        
        super.viewDidLoad()
        gruController.connect()
        sampleTableView.dataSource = dataSource
        sampleTableView.delegate = dataSource
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        nameTextField.delegate = self
        if let gesture = gesture {
            navigationItem.title = gesture.name
            nameTextField.text = gesture.name
            detailLabel.text = gesture.sensor
            self.sampleFileNames = gesture.fileName ?? []
            self.fileNameCount = gesture.uniqueFileCount ?? [:]
            self.fileNameToUniqueName = gesture.uniqueFileName ?? [:]
            self.dataSource.setData(samples: Array(gesture.samples))
            self.samples.append(contentsOf: self.dataSource.getData())
            
//            self.dataSource.setData(sampleFileNames: self.sampleFileNames)
//            self.dataSource.setCount(fileDict: self.fileNameCount)
//            self.dataSource.setName(fileNameDict: self.fileNameToUniqueName)
            self.isNew = false
        }
        
        
        updateSaveButtonState()
        
        self.hideKeyboardWhenTappedAround()
        
    }
    
    
    deinit {
        print("deinit GestureDetailsViewController")
    }

    var saved = false
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)  {
        if segue.identifier == "PickSensor",
            let sensorPickerViewController = segue.destination as? SensorPickerViewController {
            sensorPickerViewController.selectedSensor = detailLabel.text //sensor
        }
        
        
        
        // Configure the destination view controller only when the save button is pressed.
        guard let button = sender as? UIBarButtonItem, button === saveGesture else {
            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
        super.prepare(for: segue, sender: sender)

    }

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        print("should perform segue")
        print(identifier)
        if identifier == "PickSensor" {
            return true
        } else if identifier == "SaveGestureDetail" {
            let gestureName = nameTextField.text ?? ""
            
            saved = save(gestureName: gestureName, gestureSensor: detailLabel.text ?? "", samples: self.dataSource.getData())
            if saved {
                print("saved")
                gruController.disconnect()
                
            } else {
                print("boooo")
                let errorAlertController = UIAlertController(
                    title: "Error",
                    message: "Gesture must have at least one sample",
                    preferredStyle: UIAlertController.Style.alert)
                
                errorAlertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (action) in
                    errorAlertController.dismiss(animated: true, completion: nil)
                    print("CANCEL")
                }))
                
                self.present(errorAlertController, animated: true)//, completion: nil)
            }
            return saved
        } else {
            return true
        }
    }

    func save(gestureName: String, gestureSensor: String, samples: [Sample]) -> Bool {
        print("save")
        if samples.count == 0 {
            return false
        }
        if self.isNew{
            print("isNew")
            let entity =
                NSEntityDescription.entity(forEntityName: "Gesture",
                                           in: managedContext!)!
            
            self.gesture = Gesture(entity: entity,
                                   insertInto: managedContext)
            
            self.gesture?.name = gestureName
            self.gesture?.sensor = gestureSensor
            self.gesture?.samples = Set(samples)
        } else{
            if let id = self.gesture?.objectID {
                do {
                    try self.gesture = managedContext!.existingObject(with: id) as? Gesture
                    self.gesture?.name = gestureName
                    self.gesture?.sensor = gestureSensor
                    self.gesture?.samples = Set(samples)
//                    self.gesture?.samples = samples
                } catch {
                    print("Error loading and editing existing CoreData object")
                }
            }
        }
        
        do {
            print("Saving")
            try managedContext!.save()
            print("Saved")
            
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        return true
    }
    
//    func save(gestureName: String, gestureSensor: String, gestureFiles: [String], gestureFileCount: [String: Int], gestureUniqueFileName: [String: String]){
//        // 1
//        guard let appDelegate =
//            UIApplication.shared.delegate as? AppDelegate else {
//                return
//        }
//
//        let managedContext =
//            appDelegate.persistentContainer.viewContext
//
//        if self.isNew{
//        // 2
//            let entity =
//                NSEntityDescription.entity(forEntityName: "Gesture",
//                                           in: managedContext)!
//
//            self.gesture = Gesture(entity: entity,
//                                   insertInto: managedContext)
//
//            self.gesture?.name = gestureName
//            self.gesture?.sensor = gestureSensor
//            self.gesture?.fileName = gestureFiles
//            self.gesture?.uniqueFileCount = gestureFileCount
//            self.gesture?.uniqueFileName = gestureUniqueFileName
////            self.gesture?.samples =
//        } else{
//            if let id = self.gesture?.objectID {
//                do {
//                    try self.gesture = managedContext.existingObject(with: id) as? Gesture
//                        self.gesture?.name = gestureName
//                        self.gesture?.sensor = gestureSensor
//                        self.gesture?.fileName = gestureFiles
//                        self.gesture?.uniqueFileCount = gestureFileCount
//                        self.gesture?.uniqueFileName = gestureUniqueFileName
//                } catch {
//                    print("Error loading and editing existing CoreData object")
//                }
//            }
//        }
//
//        do {
//            try managedContext.save()
//
//        } catch let error as NSError {
//            print("Could not save. \(error), \(error.userInfo)")
//        }
//    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // Disable the Save button while editing.
        saveGesture.isEnabled = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateSaveButtonState()
        navigationItem.title = textField.text
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    
    func saveToFile(fileName: String, stringToWrite: [String]){
        let fileManager = FileManager.default
        do {
            let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create: true)
            let fileURL = documentDirectory.appendingPathComponent(fileName).appendingPathExtension("txt")
            print("File Path: \(fileURL.path)")
            
            let stringToWrite = stringToWrite.joined(separator: "\n")
            try stringToWrite.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8)
            
        } catch {
            print(error)
        }
        
    }
    

    @IBAction func addSample(_ sender: Any) {

        let firstAlertController = UIAlertController(
            title: "Add a Sample",
            message: "Start sampling your data below",
            preferredStyle: UIAlertController.Style.alert)
        
        let secondAlertController = UIAlertController(
            title: "Recording Sample",
            message: "Recording.... ",
            preferredStyle: UIAlertController.Style.alert)
        
        let thirdAlertController = UIAlertController(
            title: "Save",
            message: "Enter the recording label",
            preferredStyle: UIAlertController.Style.alert)
        
        let saveAction = UIAlertAction(title: "Save",
                                       style: .default) {
                                        [unowned self] action in
                                        
                                        guard let textField = thirdAlertController.textFields?.first
                                        else {
                                                return
                                            }
                                        self.nameToSave = textField.text as! String
                                        
//                                        self.sampleFileNames = self.dataSource.getData()
//                                        self.fileNameCount = self.dataSource.getCount()
//                                        self.fileNameToUniqueName = self.dataSource.getName()
                                        let newIndexPath = IndexPath(row: self.dataSource.samples.count, section: 0)
                                        
                                        //make filename unique
                                        
//                                        if self.sampleFileNames.contains(self.nameToSave){
//                                            if self.fileNameCount[self.nameToSave] == nil {
//                                                self.fileNameCount[self.nameToSave] = 1
//                                            } else {
//                                                if let count = self.fileNameCount[self.nameToSave]
//                                                {
//                                                    self.fileNameCount[self.nameToSave] = count + 1
//                                                }
//                                            }
//                                            if let count = self.fileNameCount[self.nameToSave]{
//                                                self.nameToSave = self.nameToSave + "-\(count)"
//                                            }
//                                        }
                                        
                                        // convert fileName to unique fileName using UUID
                                        var uuid = UUID().uuidString
//                                        var uniqueNameToSave = self.nameToSave + "_\(uuid)"
//                                        self.fileNameToUniqueName[self.nameToSave] = uniqueNameToSave
                                        
//                                        self.sampleFileNames.append(self.nameToSave)
                                        
//                                        self.dataSource.setData(sampleFileNames: self.sampleFileNames)
                                        


                                        // 2
                                        let entity =
                                            NSEntityDescription.entity(forEntityName: "Sample",
                                                                       in: self.managedContext!)!
                                        
                                        let sample = Sample(entity: entity,
                                                            insertInto: self.managedContext)
                                        
                                        
                                        sample.accX = self.sampleDict["accX"]
                                        sample.accY = self.sampleDict["accY"]
                                        sample.accZ = self.sampleDict["accZ"]
                                        sample.gyrX = self.sampleDict["gyrX"]
                                        sample.gyrY = self.sampleDict["gyrX"]
                                        sample.gyrZ = self.sampleDict["gyrX"]
                                        sample.name = self.nameToSave
//                                        print(self.sampleDict)
//                                        print(self.samples)
                                        self.samples.append(sample)
//                                        print(self.samples)
                                        self.dataSource.setData(samples: self.samples)
//                                        print(self.sampleDict)
//                                        print("print getData")
//                                        print(self.samples.first?.accX)
//                                        self.dataSource.setCount(fileDict: self.fileNameCount)
//                                        self.dataSource.setName(fileNameDict: self.fileNameToUniqueName)
//                                        print("name of file", self.nameToSave)
                                        
//                                        self.saveToFile(fileName: self.fileNameToUniqueName[self.nameToSave]!, stringToWrite: self.sensorData)
//                                        self.sensorData = []
                                        self.sampleDict = self.newSampleDict()
                                        
                                        self.sampleTableView.beginUpdates()
                                        self.sampleTableView.insertRows(at: [newIndexPath], with: .automatic)
                                        self.sampleTableView.endUpdates()
                                    }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        thirdAlertController.addTextField()
        
        thirdAlertController.addAction(saveAction)
        thirdAlertController.addAction(cancelAction)
        

        secondAlertController.addAction(UIAlertAction(title: "Stop", style: UIAlertAction.Style.default, handler: { (action) in
            firstAlertController.dismiss(animated: true, completion: nil)
                print("STOP")
                self.timer.invalidate()
                self.present(thirdAlertController, animated: true, completion: nil)
        }))
        
        secondAlertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: { (action) in
            firstAlertController.dismiss(animated: true, completion: nil)
            print("CANCEL")
            self.timer.invalidate()
            self.sampleDict = self.newSampleDict()
        }))

        
        // work on cancelling accelerometer updates ...
        
        
        firstAlertController.addAction(UIAlertAction(title: "Start", style: UIAlertAction.Style.default, handler: { (action) in
            firstAlertController.dismiss(animated: true, completion: nil)
            print ("START")
            
            func startAccelerometers(){
              self.sampleDict = self.newSampleDict()
              self.timer = Timer(fire: Date(), interval: (1.0/60.0),
                                 repeats: true, block: { (timer) in
                                    let data = self.gruController.getData()
                                    let acc = data[0]
                                    let gyr = data[1]
                                    self.sampleDict["accX"]!.append(Double(acc.0))
                                    self.sampleDict["accY"]!.append(Double(acc.1))
                                    self.sampleDict["accZ"]!.append(Double(acc.2))
                                    self.sampleDict["gyrX"]!.append(Double(gyr.0))
                                    self.sampleDict["gyrY"]!.append(Double(gyr.1))
                                    self.sampleDict["gyrZ"]!.append(Double(gyr.2))
//                                    self.sensorData.append("\(data)")
                                    secondAlertController.message = "Recording values: Acc: \(data[0]), Gyr: \(data[1]))"
              })
                
              //self.timer.fire()
              // Add the timer to the current run loop.
              RunLoop.current.add(self.timer, forMode: RunLoop.Mode.default)
            }
            startAccelerometers()
          
            //save the x y z reading to file system
            
            // Show another alert view
            self.present(secondAlertController, animated: true, completion: nil)
        }))
        
        firstAlertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: { (action) in
            firstAlertController.dismiss(animated: true, completion: nil)
            print("CANCEL")
        }))

        self.present(firstAlertController, animated: true)//, completion: nil)
    }
    
    @IBAction func unwindWithSelectedSensor(segue: UIStoryboardSegue) {
        if let sensorPickerViewController = segue.source as? SensorPickerViewController,
            let selectedSensor = sensorPickerViewController.selectedSensor {
            print("herererere")
            sensor = selectedSensor
            print(sensor)
        }
    }
    
    
    private func updateSaveButtonState() {
        // Disable the Save button if the text field is empty.
        let text = nameTextField.text ?? ""
        saveGesture.isEnabled = !text.isEmpty
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
                                
                                        
                    let email = textField.text as! String
                                        
                    print("Sending email to", email)
                                        
                do {//Check to see the device can send email.
                     if(try MFMailComposeViewController.canSendMail()) {
                        print("Can send email.")
                        let mail = MFMailComposeViewController()
                        mail.mailComposeDelegate = self
                        if let gestureName = self.gesture?.name,
                            let gestureSensor = self.gesture?.sensor{
                        
                        mail.setSubject("Sensor Data for \(gestureName) using \(gestureSensor)")
                        mail.setMessageBody("Attached", isHTML: false)
                        }
                        mail.setToRecipients([email])
                        for fileName in self.sampleFileNames {
                            
                            let uniqueFileName = self.fileNameToUniqueName[fileName]
                            let fileManager = FileManager.default
                            let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create: true)
                            let fileURL = documentDirectory.appendingPathComponent(uniqueFileName!).appendingPathExtension("txt")
                            print("File Path: \(fileURL.path)")
                            let fileData = NSData(contentsOfFile: fileURL.path)
                            print("File data loaded.")
                            mail.addAttachmentData(fileData! as Data, mimeType: "text/txt", fileName: fileName + ".txt")
                            }
                        self.present(mail, animated: true, completion: nil)
                    }
                } catch {
                    
                }
            }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        emailAlertController.addTextField()
        emailAlertController.textFields?.first?.text = "sapkota@mit.edu"
        emailAlertController.addAction(sendEmail)
        emailAlertController.addAction(cancelAction)
        self.present(emailAlertController, animated: true, completion: nil)
    }

    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            self.dismiss(animated: true, completion: nil)
    }
    

}



// MARK: - UITableViewDelegate
extension GestureDetailsViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            nameTextField.becomeFirstResponder()
        }
    }
}


// Put this piece of code anywhere you like
extension GestureDetailsViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(GestureDetailsViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}


extension GestureDetailsViewController{
    @IBAction func cancelGestureEdit(_ sender: Any) {
        
        performSegue(withIdentifier: "unwindToGesturesViewController", sender: self)
    }
}
