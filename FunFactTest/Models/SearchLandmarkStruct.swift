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
    var address: String? { return json["address"] as? String }
}
