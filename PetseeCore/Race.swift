//
//  Race.swift
//  Petsee
//
//  Created by Ariel Pollack on 07/05/2016.
//  Copyright © 2016 Ariel Pollack. All rights reserved.
//

import Foundation
import ObjectMapper

public class Race: Mappable, Identifiable {
    public var id: Int!
    public var name: String!
    public var image: String!
    
    required public init?(_ map: Map) {
        
    }
    
    public func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        image <- map["image"]
    }
}

extension Race: CustomStringConvertible {
    public var description: String {
        return name
    }
}