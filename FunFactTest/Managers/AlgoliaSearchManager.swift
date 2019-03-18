//
//  AlgoliaSearchManager.swift
//  FunFactTest
//
//  Created by Rushi Dolas on 2/21/19.
//  Copyright © 2019 Rushi Dolas. All rights reserved.
//

import Foundation
import InstantSearch
import FirebaseFirestore

protocol AlgoliaSearchManagerDelegate: class {
    func documentsDidDownload()
}

class AlgoliaSearchManager {
    var delegate: AlgoliaSearchManagerDelegate?
    
    init() {

    }
    
    /// Get Hashtags based on searchText
    func getHashtags(searchText: String, completionHandler: @escaping ([SearchHashtag]) -> Void) {
        let hashtagQuery = Query()
        var searchHashtags = [SearchHashtag]()
        hashtagQuery.query = searchText
        hashtagQuery.hitsPerPage = 15
        hashtagQuery.attributesToRetrieve = ["name", "count"]
        hashtagQuery.attributesToHighlight = ["name"]
        AlgoliaManager.sharedInstance.hashtagIndex.search(hashtagQuery, completionHandler: { (data, error) in
            if error != nil {
                return
            }
            // Decode JSON
            guard let hits = data!["hits"] as? [[String: AnyObject]] else { return }
            
            var tmp = [SearchHashtag]()
            for hit in hits {
                tmp.append(SearchHashtag(json: hit))
            }
            searchHashtags = tmp
            completionHandler(searchHashtags)
        })
    }
    
    /// Download landmarks from Algolia based on the query parameters in the current map bounding box
    func downloadLandmarks(query: InstantSearchClient.Query, completion: @escaping (Landmark?, String?) -> ()) {
        AlgoliaManager.sharedInstance.landmarkIndex.search(query) { (res, error) in
            if let error = error {
                completion(nil, error.localizedDescription)
            }
            else {
                guard let hits = res!["hits"] as? [[String: AnyObject]] else { return }
                if hits.isEmpty {
                    completion(nil, Errors.noRecordsFound.localizedDescription)
                    return
                }
                for hit in hits {
                    let geoloc = hit["_geoloc"] as! [String: Double]
                    let coordinates = GeoPoint(latitude: geoloc["lat"]!, longitude: geoloc["lng"]!)
                    
                    let landmark = Landmark(id: hit["objectID"] as! String,
                                            name: hit["name"] as! String,
                                            address: hit["address"] as! String,
                                            city: hit["city"] as! String,
                                            state: hit["state"] as! String,
                                            zipcode: hit["zipcode"] as! String,
                                            country: hit["country"] as! String,
                                            type: hit["type"] as! String,
                                            coordinates: coordinates,
                                            image: hit["image"] as! String,
                                            numOfFunFacts: hit["numOfFunFacts"] as! Int,
                                            likes: hit["likes"] as! Int,
                                            dislikes: hit["dislikes"] as! Int)
                    completion(landmark, nil)
                }
            }
        }
    }
}
