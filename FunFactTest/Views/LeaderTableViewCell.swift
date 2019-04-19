//
//  LeaderTableViewCell.swift
//  FunFactTest
//
//  Created by Rushi Dolas on 4/2/19.
//  Copyright © 2019 Rushi Dolas. All rights reserved.
//

import UIKit

class LeaderTableViewCell: UITableViewCell {
    @IBOutlet weak var rankLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        rankLabel.tag = 100
//        userImageView.tag = 200
//        userNameLabel.tag = 300
//        countLabel.tag = 400
//        userImageView.clipsToBounds = true
//        userImageView.contentMode = .scaleAspectFill
//        userImageView.layer.cornerRadius = userImageView.frame.width/2
        
//        rankLabel.font = UIFont(name: Fonts.demiBoldFont, size: 15.0)
//        userNameLabel.font = UIFont(name: Fonts.demiBoldFont, size: 15.0)
//        countLabel.font = UIFont(name: Fonts.regularFont, size: 15.0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
