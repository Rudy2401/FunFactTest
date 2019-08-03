//
//  UserSubsTableViewController.swift
//  FunFactTest
//
//  Created by Rushi Dolas on 10/14/18.
//  Copyright © 2018 Rushi Dolas. All rights reserved.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage

class FunFactsTableViewController: UITableViewController, FirestoreManagerDelegate {
    var userProfile: UserProfile?
    var funFacts = [FunFact]()
    var sender = ListOfFunFactsByType.submissions
    var firestore = FirestoreManager()
    var hashtagName = ""
    var landmarkName = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        switch sender {
        case .submissions:
            navigationItem.title = "User Submissions"
            firestore.downloadOtherUserData(userProfile?.uid ?? "", collection: "funFactsSubmitted") { (funFacts, error) in
                if let error = error {
                    print ("Error getting user data \(error)")
                } else {
                    self.funFacts = funFacts ?? []
                    self.tableView.reloadData()
                }
            }
        case .verifications:
            navigationItem.title = "User Verifications"
            firestore.downloadOtherUserData(userProfile?.uid ?? "", collection: "funFactsVerified") { (funFacts, error) in
                if let error = error {
                    print ("Error getting user data \(error)")
                } else {
                    self.funFacts = funFacts ?? []
                    self.tableView.reloadData()
                }
            }
        case .disputes:
            navigationItem.title = "User Disputes"
            firestore.downloadOtherUserData(userProfile?.uid ?? "", collection: "funFactsDisputed") { (funFacts, error) in
                if let error = error {
                    print ("Error getting user data \(error)")
                } else {
                    self.funFacts = funFacts ?? []
                    self.tableView.reloadData()
                }
            }
        case .rejections:
            navigationItem.title = "User Rejections"
            firestore.downloadOtherUserData(userProfile?.uid ?? "", collection: "funFactsRejected") { (funFacts, error) in
                if let error = error {
                    print ("Error getting user data \(error)")
                } else {
                    self.funFacts = funFacts ?? []
                    self.tableView.reloadData()
                }
            }
        case .hashtags:
            navigationItem.title = hashtagName
            self.tableView.reloadData()
        case .landmarks:
            navigationItem.title = landmarkName
            tableView.reloadData()
        }
    }
    func documentsDidUpdate() {
        
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        var numOfSections: Int = 0
        if funFacts.count > 0 {
            tableView.separatorStyle = .singleLine
            numOfSections = 1
            tableView.backgroundView = nil
        } else {
            let noDataLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text = "No data available"
            noDataLabel.textColor = UIColor.black
            noDataLabel.textAlignment = .center
            tableView.backgroundView = noDataLabel
            tableView.separatorStyle = .none
        }
        return numOfSections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return funFacts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! UserSubsCell
        let index = indexPath.row as Int
        cell.funFactDescription.text = self.funFacts[index].description
        cell.landmarkName.text = self.funFacts[index].landmarkName
        setupImage(index: index, completion: { (image) in
            cell.funFactImage.image = image
        })
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showFunFactDetail", sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showFunFactDetail" {
            let index = (sender as! NSIndexPath).row
            let contentVC = segue.destination as? ContentViewController
            
            contentVC!.funFact = self.funFacts[index]
            contentVC?.landmarkID = self.funFacts[index].landmarkId
        }
    }
    func setupImage(index: Int, completion: @escaping (UIImage) -> ()) {
        let funFactImage = UIImageView()
        let imageId = self.funFacts[index].image
        let imageName = "\(imageId).jpeg"
        
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let gsReference = storageRef.child("images/\(imageName)")
        
        gsReference.downloadURL { (url, error) in
            if let error = error {
                print ("Error getting url \(error)")
            } else {
                funFactImage.sd_setImage(with: url, placeholderImage: UIImage())
                funFactImage.layer.cornerRadius = 5
                completion(funFactImage.image!)
            }
        }
    }
}
