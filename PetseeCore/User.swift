//
//  User.swift
//  Petsee
//
//  Created by Ariel Pollack on 28/04/2016.
//  Copyright © 2016 Ariel Pollack. All rights reserved.
//

import Foundation
import ObjectMapper

public enum UserType: String {
    case Client = "Client"
    case ServiceProvider = "ServiceProvider"
}

 public class User: Mappable, Identifiable {
    
    public var id: Int!
    public var email: String?
    public var token: String?
    public var name: String?
    public var phone: String?
    public var about: String?
    public var image: String?
    public var ratingCount: Int?
    public var rating: Double?
    
    private var map: JSON?
    
    required public init?(_ map: Map) {
        if map.JSONDictionary["id"] == nil {
            return nil
        }
    }
    
    public func mapping(map: Map) {
        id <- map["id"]
        email <- map["email"]
        name <- map["name"]
        phone <- map["phone"]
        about <- map["about"]
        image <- map["image"]
        rating <- map["rating"]
        ratingCount <- map["rating_count"]
        token <- map["token"]
        
        #if DEBUG
            self.map = map.JSONDictionary
        #endif
    }
}

extension User: CustomStringConvertible {
    public var description: String {
        if let map = self.map {
            return map.description
        }
        
        let comps: [String: AnyObject] = ["id": id,
                                          "name": name ?? "empty",
                                          "email": email ?? "empty"]
        return comps.description
    }
}