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
        
        navigationItem.title = "Leaderboard"
        tableView.delegate = self
        tableView.dataSource = self
        leaders = AppDataSingleton.appDataSharedInstance.leadersByCity
        cityButton.isSelected = true
        setupButtons()
        setupTableHeader()
        darkModeSupport()
        refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        tableView.addSubview(refreshControl)
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
        setupButtons()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        leaders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "leaderboardCell", for: indexPath) as! LeaderboardTableViewCell
        if traitCollection.userInterfaceStyle == .light {
            cell.backgroundColor = .white
        } else {
            if #available(iOS 13.0, *) {
                cell.backgroundColor = .secondarySystemBackground
            } else {
                cell.backgroundColor = .black
            }
        }
        
        if indexPath.row % 2 == 0 {
            if #available(iOS 13.0, *) {
                cell.backgroundColor = .systemGray3
            } else {
                cell.backgroundColor = .gray
            }
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
        60
    }
    func documentsDidUpdate() {
        
    }
    
    
    func setupButtons() {
        let countryString = NSAttributedString(string: "Country", attributes: Attributes.searchButtonAttribute)
        let countryStringDark = NSAttributedString(string: "Country", attributes: Attributes.searchButtonAttributeDark)
        let countryStringSelected = NSAttributedString(string: "Country", attributes: Attributes.searchButtonSelectedAttribute)
        countryButton.setAttributedTitle(countryStringSelected, for: .selected)
        
        let cityString = NSAttributedString(string: "City", attributes: Attributes.searchButtonAttribute)
        let cityStringDark = NSAttributedString(string: "City", attributes: Attributes.searchButtonAttributeDark)
        let cityStringSelected = NSAttributedString(string: "City", attributes: Attributes.searchButtonSelectedAttribute)
        cityButton.setAttributedTitle(cityStringSelected, for: .selected)
        
        let overallString = NSAttributedString(string: "Worldwide", attributes: Attributes.searchButtonAttribute)
        let overallStringDark = NSAttributedString(string: "Worldwide", attributes: Attributes.searchButtonAttributeDark)
        let overallStringSelected = NSAttributedString(string: "Worldwide", attributes: Attributes.searchButtonSelectedAttribute)
        worldwideButton.setAttributedTitle(overallStringSelected, for: .selected)

        if traitCollection.userInterfaceStyle == .light {
            countryButton.setAttributedTitle(countryString, for: .normal)
            cityButton.setAttributedTitle(cityString, for: .normal)
            worldwideButton.setAttributedTitle(overallString, for: .normal)
        } else {
            countryButton.setAttributedTitle(countryStringDark, for: .normal)
            cityButton.setAttributedTitle(cityStringDark, for: .normal)
            worldwideButton.setAttributedTitle(overallStringDark, for: .normal)
        }
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
        headerView.backgroundColor = Colors.systemGreenColor
        
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
