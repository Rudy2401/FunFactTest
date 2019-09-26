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
                        "More Settings",
                        "Help",
                        "About"]
    var buttonLeftData = [String.fontAwesomeIcon(name: .landmark),
                          String.fontAwesomeIcon(name: .bell),
                          String.fontAwesomeIcon(name: .questionCircle),
                          String.fontAwesomeIcon(name: .infoCircle)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            let navBar = UINavigationBarAppearance()
            navBar.backgroundColor = Colors.systemGreenColor
            navBar.titleTextAttributes = Attributes.navTitleAttribute
            navBar.largeTitleTextAttributes = Attributes.navTitleAttribute
            self.navigationController?.navigationBar.standardAppearance = navBar
            self.navigationController?.navigationBar.scrollEdgeAppearance = navBar
        } else {
            // Fallback on earlier versions
        }
        darkModeSupport()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.isScrollEnabled = false
        tableView.accessibilityIdentifier = "settingsTable"
        
        navigationItem.title = "Settings"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    func darkModeSupport() {
        if traitCollection.userInterfaceStyle == .light {
            tableView.backgroundColor = .white
            view.backgroundColor = .white
        } else {
            if #available(iOS 13.0, *) {
                tableView.backgroundColor = .secondarySystemBackground
                view.backgroundColor = .secondarySystemBackground
            } else {
                tableView.backgroundColor = .black
                view.backgroundColor = .black
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        darkModeSupport()
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingsData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SettingsTableViewCell
        let buttonColor: UIColor = traitCollection.userInterfaceStyle == .light ? .darkGray : .white
        if traitCollection.userInterfaceStyle == .light {
            cell.backgroundColor = .white
        } else {
            if #available(iOS 13.0, *) {
                cell.backgroundColor = .secondarySystemBackground
            } else {
                cell.backgroundColor = .black
            }
        }
        let index = indexPath.row as Int
        cell.settingsRowLabel.text = settingsData[index]
        cell.imageButtonLeft.titleLabel?.font = UIFont.fontAwesome(ofSize: 20, style: .light)
        cell.imageButtonLeft.setTitleColor(buttonColor, for: .normal)
        cell.imageButtonLeft.setTitle(buttonLeftData[index], for: .normal)
        cell.imageButtonRight.titleLabel?.font = UIFont.fontAwesome(ofSize: 20, style: .light)
        cell.imageButtonRight.setTitleColor(buttonColor, for: .normal)
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
