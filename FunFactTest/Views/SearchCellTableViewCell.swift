//
//  SearchCellTableViewCell.swift
//  FunFactTest
//
//  Created by Rushi Dolas on 12/19/18.
//  Copyright © 2018 Rushi Dolas. All rights reserved.
//

import UIKit

class SearchCellTableViewCell: UITableViewCell {
    @IBOutlet weak var secondaryText: UILabel!
    @IBOutlet weak var primaryText: UILabel!
    @IBOutlet weak var searchImageView: UIImageView!
    var landmarkID = ""
    var userID = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        primaryText.text = ""
        secondaryText.text = ""
        primaryText.highlightedText = ""
        searchImageView.layer.masksToBounds = true
        searchImageView.clipsToBounds = true
        searchImageView.contentMode = .scaleAspectFill
        searchImageView.layer.cornerRadius = searchImageView.frame.width/2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
