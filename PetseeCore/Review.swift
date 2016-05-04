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
    public var createdAt: NSDate?
    public var updatedAt: NSDate?
    
    required public init?(_ map: Map) {
        
    }
    
    public func mapping(map: Map) {
        rate <- map["rate"]
        feedback <- map["feedback"]
        writer <- map["writer"]
        user <- map["user"]
        createdAt <- map["created_at"]
        updatedAt <- map["updated_at"]
    }
}