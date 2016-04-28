//
//  Review.swift
//  Petsee
//
//  Created by Ariel Pollack on 28/04/2016.
//  Copyright © 2016 Ariel Pollack. All rights reserved.
//

import Foundation
import ObjectMapper

class Review: Mappable {
    
    var rate: Double!
    var feedback: String?
    var writer: User?
    var user: User?
    var createdAt: NSDate?
    var updatedAt: NSDate?
    
    required init?(_ map: Map) {
        
    }
    
    func mapping(map: Map) {
        rate <- map["rate"]
        feedback <- map["feedback"]
        writer <- map["writer"]
        user <- map["user"]
        createdAt <- map["created_at"]
        updatedAt <- map["updated_at"]
    }
}