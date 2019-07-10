//
//  MinderDetailsViewController.swift
//  ByteItApp
//
//  Created by Shardul Sapkota on 6/3/19.
//  Copyright © 2019 fluid. All rights reserved.
//

import UIKit
import CoreData


class MinderDetailsViewController: UITableViewController, UITextViewDelegate {
    
    
    @IBOutlet weak var toggleMinder: UISwitch!
    @IBOutlet weak var momentName: UILabel!
    @IBOutlet weak var minderTextView: UITextView!
    @IBOutlet weak var doneGesture: UIBarButtonItem!
    
    var minder: Minder?
    
    var minderOn: Bool = false
//    var momentCoreData: String?
    var minderText: String?
    var flag = true
    var delegate: isAbleToReceiveMindersForMindersVC?
    
    
    var moment: String = ""{
        didSet{
            momentName.text = moment
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        minderTextView.delegate = self
        if let minder = minder{
            print("Inside existing minder")
            self.flag = false
            self.toggleMinder.isOn = minder.minderOn as! Bool
            self.momentName.text = minder.moment as! String
            self.minderTextView.text = minder.minderText as! String
        }
        
        self.hideKeyboardWhenTappedAround()
        
        updateSaveButtonState()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func unwindWithSelectedMoment(segue: UIStoryboardSegue) {
        if let momentPickerViewController = segue.source as? MomentPickerViewController,
            let selectedMoment = momentPickerViewController.selectedMoment {
//            print("herererere")
            moment = selectedMoment.name!
            print(moment)
        }
    }
    
    
    @IBAction func didToggleMinderSwitch(_ sender: UISwitch) {
        let id: String = sender.restorationIdentifier!
        let state: Bool = sender.isOn
        minderOn = state
//        switch id {
//        case "switchMinder":
//            minderOn = state
//            break
//        default:
//            break
//        }
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    
    @IBAction func doneAddMinders(_ sender: Any) {
        print("doneAddMoment")
        guard let momentNameText = momentName.text else{
            return
        }
        
        minderText = minderTextView.text
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        if self.flag{
            let entity = NSEntityDescription.entity(forEntityName: "Minder", in: managedContext)!
            self.minder = Minder(entity: entity, insertInto: managedContext)
            self.minder?.setValue(momentNameText, forKey:"moment")
            self.minder?.setValue(minderText, forKey:"minderText")
            self.minder?.setValue(minderOn, forKey: "minderOn")
        } else {
            if let id = self.minder?.objectID{
                do{
                    try self.minder = managedContext.existingObject(with: id) as? Minder
                    self.minder?.setValue(momentName.text, forKey:"moment")
                    self.minder?.setValue(minderText, forKey:"minderText")
                    self.minder?.setValue(minderOn, forKey: "minderOn")
                    self.delegate?.pass(minder:self.minder as! Minder)
                }catch{
                    print("Error loading and editing existing CoreData object")
                }
            }
        }
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
        self.delegate?.pass(minder:self.minder as! Minder)
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)

    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        // Disable the Save button while editing.
        doneGesture.isEnabled = false
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        updateSaveButtonState()
        navigationItem.title = momentName.text
    }
    
    func textViewShouldReturn(_ textView: UITextView) -> Bool {
        // Hide the keyboard.
        textView.resignFirstResponder()
        return true
    }
    
    
    private func updateSaveButtonState() {
        // Disable the Save button if the text field is empty.
        let text = minderTextView.text ?? ""
        doneGesture.isEnabled = !text.isEmpty
    }

}


// Put this piece of code anywhere you like
extension MinderDetailsViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(GestureDetailsViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
