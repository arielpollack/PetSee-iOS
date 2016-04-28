//
//  User.swift
//  Petsee
//
//  Created by Ariel Pollack on 28/04/2016.
//  Copyright © 2016 Ariel Pollack. All rights reserved.
//

import Foundation
import ObjectMapper

class User: Mappable {
    
    var email: String?
    var token: String?
    var name: String?
    var phone: String?
    var about: String?
    var image: String?
    var ratingCount: Int?
    var rating: Double?
    
    required init?(_ map: Map) {
        
    }
    
    func mapping(map: Map) {
        email <- map["email"]
        name <- map["name"]
        phone <- map["phone"]
        about <- map["about"]
        image <- map["image"]
        rating <- map["rating"]
        ratingCount <- map["rating_count"]
    }
}