//
//  HashtagCell.swift
//  FunFactTest
//
//  Created by Rushi Dolas on 10/7/18.
//  Copyright © 2018 Rushi Dolas. All rights reserved.
//

import UIKit

class HashtagCell: UITableViewCell {
    @IBOutlet weak var hashtag: UILabel!
    @IBOutlet weak var count: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
