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

class UserSubsTableViewController: UITableViewController {
    var userProfile: User?
    var funFactsSubmitted: [FunFact]?
    var landmarksDict: [String: String]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = .darkGray
        navigationItem.title = "User Submissions"
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (userProfile?.funFactsSubmitted.count)!
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! UserSubsCell
        let index = indexPath.row as Int
        cell.funFactDescription.text = self.funFactsSubmitted?[index].description
        cell.landmarkName.text = self.landmarksDict?[self.funFactsSubmitted?[index].landmarkId ?? ""]
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
            
            contentVC!.dataObject = self.funFactsSubmitted![index].id as AnyObject
            contentVC!.funFactDesc = self.funFactsSubmitted![index].description as String
            contentVC!.imageObject = self.funFactsSubmitted![index].image as AnyObject
            contentVC!.submittedByObject = self.funFactsSubmitted![index].submittedBy as AnyObject
            contentVC!.dateObject = self.funFactsSubmitted![index].dateSubmitted as AnyObject
            contentVC!.sourceObject = self.funFactsSubmitted![index].source as AnyObject
            contentVC!.verifiedFlag = self.funFactsSubmitted![index].verificationFlag
            contentVC!.disputeFlag = self.funFactsSubmitted![index].disputeFlag
            contentVC!.imageCaption = self.funFactsSubmitted![index].imageCaption
            contentVC!.tags = self.funFactsSubmitted![index].tags
            contentVC?.landmarkID = self.funFactsSubmitted![index].landmarkId
            contentVC!.likesObject = self.funFactsSubmitted![index].likes as AnyObject
            contentVC!.dislikesObject = self.funFactsSubmitted![index].dislikes as AnyObject
            contentVC!.funFactID = self.funFactsSubmitted![index].id
            contentVC!.userProfile = userProfile!
            contentVC!.headingObject = self.landmarksDict?[self.funFactsSubmitted?[index].landmarkId ?? ""] as AnyObject
        }
    }
    func setupImage(index: Int) -> UIImage {
        let funFactImage = UIImageView()
        let imageId = self.funFactsSubmitted![index].id
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

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
