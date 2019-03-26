//
//  NotificationFrequency.swift
//  FunFactTest
//
//  Created by Rushi Dolas on 3/25/19.
//  Copyright © 2019 Rushi Dolas. All rights reserved.
//

import UIKit

class NotificationFrequency: UIViewController {
    @IBOutlet weak var touristLabel: UILabel!
    @IBOutlet weak var touristSwitch: UISwitch!
    @IBOutlet weak var occasionalLabel: UILabel!
    @IBOutlet weak var occasionalSwitch: UISwitch!
    @IBOutlet weak var offLabel: UILabel!
    @IBOutlet weak var offSwitch: UISwitch!
    @IBOutlet weak var updateButton: CustomButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.tintColor = .darkGray
        if let customFont = UIFont(name: "AvenirNext-Bold", size: 30.0) {
            if #available(iOS 11.0, *) {
                navigationController?.navigationBar.largeTitleTextAttributes = [ NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: customFont ]
            }
        }
        navigationItem.title = "Notification frequency"
        updateButton.cornerRadius = 25
        updateButton.layer.backgroundColor = Colors.seagreenColor.cgColor
    }
    
    @IBAction func touristModeAction(_ sender: Any) {
        if !touristSwitch.isOn {
            touristSwitch.setOn(true, animated: true)
            occasionalSwitch.setOn(false, animated: true)
            offSwitch.setOn(false, animated: true)
        } else {
            touristSwitch.setOn(false, animated: true)
        }
    }
    @IBAction func occasionalAction(_ sender: Any) {
        if !occasionalSwitch.isOn {
            occasionalSwitch.setOn(true, animated: true)
            touristSwitch.setOn(false, animated: true)
            offSwitch.setOn(false, animated: true)
        } else {
            occasionalSwitch.setOn(false, animated: true)
        }
    }
    @IBAction func offAction(_ sender: Any) {
        if !offSwitch.isOn {
            offSwitch.setOn(true, animated: true)
            occasionalSwitch.setOn(false, animated: true)
            touristSwitch.setOn(false, animated: true)
        } else {
            offSwitch.setOn(false, animated: true)
        }
    }
    @IBAction func updateAction(_ sender: Any) {
        if touristSwitch.isOn {
            UserDefaults.standard.set(30, forKey: "NotificationFrequency")
        }
        if occasionalSwitch.isOn {
            UserDefaults.standard.set(5, forKey: "NotificationFrequency")
        }
        if offSwitch.isOn {
            UserDefaults.standard.set(0, forKey: "NotificationFrequency")
        }
    }
}
