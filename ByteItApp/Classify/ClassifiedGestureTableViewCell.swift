//
//  ClassifiedGestureTableViewCell.swift
//  GestureiOS
//
//  Created by Tomás Vega on 5/19/19.
//  Copyright © 2019 fluid. All rights reserved.
//

import UIKit
import CoreData

class ClassifiedGestureTableViewCell: UITableViewCell {
    
//    var index: IndexPath?
    var index: NSManagedObjectID?
    let switchView = UISwitch(frame: .zero)
    var automaticSave = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        switchView.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
        accessoryView = switchView
//        accessoryView = switchView
    }
    
    @objc func valueChanged(sender: UISwitch) {
        print("value changed:")
        guard let index = index else { return }
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        do {
            let gesture = try managedContext.existingObject(with: index) as? ClassifiedGesture
            gesture?.correct = sender.isOn as NSNumber
            if sender.isOn {
                gesture?.actualGesture = gesture?.gesture
                self.detailTextLabel?.text = gesture?.getTime()
            } else {
                gesture?.actualGesture = "nil"
                self.detailTextLabel?.text = (gesture?.getTime())! + " | " + (gesture?.actualGesture)!
            }
            
        } catch {
            print("Error loading and editing existing CoreData object")
        }
        if automaticSave {
            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }

//        let gesture = Shared.instance.gestures[index.row]
//        Shared.instance.gestures[index.row] = ClassifiedGesturee(gestureClass: gesture.gestureClass, time: gesture.time, correct: sender.isOn)
        
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}
