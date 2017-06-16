//
//  Review.swift
//  Petsee
//
//  Created by Ariel Pollack on 28/04/2016.
//  Copyright © 2016 Ariel Pollack. All rights reserved.
//

import Foundation
import ObjectMapper

class Review: Mappable, Identifiable {
    
    var id: Int!
    var rate: Int!
    var feedback: String?
    var writer: User?
    var user: User?
    var createdAt: Date!
    var updatedAt: Date!
    
    fileprivate var map: JSON?
    
    required init?(map: Map) {
        if map.JSON["id"] == nil {
            return nil
        }
    }
    
    init() {}
    
    func mapping(map: Map) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        let dateFormatterTransform = DateFormatterTransform(dateFormatter: dateFormatter)

        id <- map["id"]
        rate <- map["rate"]
        feedback <- map["feedback"]
        writer <- map["writer"]
        user <- map["user"]
        createdAt <- (map["created_at"], dateFormatterTransform)
        updatedAt <- (map["updated_at"], dateFormatterTransform)
        
        #if DEBUG
            self.map = map.JSON
        #endif
    }
}

extension Review: CustomStringConvertible {
    var description: String {
        if let map = self.map {
            return map.description
        }
        
        let comps: JSON = ["rate": rate as AnyObject,
                           "id": id as AnyObject,
                           "user": user?.id ?? 0,
                           "writer": writer?.id ?? 0]
        return comps.description
    }
}
