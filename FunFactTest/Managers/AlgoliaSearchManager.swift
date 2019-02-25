//
//  AlgoliaSearchManager.swift
//  FunFactTest
//
//  Created by Rushi Dolas on 2/21/19.
//  Copyright © 2019 Rushi Dolas. All rights reserved.
//

import Foundation
import InstantSearch

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
}
