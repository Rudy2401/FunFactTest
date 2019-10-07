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
        if traitCollection.userInterfaceStyle == .light {
            hashtag.backgroundColor = .white
            count.backgroundColor = .white
        } else {
            if #available(iOS 13.0, *) {
                hashtag.backgroundColor = .secondarySystemBackground
                count.backgroundColor = .secondarySystemBackground
            } else {
                hashtag.backgroundColor = .black
                count.backgroundColor = .black
            }
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
