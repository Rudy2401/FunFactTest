//
//  SettingsTableViewCell.swift
//  FunFactTest
//
//  Created by Rushi Dolas on 2/28/19.
//  Copyright © 2019 Rushi Dolas. All rights reserved.
//

import UIKit

class SettingsTableViewCell: UITableViewCell {
    @IBOutlet weak var imageButtonLeft: UIButton!
    @IBOutlet weak var imageButtonRight: UIButton!
    @IBOutlet weak var settingsRowLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
