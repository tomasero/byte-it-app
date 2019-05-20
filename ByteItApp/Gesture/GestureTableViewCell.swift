//
//  GestureTableViewCell.swift
//  GestureiOS
//
//  Created by fluid on 11/10/18.
//  Copyright © 2018 fluid. All rights reserved.
//

import UIKit

class GestureTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var sensorLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
