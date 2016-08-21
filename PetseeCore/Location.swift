//
//  Location.swift
//  Petsee
//
//  Created by Ariel Pollack on 21/08/2016.
//  Copyright © 2016 Ariel Pollack. All rights reserved.
//

import Foundation
import ObjectMapper

public class Location: Mappable {
    
    public var latitude: Double!
    public var longitude: Double!
    public var timestamp: NSDate!
    
    required public init?(_ map: Map) {
        
    }
    
    public func mapping(map: Map) {
        latitude <- map["latitude"]
        longitude <- map["longitude"]
        timestamp <- (map["timestamp"], DateTransform())
    }
}