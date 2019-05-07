//
//  CacheManager.swift
//  FunFactTest
//
//  Created by Rushi Dolas on 8/23/18.
//  Copyright © 2018 Rushi Dolas. All rights reserved.
//

import Foundation

enum CacheConfiguration {
    static let maxObjects = 100
    static let maxSize = 1024 * 1024 * 100
}

final class CacheManager {
    
    static let shared: CacheManager = CacheManager()
    private static var cache: NSCache<NSString, AnyObject> = {
        let cache = NSCache<NSString, AnyObject>()
        cache.countLimit = CacheConfiguration.maxObjects
        cache.totalCostLimit = CacheConfiguration.maxSize
        
        return cache
    }()
    
    private init() { }  
    
    func cache(object: AnyObject, key: String) {
        CacheManager.cache.setObject(object, forKey: key as NSString)
    }
    
    func getFromCache(key: String) -> AnyObject? {
        return CacheManager.cache.object(forKey: key as NSString)
    }
    
    func checkIfImageExists(imageName: String) -> Bool {
        return CacheManager.cache.object(forKey: imageName as NSString) == nil ? false : true
    }
    
    func replaceImage(imageName: String, image: AnyObject) {
        CacheManager.cache.setObject(image, forKey: imageName as NSString)
    }
    
    func removeImage(key: String) {
        CacheManager.cache.removeObject(forKey: key as NSString)
    }
}
