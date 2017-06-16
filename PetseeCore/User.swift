//
//  User.swift
//  Petsee
//
//  Created by Ariel Pollack on 28/04/2016.
//  Copyright © 2016 Ariel Pollack. All rights reserved.
//

import Foundation
import ObjectMapper

enum UserType: String {
    case Client = "Client"
    case ServiceProvider = "ServiceProvider"
}

 class User: Mappable, Identifiable {
    
    var id: Int!
    var email: String?
    var token: String?
    var name: String?
    var phone: String?
    var about: String?
    var image: String?
    var ratingCount: Int?
    var rating: Double?
    var type: UserType?
    
    fileprivate var map: JSON?
    
    required init?(map: Map) {
        if map.JSON["id"] == nil {
            return nil
        }
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        email <- map["email"]
        name <- map["name"]
        phone <- map["phone"]
        about <- map["about"]
        image <- map["image"]
        rating <- map["rating"]
        ratingCount <- map["rating_count"]
        token <- map["token"]
        type <- map["type"]
        
        #if DEBUG
            self.map = map.JSON as JSON
        #endif
    }
}

extension User: CustomStringConvertible {
    var description: String {
        if let map = self.map {
            return map.description
        }
        
        let comps: [String: String] = ["id": "\(id)",
                                          "name": name ?? "empty" ,
                                          "email": email ?? "empty"]
        return comps.description
    }
}
