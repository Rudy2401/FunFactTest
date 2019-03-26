//
//  SettingsViewController.swift
//  FunFactTest
//
//  Created by Rushi Dolas on 2/28/19.
//  Copyright © 2019 Rushi Dolas. All rights reserved.
//

import UIKit


class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var settingsData = ["Choose your interests",
                        "Notification frequency",
                        "Help",
                        "About"]
    var buttonLeftData = [String.fontAwesomeIcon(name: .landmark),
                          String.fontAwesomeIcon(name: .bell),
                          String.fontAwesomeIcon(name: .questionCircle),
                          String.fontAwesomeIcon(name: .infoCircle)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.tintColor = .darkGray
        if let customFont = UIFont(name: "AvenirNext-Bold", size: 30.0) {
            if #available(iOS 11.0, *) {
                navigationController?.navigationBar.largeTitleTextAttributes = [ NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: customFont ]
            } else {
                // Fallback on earlier versions
            }
        }
        navigationItem.title = "Settings"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SettingsTableViewCell
        let index = indexPath.row as Int
        cell.settingsRowLabel.text = settingsData[index]
        cell.imageButtonLeft.titleLabel?.font = UIFont.fontAwesome(ofSize: 20, style: .light)
        cell.imageButtonLeft.setTitleColor(.darkGray, for: .normal)
        cell.imageButtonLeft.setTitle(buttonLeftData[index], for: .normal)
        cell.imageButtonRight.titleLabel?.font = UIFont.fontAwesome(ofSize: 20, style: .light)
        cell.imageButtonRight.setTitleColor(.darkGray, for: .normal)
        cell.imageButtonRight.setTitle(String.fontAwesomeIcon(name: .chevronRight), for: .normal)
        return cell
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            self.performSegue(withIdentifier: "interestVC", sender: indexPath)
        case 1:
            self.performSegue(withIdentifier: "notifcationFreqSegue", sender: indexPath)
        default:
            return
        }
    }
}
