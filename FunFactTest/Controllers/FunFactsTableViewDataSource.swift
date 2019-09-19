//
//  FunFactsTableViewDataSource.swift
//  FunFactTest
//
//  Created by Rushi Dolas on 8/7/19.
//  Copyright © 2019 Rushi Dolas. All rights reserved.
//

import UIKit
import Firebase

@objc class FunFactsTableViewDataSource: NSObject, UITableViewDataSource {
    var funFactMinis: [FunFactMini] = []
    var documents: [QueryDocumentSnapshot] = []
    let updateHandler: () -> ()
    let query: Query
    var isFetchingUpdates = false
    var sender = ListOfFunFactsByType.submissions
    
    // MARK: - UITableViewDataSource
    
    public init(query: Query, updateHandler: @escaping () -> ()) {
        self.query = query
        self.updateHandler = updateHandler
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! UserSubsCell
        let index = indexPath.row as Int
        cell.funFactDescription.text = self.funFactMinis[index].description
        cell.landmarkName.text = self.funFactMinis[index].landmarkName
        setupImage(index: index, completion: { (image) in
            cell.funFactImage.image = image
        })
        return cell
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        var numOfSections: Int = 0
        if funFactMinis.count > 0 {
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
    
    public func fetchNext() {
        if isFetchingUpdates {
            return
        }
        isFetchingUpdates = true
        
        let nextQuery: Query
        if let lastDocument = documents.last {
            nextQuery = query.start(afterDocument: lastDocument).limit(to: 10)
        } else {
            nextQuery = query.limit(to: 10)
        }
        
        nextQuery.getDocuments { (querySnapshot, error) in
            guard let snapshot = querySnapshot else {
                print("Error fetching next documents: \(error!)")
                self.isFetchingUpdates = false
                return
            }
            if snapshot.count == 0 {
                return
            }
            for document in querySnapshot!.documents {
                let funFactMini = FunFactMini(landmarkName: document.data()["landmarkName"] as! String,
                                              id: document.data()["id"] as! String,
                                              description: document.data()["description"] as! String)
                self.funFactMinis.append(funFactMini)
            }
            self.documents += snapshot.documents
            self.updateHandler()
            self.isFetchingUpdates = false
        }
    }
    /// Returns the funFact after the given index.
    public subscript(index: Int) -> FunFactMini {
        return funFactMinis[index]
    }
    
    /// The number of items in the data source.
    public var count: Int {
        return funFactMinis.count
    }
    
    func setupImage(index: Int, completion: @escaping (UIImage) -> ()) {
        let funFactImage = UIImageView()
        let imageId = self.funFactMinis[index].id
        let imageName = "\(imageId).jpeg"
        let imageFromCache = CacheManager.shared.getFromCache(key: imageName) as? UIImage
        if imageFromCache != nil {
            funFactImage.image = imageFromCache
        } else {
            let storage = Storage.storage()
            let storageRef = storage.reference()
            let gsReference = storageRef.child("images/\(imageName)")
            
            gsReference.downloadURL { (url, error) in
                if let error = error {
                    print ("Error getting url \(error)")
                } else {
                    funFactImage.sd_setImage(with: url,
                                             placeholderImage: UIImage.fontAwesomeIcon(name: .image,
                                                                                       style: .regular,
                                                                                       textColor: .lightGray,
                                                                                       size: CGSize(width: 50, height: 50)))
                    funFactImage.layer.cornerRadius = 5
                    completion(funFactImage.image!)
                }
            }
        }
    }
}
