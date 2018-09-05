//
//  AddressCell.swift
//  FunFactTest
//
//  Created by Rushi Dolas on 7/29/18.
//  Copyright © 2018 Rushi Dolas. All rights reserved.
//

import UIKit

class AddressCell: UITableViewCell {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var address: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
