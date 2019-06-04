//
//  MinderDetailsViewController.swift
//  ByteItApp
//
//  Created by Shardul Sapkota on 6/3/19.
//  Copyright © 2019 fluid. All rights reserved.
//

import UIKit

class MinderDetailsViewController: UITableViewController {
    
    var moment: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func unwindWithSelectedMoment(segue: UIStoryboardSegue) {
        if let momentPickerViewController = segue.source as? MomentPickerViewController,
            let selectedMoment = momentPickerViewController.selectedMoment {
            print("herererere")
            moment = selectedMoment.name!
            print(moment)
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
