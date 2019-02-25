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

class UserSubsTableViewController: UITableViewController, FirestoreManagerDelegate {
    var userProfile: UserProfile?
    var funFacts: [FunFact]?
    var landmarksDict: [String: String]?
    var sender: String?
    var firestore = FirestoreManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
//        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
//        navigationController?.navigationBar.shadowImage = UIImage()
        if let customFont = UIFont(name: "AvenirNext-Bold", size: 30.0) {
            navigationController?.navigationBar.largeTitleTextAttributes = [ NSAttributedString.Key.foregroundColor: UIColor.black, NSAttributedString.Key.font: customFont ]
        }
        switch sender {
        case "sub":
            navigationItem.title = "User Submissions"
            firestore.downloadOtherUserData(userProfile?.uid ?? "", collection: "funFactsSubmitted") { (refs) in
                for ref in refs {
                    self.firestore.downloadFunFacts(for: ref, completionHandler: { (funFact) in
                        self.funFacts?.append(funFact)
                        self.tableView.reloadData()
                    })
                }
            }
        case "ver":
            navigationItem.title = "User Verifications"
            firestore.downloadOtherUserData(userProfile?.uid ?? "", collection: "funFactsVerified") { (refs) in
                for ref in refs {
                    self.firestore.downloadFunFacts(for: ref, completionHandler: { (funFact) in
                        self.funFacts?.append(funFact)
                        self.tableView.reloadData()
                    })
                }
            }
        case "disp":
            navigationItem.title = "User Disputes"
            firestore.downloadOtherUserData(userProfile?.uid ?? "", collection: "funFactsDisputed") { (refs) in
                for ref in refs {
                    self.firestore.downloadFunFacts(for: ref, completionHandler: { (funFact) in
                        self.funFacts?.append(funFact)
                        self.tableView.reloadData()
                    })
                }
            }
        case "rej":
            navigationItem.title = "User Rejections"
            firestore.downloadOtherUserData(userProfile?.uid ?? "", collection: "funFactsRejected") { (refs) in
                for ref in refs {
                    self.firestore.downloadFunFacts(for: ref, completionHandler: { (funFact) in
                        self.funFacts?.append(funFact)
                        self.tableView.reloadData()
                    })
                }
            }
        default:
            navigationItem.title = "User Submissions"
            firestore.downloadOtherUserData(userProfile?.uid ?? "", collection: "funFactsSubmitted") { (refs) in
                for ref in refs {
                    self.firestore.downloadFunFacts(for: ref, completionHandler: { (funFact) in
                        self.funFacts?.append(funFact)
                        self.tableView.reloadData()
                    })
                }
            }
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    func documentsDidUpdate() {
        
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        var numOfSections: Int = 0
        if funFacts?.count ?? 0 > 0 {
            tableView.separatorStyle = .singleLine
            numOfSections            = 1
            tableView.backgroundView = nil
        } else {
            let noDataLabel = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            noDataLabel.text          = "No data available"
            noDataLabel.textColor     = UIColor.black
            noDataLabel.textAlignment = .center
            tableView.backgroundView  = noDataLabel
            tableView.separatorStyle  = .none
        }
        return numOfSections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return funFacts!.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! UserSubsCell
        let index = indexPath.row as Int
        cell.funFactDescription.text = self.funFacts?[index].description
        cell.landmarkName.text = self.landmarksDict?[self.funFacts?[index].landmarkId ?? ""]
        cell.funFactImage.image = setupImage(index: index)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showFunFactDetail", sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showFunFactDetail" {
            let index = (sender as! NSIndexPath).row
            let contentVC = segue.destination as? ContentViewController
            
            contentVC!.dataObject = self.funFacts![index].id as AnyObject
            contentVC!.funFactDesc = self.funFacts![index].description as String
            contentVC!.imageObject = self.funFacts![index].image as AnyObject
            contentVC!.submittedByObject = self.funFacts![index].submittedBy as AnyObject
            contentVC!.dateObject = self.funFacts![index].dateSubmitted as AnyObject
            contentVC!.sourceObject = self.funFacts![index].source as AnyObject
            contentVC!.verifiedFlag = self.funFacts![index].verificationFlag
            contentVC!.disputeFlag = self.funFacts![index].disputeFlag
            contentVC!.imageCaption = self.funFacts![index].imageCaption
            contentVC!.tags = self.funFacts![index].tags
            contentVC?.landmarkID = self.funFacts![index].landmarkId
            contentVC!.likesObject = self.funFacts![index].likes as AnyObject
            contentVC!.dislikesObject = self.funFacts![index].dislikes as AnyObject
            contentVC!.funFactID = self.funFacts![index].id
            contentVC!.headingObject = self.landmarksDict?[self.funFacts?[index].landmarkId ?? ""] as AnyObject
        }
    }
    func setupImage(index: Int) -> UIImage {
        let funFactImage = UIImageView()
        let imageId = self.funFacts![index].id
        let imageName = "\(imageId).jpeg"
        let imageFromCache = CacheManager.shared.getFromCache(key: imageName) as? UIImage
        if imageFromCache != nil {
            print("******In cache")
            funFactImage.image = imageFromCache
            funFactImage.layer.cornerRadius = 5
        } else {
            let storage = Storage.storage()
            let storageRef = storage.reference()
            let gsReference = storageRef.child("images/\(imageName)")
            funFactImage.sd_setImage(with: gsReference, placeholderImage: UIImage())
            funFactImage.layer.cornerRadius = 5
        }
        return funFactImage.image!
    }

}
