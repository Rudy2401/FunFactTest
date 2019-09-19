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
    var sender = ListOfFunFactsByType.submissions
    var firestore = FirestoreManager()
    var hashtagName = ""
    var landmarkName = ""
    let collection = [ListOfFunFactsByType.submissions: "funFactsSubmitted",
                      ListOfFunFactsByType.verifications: "funFactsVerified",
                      ListOfFunFactsByType.disputes: "funFactsDisputed",
                      ListOfFunFactsByType.rejections: "funFactsRejected",
                      ListOfFunFactsByType.hashtags: "funFacts"]
    
    private lazy var baseQuery: Query = {
        if self.sender == ListOfFunFactsByType.hashtags {
            return Firestore.firestore()
                .collection("hashtags")
                .document(self.hashtagName.components(separatedBy: "#").last!)
                .collection(collection[self.sender]!)
                .order(by: "landmarkName")
                .limit(to: 10)
        } else {
            return Firestore.firestore()
                .collection("users")
                .document(self.userProfile!.uid)
                .collection(collection[self.sender]!)
                .order(by: "landmarkName")
                .limit(to: 10)
        }
    }()
    lazy private var dataSource: FunFactsTableViewDataSource = {
        return dataSourceForQuery(baseQuery)
    }()
    fileprivate var query: Query? {
        didSet {
            tableView.dataSource = nil
            if let query = query {
                dataSource = dataSourceForQuery(query)
                tableView.dataSource = dataSource
                dataSource.fetchNext() // Add this line
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        query = baseQuery
        tableView.delegate = self
        tableView.dataSource = dataSource
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.tableView.reloadData()
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    private func dataSourceForQuery(_ query: Query) -> FunFactsTableViewDataSource {
        return FunFactsTableViewDataSource(query: query) {
            self.tableView.reloadData()
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        switch sender {
        case .submissions:
            navigationItem.title = "User Submissions"
        case .verifications:
            navigationItem.title = "User Verifications"
        case .disputes:
            navigationItem.title = "User Disputes"
        case .rejections:
            navigationItem.title = "User Rejections"
        case .hashtags:
            navigationItem.title = hashtagName
        case .landmarks:
            navigationItem.title = landmarkName
        }
    }
    func documentsDidUpdate() {
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "showFunFactDetail", sender: indexPath)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showFunFactDetail" {
            let index = (sender as! NSIndexPath).row
            let contentVC = segue.destination as? ContentViewController
            
            contentVC?.sender = .table
            contentVC?.funFactMini = dataSource.funFactMinis[index]
        }
    }
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Load more rows if the user is 100 points away from scrolling to the bottom.
        let height = scrollView.frame.size.height + 100
        let contentYoffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
        if distanceFromBottom < height && dataSource.isFetchingUpdates == false {
            dataSource.fetchNext()
        }
    }
}

