//
//  Review.swift
//  Petsee
//
//  Created by Ariel Pollack on 28/04/2016.
//  Copyright © 2016 Ariel Pollack. All rights reserved.
//

import Foundation
import ObjectMapper

public class Review: Mappable, Identifiable {
    
    public var id: Int!
    public var rate: Int!
    public var feedback: String?
    public var writer: User?
    public var user: User?
    public var createdAt: NSDate!
    public var updatedAt: NSDate!
    
    private var map: JSON?
    
    required public init?(_ map: Map) {
        
    }
    
    public func mapping(map: Map) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        let dateFormatterTransform = DateFormatterTransform(dateFormatter: dateFormatter)

        rate <- map["rate"]
        feedback <- map["feedback"]
        writer <- map["writer"]
        user <- map["user"]
        createdAt <- (map["created_at"], dateFormatterTransform)
        updatedAt <- (map["updated_at"], dateFormatterTransform)
        
        #if DEBUG
            self.map = map.JSONDictionary
        #endif
    }
}

extension Review: CustomStringConvertible {
    public var description: String {
        if let map = self.map {
            return map.description
        }
        
        let comps: JSON = ["rate": rate,
                           "id": id,
                           "user": user?.id ?? 0,
                           "writer": writer?.id ?? 0]
        return comps.description
    }
}