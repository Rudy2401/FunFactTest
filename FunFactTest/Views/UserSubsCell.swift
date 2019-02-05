//
//  UserSubsCell.swift
//  FunFactTest
//
//  Created by Rushi Dolas on 10/14/18.
//  Copyright © 2018 Rushi Dolas. All rights reserved.
//

import UIKit

class UserSubsCell: UITableViewCell {
    @IBOutlet weak var funFactImage: UIImageView!
    @IBOutlet weak var landmarkName: UILabel!
    @IBOutlet weak var funFactDescription: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        funFactImage.layer.masksToBounds = true
        funFactImage.clipsToBounds = true
        funFactImage.contentMode = .scaleAspectFill
        funFactImage.layer.cornerRadius = funFactImage.frame.width/2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
