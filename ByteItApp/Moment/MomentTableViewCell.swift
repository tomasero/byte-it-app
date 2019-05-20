//
//   MomentTableViewCell.swift
//  GestureiOS
//
//  Created by Tomás Vega on 1/18/19.
//  Copyright © 2019 fluid. All rights reserved.
//

import UIKit

class MomentTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var infoLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
