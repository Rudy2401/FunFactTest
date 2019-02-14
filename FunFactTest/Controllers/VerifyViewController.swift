//
//  VerifyViewController.swift
//  FunFactTest
//
//  Created by Rushi Dolas on 2/11/19.
//  Copyright © 2019 Rushi Dolas. All rights reserved.
//

import UIKit

class VerifyViewController: UIViewController {
    @IBOutlet weak var tipsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tipsText1 = NSMutableAttributedString(string: "Tips to verify fact", attributes: Attributes.attribute16DemiBlack)
        let tipsText2 = NSMutableAttributedString(string: "1. Check if the Source ", attributes: Attributes.attribute16DemiBlack)
    }
}
