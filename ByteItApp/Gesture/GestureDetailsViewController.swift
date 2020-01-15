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
//    var gruController = Shared.instance.gruController
    var lgruController = Shared.instance.lGRUController
    var rgruController = Shared.instance.rGRUController
    var sampleDict: [String: [Double]] = [
        "laccX": [Double](),
        "laccY": [Double](),
        "laccZ": [Double](),
        "lgyrX": [Double](),
        "lgyrY": [Double](),
        "lgyrZ": [Double](),
        "raccX": [Double](),
        "raccY": [Double](),
        "raccZ": [Double](),
        "rgyrX": [Double](),
        "rgyrY": [Double](),
        "rgyrZ": [Double]()
    ]
  
    func newSampleDict() -> [String: [Double]] {
        return [
            "laccX": [Double](),
            "laccY": [Double](),
            "laccZ": [Double](),
            "lgyrX": [Double](),
            "lgyrY": [Double](),
            "lgyrZ": [Double](),
            "raccX": [Double](),
            "raccY": [Double](),
            "raccZ": [Double](),
            "rgyrX": [Double](),
            "rgyrY": [Double](),
            "rgyrZ": [Double]()
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
//        gruController.connect()
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
//            self.samples.append(contentsOf: self.dataSource.getData())
            
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
//                gruController.disconnect()
            } else {
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
    
//
//    func saveToFile(fileName: String, stringToWrite: [String]){
//        let fileManager = FileManager.default
//        do {
//            let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create: true)
//            let fileURL = documentDirectory.appendingPathComponent(fileName).appendingPathExtension("txt")
//            print("File Path: \(fileURL.path)")
//
//            let stringToWrite = stringToWrite.joined(separator: "\n")
//            try stringToWrite.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8)
//
//        } catch {
//            print(error)
//        }
//
//    }
    

    @IBAction func addSample(_ sender: Any) {
        if let sensor = detailLabel.text {
            if sensor == "" {
                let sensorsAlertController = UIAlertController(
                    title: "Sensors not selected",
                    message: "Please choose sensors",
                    preferredStyle: UIAlertController.Style.alert)
                sensorsAlertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (action) in
                    sensorsAlertController.dismiss(animated: true, completion: nil)
                }))
                
                self.present(sensorsAlertController, animated: true)//, completion: nil)
                return
            }
        }
        
        let leftConnected = lgruController.getPeripheralState() == "Connected",
            rightConnected = rgruController.getPeripheralState() == "Connected"
        let bothConnected = leftConnected && rightConnected
        
        if sensor == "Left" && !leftConnected
        || sensor == "Right" && !rightConnected
        || sensor == "Both" && !bothConnected {
            let disconnectedAlertController = UIAlertController(
                title: "Disconnected",
                message: "Please connect the appropriate GRUs first",
                preferredStyle: UIAlertController.Style.alert)
            disconnectedAlertController.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { (action) in
                disconnectedAlertController.dismiss(animated: true, completion: nil)
            }))
            
            self.present(disconnectedAlertController, animated: true)//, completion: nil)
            
        }

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
                                        if let name = textField.text {
                                            self.nameToSave = name
                                        } else {
                                            self.nameToSave = "Empty"
                                        }
                                        
                                        
                                        
   
                                        var uuid = UUID().uuidString
                                        let entity =
                                            NSEntityDescription.entity(forEntityName: "Sample",
                                                                       in: self.managedContext!)!
                                        
                                        let sample = Sample(entity: entity,
                                                            insertInto: self.managedContext)
                                        
                                        
                                        sample.laccX = self.sampleDict["laccX"]
                                        sample.laccY = self.sampleDict["laccY"]
                                        sample.laccZ = self.sampleDict["laccZ"]
                                        sample.lgyrX = self.sampleDict["lgyrX"]
                                        sample.lgyrY = self.sampleDict["lgyrY"]
                                        sample.lgyrZ = self.sampleDict["lgyrZ"]
                                        sample.name = self.nameToSave
                                        sample.raccX = self.sampleDict["raccX"]
                                        sample.raccY = self.sampleDict["raccY"]
                                        sample.raccZ = self.sampleDict["raccZ"]
                                        sample.rgyrX = self.sampleDict["rgyrX"]
                                        sample.rgyrY = self.sampleDict["rgyrY"]
                                        sample.rgyrZ = self.sampleDict["rgyrZ"]

//                                        self.samples = self.dataSource.samples
//                                        self.samples.append(sample)
                                        self.dataSource.samples.insert(sample, at: 0)
                                        self.gesture?.samples = Set(self.dataSource.samples)
                                        do {
                                            print("Saving")
                                            try self.managedContext!.save()
                                            print("Saved")
                                            
                                        } catch let error as NSError {
                                            print("Could not save. \(error), \(error.userInfo)")
                                        }
       
//                                        self.dataSource.setData(samples: self.samples)
                                        
                                        self.sampleDict = self.newSampleDict()
//                                        self.sampleTableView.beginUpdates()
//                                        let newIndexPath = IndexPath(row: self.dataSource.samples.count, section: 0)
                                        let newIndexPath = IndexPath(row: 0, section: 0)
                                        self.sampleTableView.insertRows(at: [newIndexPath], with: .automatic)
//                                        self.sampleTableView.endUpdates()
                                    }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        thirdAlertController.addTextField()
        thirdAlertController.textFields?.first?.text = "s\(self.dataSource.samples.count + 1)"
        
        thirdAlertController.addAction(saveAction)
        thirdAlertController.addAction(cancelAction)
        
//        secondAlertController.addAction(UIAlertAction(title: "Stop", style: UIAlertAction.Style.default, handler: { (action) in
//            firstAlertController.dismiss(animated: true, completion: nil)
//            print("STOP")
//            self.timer.invalidate()
//            self.present(thirdAlertController, animated: true, completion: nil)
//        }))
        
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
              self.timer = Timer(fire: Date(), interval: (1.0/20.0),
                                 repeats: true, block: { (timer) in
                                    //let data = self.gruController.getData()
                                    let ldata = self.lgruController.getData()
                                    let rdata = self.rgruController.getData()
                                    
                                    let lacc = ldata[0]
                                    let lgyr = ldata[1]
                                    
                                    let racc = rdata[0]
                                    let rgyr = rdata[1]
                                    
                                    self.sampleDict["laccX"]!.append(Double(lacc.0))
                                    self.sampleDict["laccY"]!.append(Double(lacc.1))
                                    self.sampleDict["laccZ"]!.append(Double(lacc.2))
                                    self.sampleDict["lgyrX"]!.append(Double(lgyr.0))
                                    self.sampleDict["lgyrY"]!.append(Double(lgyr.1))
                                    self.sampleDict["lgyrZ"]!.append(Double(lgyr.2))
                                    self.sampleDict["raccX"]!.append(Double(racc.0))
                                    self.sampleDict["raccY"]!.append(Double(racc.1))
                                    self.sampleDict["raccZ"]!.append(Double(racc.2))
                                    self.sampleDict["rgyrX"]!.append(Double(rgyr.0))
                                    self.sampleDict["rgyrY"]!.append(Double(rgyr.1))
                                    self.sampleDict["rgyrZ"]!.append(Double(rgyr.2))
//                                    self.sensorData.append("\(data)")
                                    
                                    let paragraphStyle = NSMutableParagraphStyle()
                                    paragraphStyle.alignment = .left
                                    let messageText = NSMutableAttributedString(
                                        string: "AccL: \(ldata[0])\nGyrL: \(ldata[1])\nAccR: \(rdata[0])\nGyrR: \(rdata[1])",
                                        attributes: [
                                            NSAttributedString.Key.paragraphStyle: paragraphStyle,
//                                            NSFontAttributeName : UIFont.preferredFont(forTextStyle: .body),
//                                            NSForegroundColorAttributeName : UIColor.black
                                        ]
                                    )
                                    
//                                    secondAlertController.message = "Acc_L: \(ldata[0]), \nGyr_L: \(ldata[1]), \nAcc_R: \(rdata[0]), \nGyr_R: \(rdata[1])"
                                    secondAlertController.setValue(messageText, forKey: "attributedMessage")
                                    
                })
                
              //self.timer.fire()
              // Add the timer to the current run loop.
                RunLoop.current.add(self.timer, forMode: RunLoop.Mode.default)
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
                    print(secondAlertController.isBeingPresented)
                    if (self.timer.isValid) {
                        secondAlertController.dismiss(animated: true, completion: nil)
                        print("STOP")
                        self.timer.invalidate()
                        self.present(thirdAlertController, animated: true, completion: nil)
                    }
                }
            }
            startAccelerometers()
            // Show another alert view
            self.present(secondAlertController, animated: true, completion: nil)
          
            //save the x y z reading to file system
            
            
            

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
    
//    func createExportString() -> String {
//        let name = gesture?.name
//        let sensor = gesture?.sensor
//        let samples = Array(gesture!.samples)
//        var export: String = NSLocalizedString("name,sensor,samples(name, accx, accy, accz, gyrx, gyry, gyrz)\n", comment: "")
//        export += "\(name!),\(sensor!)\n"
//        for sample in samples {
//            export += "\(sample.getString())\n"
//        }
//        print("This is what the app will export: \(export)")
//        return export
//    }
    
    func createExportString() -> String {
//        var export: String = NSLocalizedString("name,sensor,samples(name,laccX,laccY,laccZ,lgyrX,lgyrY,lgyrZ,raccX,raccY,raccZ,rgyrX,rgyrY,rgyrZ)\n", comment: "")
        var export: String = NSLocalizedString("name,sampleNum,accX,accY,accZ,gyrX,gyrY,gyrZ\n", comment: "")
//        if detailLabel.text == "Both" {
//            export = NSLocalizedString("name,sampleNum,accX,laccY,laccZ,lgyrX,lgyrY,lgyrZ,raccX,raccY,raccZ,rgyrX,rgyrY,rgyrZ\n", comment: "")
//        } else {
//            export = NSLocalizedString("name,sampleNum,accX,accY,accZ,gyrX,gyrY,gyrZ\n", comment: "")
//        }
        export += (self.gesture?.getString())!
        print("This is what the app will export: \(export)")
        return export
    }
    
    func getTime(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .short
        let time = formatter.string(from: date)
        return time
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
                                            mail.setSubject("GRU Gesture \(date)")
                                            mail.setMessageBody("Attached", isHTML: false)
                                            mail.setToRecipients([email])
                                            let f = "gesture_\(date).txt"
                                            let data =  self.createExportString().data(using: .utf8)
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
  
//    @IBAction func exportData(_ sender: Any) {
//
//        let emailAlertController = UIAlertController(
//            title: "Export files to your email",
//            message: "Please enter your email below",
//            preferredStyle: UIAlertController.Style.alert)
//
//        let sendEmail = UIAlertAction(title: "Send",
//                                      style: .default) {
//                                        [unowned self] action in
//
//                    guard let textField = emailAlertController.textFields?.first
//                    else { return }
//
//                    let email = textField.text!
//
//                    print("Sending email to", email)
//
//                do {//Check to see the device can send email.
//                     if(try MFMailComposeViewController.canSendMail()) {
//                        print("Can send email.")
//                        let mail = MFMailComposeViewController()
//                        mail.mailComposeDelegate = self
//                        if let gestureName = self.gesture?.name,
//                            let gestureSensor = self.gesture?.sensor{
//
//                        mail.setSubject("Sensor Data for \(gestureName) using \(gestureSensor)")
//                        mail.setMessageBody("Attached", isHTML: false)
//                        }
//                        mail.setToRecipients([email])
//                        for fileName in self.sampleFileNames {
//
//                            let uniqueFileName = self.fileNameToUniqueName[fileName]
//                            let fileManager = FileManager.default
//                            let documentDirectory = try fileManager.url(for: .documentDirectory, in: .userDomainMask, appropriateFor:nil, create: true)
//                            let fileURL = documentDirectory.appendingPathComponent(uniqueFileName!).appendingPathExtension("txt")
//                            print("File Path: \(fileURL.path)")
//                            let fileData = NSData(contentsOfFile: fileURL.path)
//                            print("File data loaded.")
//                            mail.addAttachmentData(fileData! as Data, mimeType: "text/txt", fileName: fileName + ".txt")
//                            }
//                        self.present(mail, animated: true, completion: nil)
//                    }
//                } catch {
//
//                }
//            }
//
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
//        emailAlertController.addTextField()
//        emailAlertController.textFields?.first?.text = "sapkota@mit.edu"
//        emailAlertController.addAction(sendEmail)
//        emailAlertController.addAction(cancelAction)
//        self.present(emailAlertController, animated: true, completion: nil)
//    }

    
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
