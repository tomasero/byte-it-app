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
    override func awakeFromNib() {
        super.awakeFromNib()
        
//        switchView.setOn(false, animated: false)
        switchView.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
        accessoryView = switchView
    }
    
    @objc func valueChanged(sender: UISwitch) {
        print("ValueChanged")
        print(textLabel?.text ?? "")
        print(detailTextLabel?.text ?? "")
        print((textLabel?.text ?? "") + " switch is " + (sender.isOn ? "ON" : "OFF"))
        guard let index = index else { return }
        
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        do {
            let gesture = try managedContext.existingObject(with: index) as? ClassifiedGesture
            print(sender.isOn)
            print(gesture?.correct ?? -1)
            gesture?.correct = sender.isOn as NSNumber
            print(gesture?.correct ?? -1)
        } catch {
            print("Error loading and editing existing CoreData object")
        }
        do {
            try managedContext.save()
            
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
//        let gesture = Shared.instance.gestures[index.row]
//        Shared.instance.gestures[index.row] = ClassifiedGesturee(gestureClass: gesture.gestureClass, time: gesture.time, correct: sender.isOn)
        
        
        
        print(Shared.instance.gestures)
        
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }

}
