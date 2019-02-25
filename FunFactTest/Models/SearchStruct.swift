//
//  SearchLandmarkStruct.swift
//  FunFactTest
//
//  Created by Rushi Dolas on 1/14/19.
//  Copyright © 2019 Rushi Dolas. All rights reserved.
//

import Foundation
import InstantSearchClient
import InstantSearch

struct SearchLandmark {
    private let json: [String: AnyObject]
    init(json: [String: AnyObject]) {
        self.json = json
    }
    
    var image: String? { return json["image"] as? String }
    var nameHighlighted: String? { return SearchResults.highlightResult(hit: json, path: "name")?.value }
    var addressHighlighted: String? { return SearchResults.highlightResult(hit: json, path: "address")?.value }
}

struct SearchHashtag {
    private let json: [String: AnyObject]
    init(json: [String: AnyObject]) {
        self.json = json
    }

    var nameHighlighted: String? { return SearchResults.highlightResult(hit: json, path: "name")?.value }
    var count: Int? { return json["count"] as? Int }
    var image: String? { return json["image"] as? String }
}

struct SearchUsers {
    private let json: [String: AnyObject]
    init(json: [String: AnyObject]) {
        self.json = json
    }
    
    var nameHighlighted: String? { return SearchResults.highlightResult(hit: json, path: "name")?.value }
    var userNameHighlighted: String? { return SearchResults.highlightResult(hit: json, path: "userName")?.value }
    var photoURL: String? { return json["photoURL"] as? String }
}
