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

class SearchViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var landmarkButton: UIButton!
    @IBOutlet weak var addressButton: UIButton!
    @IBOutlet weak var hashtagButton: UIButton!
    @IBOutlet weak var userButton: UIButton!
    
    let searchController = UISearchController(searchResultsController: nil)
    var filteredLandmarks = [String]()
    var landmarks = [String]()
    var addresses = [String]()
    var filteredAddresses = [String]()
    var hashtags = [String]()
    var filteredHashtags = [String]()
    var users = [String]()
    var filteredUsers = [String]()
    var imageDict = [String: String]()
    
    var searchId = 0
    var displayedSearchId = -1
    var loadedPage: UInt = 0
    var nbPages: UInt = 0
    var searchLandmarks = [SearchLandmark]()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupButtons()
        tableView.delegate = self
        tableView.dataSource = self
        searchController.delegate = self
        landmarkButton.isSelected = true

        for landmark in AppDataSingleton.appDataSharedInstance.listOfLandmarks.listOfLandmarks {
            landmarks.append(landmark.name)
            addresses.append(((landmark.address.trimmingCharacters(in: .whitespacesAndNewlines) == "") ? landmark.name : landmark.address) + ", " + landmark.city + ", " + landmark.state + " " + landmark.zipcode)
        }
        
        getHashtags()
        getUsers()
        populateDict()
        // Setup the Search Controller
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchBar.sizeToFit()
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search Landmarks"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    func getHashtags() {
        let db = Firestore.firestore()
        db.collection("hashtags").order(by: "hashtagcount", descending: true).getDocuments { (snapshot, error) in
            if let err = error {
                print("Error getting documents: \(err)")
            } else {
                for document in (snapshot?.documents)! {
                    self.hashtags.append("#\(document.documentID)")
                }
            }
        }
    }
    
    func getUsers() {
        let db = Firestore.firestore()
        db.collection("users").getDocuments { (snapshot, error) in
            if let err = error {
                print("Error getting documents: \(err)")
            } else {
                for document in (snapshot?.documents)! {
                    self.users.append(document.data()["name"] as! String)
                }
            }
        }
    }
    
    func populateDict() {
        for landmark in AppDataSingleton.appDataSharedInstance.listOfLandmarks.listOfLandmarks {
            for funFact in AppDataSingleton.appDataSharedInstance.listOfFunFacts.listOfFunFacts {
                if landmark.id == funFact.landmarkId {
                    imageDict[landmark.name] = funFact.image
                    break
                }
            }
            
        }
    }
    
    func setupButtons() {
        let landmarkString = NSAttributedString(string: "Places", attributes: Attributes.searchButtonAttribute)
        let landmarkStringSelected = NSAttributedString(string: "Places", attributes: Attributes.searchButtonSelectedAttribute)
        landmarkButton.setAttributedTitle(landmarkString, for: .normal)
        landmarkButton.setAttributedTitle(landmarkStringSelected, for: .selected)
        
        let addressString = NSAttributedString(string: "Address", attributes: Attributes.searchButtonAttribute)
        let addressStringSelected = NSAttributedString(string: "Address", attributes: Attributes.searchButtonSelectedAttribute)
        addressButton.setAttributedTitle(addressString, for: .normal)
        addressButton.setAttributedTitle(addressStringSelected, for: .selected)
        
        let hashtagString = NSAttributedString(string: "Tags", attributes: Attributes.searchButtonAttribute)
        let hashtagStringSelected = NSAttributedString(string: "Tags", attributes: Attributes.searchButtonSelectedAttribute)
        hashtagButton.setAttributedTitle(hashtagString, for: .normal)
        hashtagButton.setAttributedTitle(hashtagStringSelected, for: .selected)
        
        let userString = NSAttributedString(string: "People", attributes: Attributes.searchButtonAttribute)
        let userStringSelected = NSAttributedString(string: "People", attributes: Attributes.searchButtonSelectedAttribute)
        userButton.setAttributedTitle(userString, for: .normal)
        userButton.setAttributedTitle(userStringSelected, for: .selected)
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
        let client = Client(appID: "P1NWQ6JXG6", apiKey: "56f9249980860f38c01e52158800a9b0")
        let index = client.index(withName: "landmark_name")
        let query = Query()
        
        let curSearchId = searchId
        query.query = searchText
        query.hitsPerPage = 15
        query.attributesToRetrieve = ["name", "address", "image"]
        query.attributesToHighlight = ["name"]
        if landmarkButton.isSelected {
            index.search(query, completionHandler: { (data, error) in
                if (curSearchId <= self.displayedSearchId) || error != nil {
                    return
                }
                self.displayedSearchId = curSearchId
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
        self.searchId += 1
        
        if addressButton.isSelected {
            filteredAddresses = addresses.filter({( address : String) -> Bool in
                return address.lowercased().contains(searchText.lowercased())
            })
        }
        if hashtagButton.isSelected {
            filteredHashtags = hashtags.filter({( hashtag : String) -> Bool in
                return hashtag.lowercased().contains(searchText.lowercased())
            })
        }
        if userButton.isSelected {
            filteredUsers = users.filter({( user : String) -> Bool in
                return user.lowercased().contains(searchText.lowercased())
            })
        }
        tableView.reloadData()
    }

    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            if landmarkButton.isSelected {
                return searchLandmarks.count
            }
            if hashtagButton.isSelected {
                return filteredHashtags.count
            }
            if userButton.isSelected {
                return filteredUsers.count
            }
            if addressButton.isSelected {
                return filteredAddresses.count
            }
        }
        
        return landmarks.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
     
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! SearchCellTableViewCell
        var searchText = ""
        var secondaryText = ""
        var image = ""
        
        print (isFiltering())
        if isFiltering() {
            if landmarkButton.isSelected {
                print (searchLandmarks)
                searchText = searchLandmarks[indexPath.row].nameHighlighted!
                secondaryText = searchLandmarks[indexPath.row].address!
                image = searchLandmarks[indexPath.row].image!
            }
            if addressButton.isSelected {
                secondaryText = filteredAddresses[indexPath.row]
                for landmark in AppDataSingleton.appDataSharedInstance.listOfLandmarks.listOfLandmarks {
                    if landmark.address == secondaryText.split(separator: ",")[0] {
                        searchText = landmark.name
                    }
                }
            }
            if hashtagButton.isSelected {
                searchText = filteredHashtags[indexPath.row]
            }
            if userButton.isSelected {
                searchText = filteredUsers[indexPath.row]
            }
        } else {
            searchLandmarks = []
            tableView.reloadData()
        }
        cell.primaryText.highlightedTextColor = Colors.seagreenColor
        cell.primaryText.highlightedText = searchText
        cell.secondaryText.text = secondaryText
        if searchText.count > 0 {
            cell.searchImageView.image = setupImage(image: image)
        }
        else {
            cell.searchImageView.image = UIImage()
        }
        return cell
    }

    @IBAction func onClickLandmark(_ sender: Any) {
        landmarkButton.isSelected = true
        addressButton.isSelected = false
        hashtagButton.isSelected = false
        userButton.isSelected = false
        searchController.searchBar.placeholder = "Search Landmarks"
        tableView.reloadData()
    }
    
    @IBAction func onClickAddress(_ sender: Any) {
        addressButton.isSelected = true
        landmarkButton.isSelected = false
        hashtagButton.isSelected = false
        userButton.isSelected = false
        searchController.searchBar.placeholder = "Search Addresses"
        tableView.reloadData()
    }
    
    @IBAction func onClickHashtag(_ sender: Any) {
        hashtagButton.isSelected = true
        landmarkButton.isSelected = false
        addressButton.isSelected = false
        userButton.isSelected = false
        searchController.searchBar.placeholder = "Search Hashtags"
        tableView.reloadData()
    }
    
    @IBAction func onClickUser(_ sender: Any) {
        userButton.isSelected = true
        landmarkButton.isSelected = false
        addressButton.isSelected = false
        hashtagButton.isSelected = false
        searchController.searchBar.placeholder = "Search Users"
        tableView.reloadData()
    }
    
    func setupImage(image: String) -> UIImage {
        let landmarkImage = UIImageView()
        
        let imageName = image + ".jpeg"
        let imageFromCache = CacheManager.shared.getFromCache(key: imageName) as? UIImage
        if imageFromCache != nil {
            print("******In cache")
            landmarkImage.image = imageFromCache
            landmarkImage.layer.cornerRadius = 5
        } else {
            let storage = Storage.storage()
            let storageRef = storage.reference()
            let gsReference = storageRef.child("images/\(imageName)")
            landmarkImage.sd_setImage(with: gsReference, placeholderImage: UIImage())
            landmarkImage.layer.cornerRadius = 5
        }
        return landmarkImage.image!
    }
    
}
extension SearchViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)

    }
}
