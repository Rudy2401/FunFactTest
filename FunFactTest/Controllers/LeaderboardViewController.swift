//
//  LeaderboardViewController.swift
//  FunFactTest
//
//  Created by Rushi Dolas on 4/10/19.
//  Copyright © 2019 Rushi Dolas. All rights reserved.
//

import UIKit
import SDWebImage

class LeaderboardViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, FirestoreManagerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var cityButton: UIButton!
    @IBOutlet weak var countryButton: UIButton!
    @IBOutlet weak var worldwideButton: UIButton!
    
    var leaders = [Leader]() {
        didSet {
            tableView.reloadData()
        }
    }
    var refreshControl: UIRefreshControl!
    var firestore = FirestoreManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Leaderboard"
        tableView.delegate = self
        tableView.dataSource = self
        leaders = AppDataSingleton.appDataSharedInstance.leadersByCity
        cityButton.isSelected = true
        setupButtons()
        setupTableHeader()
        
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        tableView.addSubview(refreshControl)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return leaders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "leaderboardCell", for: indexPath) as! LeaderboardTableViewCell
        
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = Colors.veryLightGray
        }
        cell.rankLabel.text = "\(indexPath.row + 1)"
        cell.userNameLabel.text = leaders[indexPath.row].userID
        cell.countLabel.text = "\(leaders[indexPath.row].count)"
        let url = URL(string: leaders[indexPath.row].photoURL) ?? URL(string: "")

        cell.userImageView.sd_setImage(with: url,
                                       placeholderImage: UIImage(),
                                       options: SDWebImageOptions(rawValue: 0),
                                       completed: { (image, error, cacheType, imageURL) in
                                        if error != nil {
                                            cell.userImageView.image = UIImage
                                                .fontAwesomeIcon(name: .user,
                                                                 style: .solid,
                                                                 textColor: .darkGray,
                                                                 size: CGSize(width: 100, height: 100))
                                        }
        })
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    func documentsDidUpdate() {
        
    }
    
    
    func setupButtons() {
        let countryString = NSAttributedString(string: "Country", attributes: Attributes.searchButtonAttribute)
        let countryStringSelected = NSAttributedString(string: "Country", attributes: Attributes.searchButtonSelectedAttribute)
        countryButton.setAttributedTitle(countryString, for: .normal)
        countryButton.setAttributedTitle(countryStringSelected, for: .selected)
        
        let cityString = NSAttributedString(string: "City", attributes: Attributes.searchButtonAttribute)
        let cityStringSelected = NSAttributedString(string: "City", attributes: Attributes.searchButtonSelectedAttribute)
        cityButton.setAttributedTitle(cityString, for: .normal)
        cityButton.setAttributedTitle(cityStringSelected, for: .selected)
        
        let overallString = NSAttributedString(string: "Worldwide", attributes: Attributes.searchButtonAttribute)
        let overallStringSelected = NSAttributedString(string: "Worldwide", attributes: Attributes.searchButtonSelectedAttribute)
        worldwideButton.setAttributedTitle(overallString, for: .normal)
        worldwideButton.setAttributedTitle(overallStringSelected, for: .selected)
    }
    
    @IBAction func cityAction(_ sender: Any) {
        leaders = AppDataSingleton.appDataSharedInstance.leadersByCity
        cityButton.isSelected = true
        countryButton.isSelected = false
        worldwideButton.isSelected = false
    }
    @IBAction func countryAction(_ sender: Any) {
        leaders = AppDataSingleton.appDataSharedInstance.leadersByCountry
        countryButton.isSelected = true
        cityButton.isSelected = false
        worldwideButton.isSelected = false
    }
    @IBAction func worldwideAction(_ sender: Any) {
        leaders = AppDataSingleton.appDataSharedInstance.leadersWorldwide
        worldwideButton.isSelected = true
        cityButton.isSelected = false
        countryButton.isSelected = false
    }
    func setupTableHeader() {
        let headerView = UIView(frame: CGRect(x: 0, y: 50, width: tableView.frame.width, height: 40))
        headerView.backgroundColor = Colors.seagreenColor
        
        let ranklabelView = UILabel(frame: CGRect(x: headerView.frame.size.width * 0.04,
                                                  y: headerView.frame.size.height * 0.22,
                                                  width: headerView.frame.size.width * 0.735,
                                                  height: headerView.frame.size.height * 0.5))
        ranklabelView.font = UIFont(name: Fonts.demiBoldFont, size: 15.0)
        ranklabelView.textColor = .white
        ranklabelView.text = "Rank"
        headerView.addSubview(ranklabelView)
        let namelabelView = UILabel(frame: CGRect(x: headerView.frame.size.width * 0.25,
                                                  y: headerView.frame.size.height * 0.22,
                                                  width: headerView.frame.size.width * 0.735,
                                                  height: headerView.frame.size.height * 0.5))
        namelabelView.font = UIFont(name: Fonts.demiBoldFont, size: 15.0)
        namelabelView.textColor = .white
        namelabelView.text = "User Name"
        headerView.addSubview(namelabelView)
        let countlabelView = UILabel(frame: CGRect(x: headerView.frame.size.width * 0.75,
                                                   y: headerView.frame.size.height * 0.22,
                                                   width: headerView.frame.size.width * 0.735,
                                                   height: headerView.frame.size.height * 0.5))
        countlabelView.font = UIFont(name: Fonts.demiBoldFont, size: 15.0)
        countlabelView.textColor = .white
        countlabelView.text = "Submissions"
        headerView.addSubview(countlabelView)
        tableView.tableHeaderView = headerView
    }
    @objc func didPullToRefresh() {
        firestore.getLeaders(type: .country) { (leaders, error) in
            if let error = error {
                print ("Error getting leader data \(error)")
            } else {
                AppDataSingleton.appDataSharedInstance.leadersByCountry = leaders!
                if self.countryButton.isSelected {
                    self.leaders = AppDataSingleton.appDataSharedInstance.leadersByCountry
                    self.refreshControl?.endRefreshing()
                }
            }
        }
        firestore.getLeaders(type: .city) { (leaders, error) in
            if let error = error {
                print ("Error getting leader data \(error)")
            } else {
                AppDataSingleton.appDataSharedInstance.leadersByCity = leaders!
                if self.cityButton.isSelected {
                    self.leaders = AppDataSingleton.appDataSharedInstance.leadersByCity
                    self.refreshControl?.endRefreshing()
                }
            }
        }
        firestore.getLeaders(type: .worldwide) { (leaders, error) in
            if let error = error {
                print ("Error getting leader data \(error)")
            } else {
                AppDataSingleton.appDataSharedInstance.leadersWorldwide = leaders!
                if self.worldwideButton.isSelected {
                    self.leaders = AppDataSingleton.appDataSharedInstance.leadersWorldwide
                    self.refreshControl?.endRefreshing()
                }
            }
        }
    }
}
