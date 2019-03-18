//
//  AlgoliaManager.swift
//  FunFactTest
//
//  Created by Rushi Dolas on 2/20/19.
//  Copyright © 2019 Rushi Dolas. All rights reserved.
//

import InstantSearch
import Foundation

private let DEFAULTS_KEY_MIRRORED       = "algolia.mirrored"
private let DEFAULTS_KEY_STRATEGY       = "algolia.requestStrategy"
private let DEFAULTS_KEY_TIMEOUT        = "algolia.offlineFallbackTimeout"

class AlgoliaManager: NSObject {
    /// The singleton instance.
    static let sharedInstance = AlgoliaManager()
    
    let client: Client
    var landmarkIndex: Index
    var hashtagIndex: Index
    var usersIndex: Index
    
    private override init() {
        let apiKey = Bundle.main.infoDictionary!["AlgoliaApiKey"] as! String
        client = Client(appID: "P1NWQ6JXG6", apiKey: apiKey)
        
        landmarkIndex = client.index(withName: "landmark_name")
        landmarkIndex.setSettings([
            "searchableAttributes": ["name,address,city,country","country"],
            "ranking": ["desc(likes)"]
            ])
        
        hashtagIndex = client.index(withName: "hashtag_name")
        hashtagIndex.setSettings([
            "searchableAttributes": ["name"],
            "ranking": ["desc(count)"]
            ])
        
        usersIndex = client.index(withName: "user_profile")
        usersIndex.setSettings([
            "searchableAttributes": ["name,userName"]
            ])
    }
}
