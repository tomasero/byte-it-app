//
//  MomentPickerViewController.swift
//  ByteItApp
//
//  Created by Shardul Sapkota on 6/3/19.
//  Copyright © 2019 fluid. All rights reserved.
//

import UIKit
import CoreData
import os.log


protocol isAbleToReceiveMinder {
    func pass(moment: Moment)
}

class MomentPickerViewController: UITableViewController, isAbleToReceiveMoment {
    
    var delegate: isAbleToReceiveMinder?
    var moments = [Moment]()
    
    func pass(moment: Moment) {
        print("Moments of success")
        print(moment)
        //        moments.append(moment)s
        
        print("moments")
        print(moments)
        
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            // Update an existing gesture.
            moments[selectedIndexPath.row] = moment
            tableView.reloadRows(at: [selectedIndexPath], with: .none)
        } else {
            // Add a new gesture.
            let newIndexPath = IndexPath(row: moments.count, section: 0)
            
            moments.append(moment)
            tableView.insertRows(at: [newIndexPath], with: .automatic)
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    
    var selectedMomentIndex: Int?
    
    var selectedMoment: Moment? {
        didSet {
            if let selectedMoment = selectedMoment,
                let index = moments.index(of: selectedMoment) {
                selectedMomentIndex = index
            }
        }
    }
    
    override func tableView(_ tableView: UITableView,
                            numberOfRowsInSection section: Int) -> Int {
        return moments.count
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard segue.identifier == "SaveSelectedMoment",
            let cell = sender as? UITableViewCell,
            let indexPath = tableView.indexPath(for: cell) else {
                return
        }
        
        let index = indexPath.row
        selectedMoment = moments[index]
    }
    
    override func tableView(_ tableView: UITableView,
                            cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let moment = moments[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "MinderCell", for: indexPath)
        cell.textLabel?.text = moment.value(forKeyPath: "name") as? String
        let date = moment.value(forKey: "time") as? Date
        let place = moment.value(forKeyPath: "place") as? String
        let placeName = place ?? "None"
        let time = date?.description ?? "None"
        cell.detailTextLabel?.text = placeName + " | " + time
        return cell
        if indexPath.row == selectedMomentIndex {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
        // 1
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }

        let managedContext =
            appDelegate.persistentContainer.viewContext

        //2
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Moment")

        //3
        do {
            moments = try managedContext.fetch(fetchRequest) as! [Moment]
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


// MARK: - UITableViewDelegate
extension MomentPickerViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Other row is selected - need to deselect it
        if let index = selectedMomentIndex {
            let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0))
            cell?.accessoryType = .none
        }
        
        selectedMoment = moments[indexPath.row]
        
        // update the checkmark for the current row
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .checkmark
    }
}
