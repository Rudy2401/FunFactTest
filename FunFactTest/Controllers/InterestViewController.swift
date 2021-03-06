//
//  InterestViewController.swift
//  FunFactTest
//
//  Created by Rushi Dolas on 3/23/19.
//  Copyright © 2019 Rushi Dolas. All rights reserved.
//

import UIKit


class InterestViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var updateButton: CustomButton!
    
    let landmarkTypes = [LandmarkTypes.art,
                         LandmarkTypes.cool,
                         LandmarkTypes.historic,
                         LandmarkTypes.landmark,
                         LandmarkTypes.natural,
                         LandmarkTypes.park,
                         LandmarkTypes.restaurant]
    var interests = Set<String>()
    
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
        navigationItem.title = "Choose your interests"
        updateButton.cornerRadius = 25
        updateButton.layer.backgroundColor = Colors.systemGreenColor.cgColor
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        darkModeSupport()
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return landmarkTypes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! InterestTableViewCell
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
        cell.landmarkTypeLabel.text = landmarkTypes[index]
        cell.landmarkTypeButton.setImage(Constants.getMarkerDetails(type: landmarkTypes[index],
                                                                    width: Double(cell.landmarkTypeButton.frame.width),
                                                                    height: Double(cell.landmarkTypeButton.frame.height)).image,
                                         for: .normal)
        cell.landmarkTypeButton.tintColor = Constants.getMarkerDetails(type: landmarkTypes[index],
                                                                       width: Double(cell.landmarkTypeButton.frame.width),
                                                                       height: Double(cell.landmarkTypeButton.frame.height)).color
        let array = UserDefaults.standard.array(forKey: "UserInterests") as? [String] ?? []
        if array.contains(landmarkTypes[index]) {
            cell.accessoryType = .checkmark
            interests.insert(landmarkTypes[index])
        }
        return cell
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView.cellForRow(at: indexPath as IndexPath)?.accessoryType == .checkmark {
            tableView.cellForRow(at: indexPath as IndexPath)?.accessoryType = .none
            interests.remove(landmarkTypes[indexPath.row])
        } else {
            tableView.cellForRow(at: indexPath as IndexPath)?.accessoryType = .checkmark
            interests.insert(landmarkTypes[indexPath.row])
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.height/7
    }

    @IBAction func updateInterests(_ sender: Any) {
        let defaults = UserDefaults.standard
        let data = NSArray(array: Array(interests))
        defaults.set(data, forKey: "UserInterests")
        let alert = Utils.showAlert(status: .success, message: ErrorMessages.interestsSuccess)
        self.present(alert, animated: true) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                guard self?.presentedViewController == alert else { return }
                self?.dismiss(animated: true, completion: nil)
                self!.navigationController?.popViewController(animated: true)
            }
        }
    }
}
