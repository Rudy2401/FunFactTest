//
//  SearchViewController.swift
//  FunFactTest
//
//  Created by Rushi Dolas on 12/19/18.
//  Copyright © 2018 Rushi Dolas. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage
import InstantSearchClient
import CoreLocation
import MapKit
import SDWebImage

class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchControllerDelegate,
FirestoreManagerDelegate, AlgoliaSearchManagerDelegate, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var landmarkButton: UIButton!
    @IBOutlet weak var hashtagButton: UIButton!
    @IBOutlet weak var userButton: UIButton!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var searchId = 0
    var displayedSearchId = -1
    var loadedPage: UInt = 0
    var nbPages: UInt = 0
    var searchLandmarks = [SearchLandmark]()
    var searchHashtags = [SearchHashtag]()
    var searchUsers = [SearchUsers]()
    var firestore = FirestoreManager()
    var algoliaManager = AlgoliaSearchManager()
    let locationManager = CLLocationManager()
    var currentLocation = CLLocationCoordinate2D()
    var mapView: MKMapView?

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
        
        if traitCollection.userInterfaceStyle == .light {
            view.backgroundColor = .white
            tableView.backgroundColor = .white
        } else {
            if #available(iOS 13.0, *) {
                view.backgroundColor = .secondarySystemBackground
                tableView.backgroundColor = .secondarySystemBackground
            } else {
                view.backgroundColor = .black
                tableView.backgroundColor = .black
            }
        }
        setupButtons()
        tableView.delegate = self
        tableView.dataSource = self
        searchController.delegate = self
        firestore.delegate = self
        algoliaManager.delegate = self
        landmarkButton.isSelected = true

        // Setup the Search Controller
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchBar.sizeToFit()
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search Landmarks"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        mapView = MKMapView(frame: self.view.frame)
        mapView!.delegate = self
        mapView!.showsUserLocation = true
        if landmarkButton.isSelected {
            let landmarkQuery = Query()
            landmarkQuery.hitsPerPage = 15
            landmarkQuery.attributesToRetrieve = ["name", "address", "image", "city", "state", "country", "zipcode", "objectID"]
            landmarkQuery.attributesToHighlight = ["name", "address"]
            landmarkQuery.aroundLatLng = LatLng(lat: (mapView?.userLocation.coordinate.latitude)!,
                                                lng: (mapView?.userLocation.coordinate.longitude)!)
            landmarkQuery.aroundRadius = .all
            AlgoliaManager.sharedInstance.landmarkIndex.search(landmarkQuery, completionHandler: { (data, error) in
                if error != nil {
                    return
                }
                self.loadedPage = 0 // Reset loaded page
                // Decode JSON
                guard let hits = data!["hits"] as? [[String: AnyObject]] else { return }
                guard let nbPages = data!["nbPages"] as? UInt else { return }
                self.nbPages = nbPages
                
                var tmp = [SearchLandmark]()
                for hit in hits {
                    tmp.append(SearchLandmark(json: hit))
                }
                self.searchLandmarks = tmp
                self.tableView.reloadData()
            })
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
        tableView.reloadData()
    }
    override func viewWillDisappear(_ animated: Bool) {
        
    }
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        setupButtons()
    }
    func documentsDidDownload() {
        
    }
    func setupButtons() {
        var landmarkString = NSAttributedString()
        if #available(iOS 13.0, *) {
            let searchField = searchController.searchBar.searchTextField
            if traitCollection.userInterfaceStyle == .light {
                landmarkString = NSAttributedString(string: "Places", attributes: Attributes.searchButtonAttribute)
                view.backgroundColor = .white
                tableView.backgroundColor = .white
                searchController.searchBar.barStyle = .default
                searchField.backgroundColor = .white
                searchField.textColor = .black
            } else {
                landmarkString = NSAttributedString(string: "Places", attributes: Attributes.searchButtonAttributeDark)
                searchController.searchBar.barStyle = .blackOpaque
                searchField.textColor = .white
                if #available(iOS 13.0, *) {
                    view.backgroundColor = .secondarySystemBackground
                    tableView.backgroundColor = .secondarySystemBackground
                    searchField.backgroundColor = .secondarySystemBackground
                } else {
                    view.backgroundColor = .black
                    tableView.backgroundColor = .black
                    searchField.backgroundColor = .black
                }
            }
        } else {
            landmarkString = NSAttributedString(string: "Places", attributes: Attributes.searchButtonAttribute)
        }

        let landmarkStringSelected = NSAttributedString(string: "Places", attributes: Attributes.searchButtonSelectedAttribute)
        landmarkButton.setAttributedTitle(landmarkString, for: .normal)
        landmarkButton.setAttributedTitle(landmarkStringSelected, for: .selected)
        
        var hashtagString = NSAttributedString()
        if traitCollection.userInterfaceStyle == .light {
            hashtagString = NSAttributedString(string: "Tags", attributes: Attributes.searchButtonAttribute)
        } else {
            hashtagString = NSAttributedString(string: "Tags", attributes: Attributes.searchButtonAttributeDark)
        }
        let hashtagStringSelected = NSAttributedString(string: "Tags", attributes: Attributes.searchButtonSelectedAttribute)
        hashtagButton.setAttributedTitle(hashtagString, for: .normal)
        hashtagButton.setAttributedTitle(hashtagStringSelected, for: .selected)
        
        var userString = NSAttributedString()
        if traitCollection.userInterfaceStyle == .light {
            userString = NSAttributedString(string: "People", attributes: Attributes.searchButtonAttribute)
        } else {
            userString = NSAttributedString(string: "People", attributes: Attributes.searchButtonAttributeDark)
        }
        let userStringSelected = NSAttributedString(string: "People", attributes: Attributes.searchButtonSelectedAttribute)
        userButton.setAttributedTitle(userString, for: .normal)
        userButton.setAttributedTitle(userStringSelected, for: .selected)
    }
    func documentsDidUpdate() {
        
    }
    
    
    func willPresentSearchController(_ searchController: UISearchController) {
        navigationController?.navigationBar.isTranslucent = true
    }
    
    func willDismissSearchController(_ searchController: UISearchController) {
        navigationController?.navigationBar.isTranslucent = false
    }
    
    // MARK: - Private instance methods
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        if landmarkButton.isSelected {
            let landmarkQuery = Query()
            landmarkQuery.query = searchText
            landmarkQuery.hitsPerPage = 15
            landmarkQuery.attributesToRetrieve = ["name", "address", "image", "city", "state", "country", "zipcode", "objectID"]
            landmarkQuery.attributesToHighlight = ["name", "address"]
            AlgoliaManager.sharedInstance.landmarkIndex.search(landmarkQuery, completionHandler: { (data, error) in
                if error != nil {
                    return
                }
                self.loadedPage = 0 // Reset loaded page
                // Decode JSON
                guard let hits = data!["hits"] as? [[String: AnyObject]] else { return }
                guard let nbPages = data!["nbPages"] as? UInt else { return }
                self.nbPages = nbPages
                
                var tmp = [SearchLandmark]()
                for hit in hits {
                    tmp.append(SearchLandmark(json: hit))
                }
                self.searchLandmarks = tmp
                self.tableView.reloadData()
            })
        }
        
        if hashtagButton.isSelected {
            let hashtagQuery = Query()
            hashtagQuery.query = searchText
            hashtagQuery.hitsPerPage = 15
            hashtagQuery.attributesToRetrieve = ["name", "count", "image"]
            hashtagQuery.attributesToHighlight = ["name"]
            AlgoliaManager.sharedInstance.hashtagIndex.search(hashtagQuery, completionHandler: { (data, error) in
                if error != nil {
                    return
                }
                self.loadedPage = 0 // Reset loaded page
                // Decode JSON
                guard let hits = data!["hits"] as? [[String: AnyObject]] else { return }
                guard let nbPages = data!["nbPages"] as? UInt else { return }
                self.nbPages = nbPages
                
                var tmp = [SearchHashtag]()
                for hit in hits {
                    tmp.append(SearchHashtag(json: hit))
                }
                self.searchHashtags = tmp
                self.tableView.reloadData()
            })
        }
        if userButton.isSelected {
            let userQuery = Query()
            userQuery.query = searchText
            userQuery.hitsPerPage = 15
            userQuery.attributesToRetrieve = ["name", "userName", "photoURL", "objectID"]
            userQuery.attributesToHighlight = ["name", "userName"]
            AlgoliaManager.sharedInstance.usersIndex.search(userQuery, completionHandler: { (data, error) in
                if error != nil {
                    return
                }
                self.loadedPage = 0 // Reset loaded page
                // Decode JSON
                guard let hits = data!["hits"] as? [[String: AnyObject]] else { return }
                guard let nbPages = data!["nbPages"] as? UInt else { return }
                self.nbPages = nbPages
                
                var tmp = [SearchUsers]()
                for hit in hits {
                    tmp.append(SearchUsers(json: hit))
                }
                self.searchUsers = tmp
                self.tableView.reloadData()
            })
        }
    }

    func isFiltering() -> Bool {
        return true
//        return searchController.isActive && !searchBarIsEmpty()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            if landmarkButton.isSelected {
                return searchLandmarks.count
            }
            if hashtagButton.isSelected {
                return searchHashtags.count
            }
            if userButton.isSelected {
                return searchUsers.count
            }
        }
        return searchLandmarks.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
     
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SearchCellTableViewCell
        if traitCollection.userInterfaceStyle == .light {
            cell.backgroundColor = .white
        } else {
            if #available(iOS 13.0, *) {
                cell.backgroundColor = .secondarySystemBackground
            } else {
                cell.backgroundColor = .black
            }
        }
        var searchText = ""
        var secondaryText = ""
        var image = ""
        var photoURL = ""
        
        if isFiltering() {
            if landmarkButton.isSelected {
                searchText = searchLandmarks[indexPath.row].nameHighlighted!
                secondaryText = searchLandmarks[indexPath.row].addressHighlighted!
                image = searchLandmarks[indexPath.row].image!
                cell.landmarkID = searchLandmarks[indexPath.row].landmarkID!
                setupImage(image: image, completion: { (resultImage) in
                    cell.searchImageView.image = resultImage
                })
            }
            if hashtagButton.isSelected {
                searchText = "#\(searchHashtags[indexPath.row].nameHighlighted!)"
                secondaryText = "\(searchHashtags[indexPath.row].count ?? 0) facts"
                image = searchHashtags[indexPath.row].image!
                setupImage(image: image, completion: { (resultImage) in
                    cell.searchImageView.image = resultImage
                })
            }
            if userButton.isSelected {
                searchText = searchUsers[indexPath.row].userNameHighlighted!
                secondaryText = searchUsers[indexPath.row].nameHighlighted!
                photoURL = searchUsers[indexPath.row].photoURL!
                let url = URL(string: photoURL) ?? URL(string: "")
                cell.userID = searchUsers[indexPath.row].userID!
                cell.searchImageView?.sd_setImage(with: url,
                                               placeholderImage: UIImage(),
                                               options: SDWebImageOptions(rawValue: 0),
                                               completed: { (image, error, cacheType, imageURL) in
                                                if error != nil {
                                                    cell.searchImageView.image = UIImage.fontAwesomeIcon(name: .user,
                                                                                                         style: .solid,
                                                                                                         textColor: .darkGray,
                                                                                                         size: CGSize(width: 100, height: 100))
                                                }
                })
            }
        } else {
            searchLandmarks = []
            tableView.reloadData()
        }
        cell.primaryText.highlightedTextColor = Colors.systemGreenColor
        cell.secondaryText.highlightedTextColor = Colors.systemGreenColor
        cell.primaryText.highlightedText = searchText
        cell.secondaryText.highlightedText = secondaryText
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.hashtagButton.isSelected {
            let cell = tableView.cellForRow(at: indexPath) as! SearchCellTableViewCell
            let hashtag = "\(cell.primaryText.text?.components(separatedBy: "#").last ?? "")"
            firestore.getFunFacts(for: hashtag) { (funFacts, error) in
                if let error = error {
                    print ("Error getting hashtag funfacts \(error)")
                } else {
                    let funFactsVC = self.storyboard?.instantiateViewController(withIdentifier: "userSubs") as! FunFactsTableViewController
                    funFactsVC.userProfile = AppDataSingleton.appDataSharedInstance.userProfile
                    funFactsVC.sender = .hashtags
                    funFactsVC.hashtagName = cell.primaryText.text!
                    self.navigationController?.pushViewController(funFactsVC, animated: true)
                }
            }
        } else if landmarkButton.isSelected {
            let cell = tableView.cellForRow(at: indexPath) as! SearchCellTableViewCell
            let landmarkID = cell.landmarkID
            firestore.downloadFunFacts(for: landmarkID) { (funFacts, pageContent, error) in
                if let error = error {
                    print ("Error getting funfacts \(error)")
                } else {
                    let funFacts = funFacts!
                    let destinationVC = self.storyboard?.instantiateViewController(withIdentifier: "funFactPage") as! FunFactPageViewController
                    destinationVC.pageContent = pageContent! as NSArray
                    destinationVC.funFacts = funFacts
                    destinationVC.headingContent = cell.primaryText.text ?? ""
                    destinationVC.landmarkID = landmarkID
                    destinationVC.address = cell.secondaryText.text ?? ""
                    
                    self.navigationController?.pushViewController(destinationVC, animated: true)
                }
            }
        } else if userButton.isSelected {
            let cell = tableView.cellForRow(at: indexPath) as! SearchCellTableViewCell
            let userID = cell.userID
            firestore.downloadUserProfile(userID) { (user, error) in
                if let error = error {
                    print ("Error getting user profile \(error)")
                } else {
                    let profileVC = self.storyboard?.instantiateViewController(withIdentifier: "profileView") as! ProfileViewController
                    profileVC.uid = userID
                    profileVC.mode = .otherUser
                    profileVC.userProfile = user!
                    self.navigationController?.pushViewController(profileVC, animated: true)
                }
            }
        }
    }

    @IBAction func onClickLandmark(_ sender: Any) {
        landmarkButton.isSelected = true
        hashtagButton.isSelected = false
        userButton.isSelected = false
        searchController.searchBar.placeholder = "Search Landmarks"
        tableView.reloadData()
    }
    
    @IBAction func onClickHashtag(_ sender: Any) {
        hashtagButton.isSelected = true
        landmarkButton.isSelected = false
        userButton.isSelected = false
        searchController.searchBar.placeholder = "Search Hashtags"
        tableView.reloadData()
    }
    
    @IBAction func onClickUser(_ sender: Any) {
        userButton.isSelected = true
        landmarkButton.isSelected = false
        hashtagButton.isSelected = false
        searchController.searchBar.placeholder = "Search Users"
        tableView.reloadData()
    }
    
    func setupImage(image: String, completion: @escaping (UIImage) -> ()) {
        let landmarkImage = UIImageView()
        let imageName = image + ".jpeg"
        let imageFromCache = CacheManager.shared.getFromCache(key: imageName) as? UIImage
        if imageFromCache != nil {
            print("******In cache")
            landmarkImage.image = imageFromCache
        } else {
            let storage = Storage.storage()
            let storageRef = storage.reference()
            let gsReference = storageRef.child("images/\(imageName)")
            gsReference.downloadURL { url, error in
                if let error = error {
                    print ("Error setting url \(error)")
                } else {
                    landmarkImage.sd_setImage(with: url, placeholderImage: UIImage())
                    landmarkImage.layer.cornerRadius = 5
                    completion(landmarkImage.image!)
                }
            }
        }
    }
}
extension SearchViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        DispatchQueue.main.async {
            self.filterContentForSearchText(searchController.searchBar.text!)
        }
    }
}
