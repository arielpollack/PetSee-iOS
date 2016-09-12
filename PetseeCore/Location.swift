//
//  Location.swift
//  Petsee
//
//  Created by Ariel Pollack on 21/08/2016.
//  Copyright © 2016 Ariel Pollack. All rights reserved.
//

import Foundation
import ObjectMapper

class Location: Mappable {
    
    var latitude: Double!
    var longitude: Double!
    var timestamp: NSDate!
    
    required init?(_ map: Map) {
        
    }
    
    init() {
        
    }
    
    func mapping(map: Map) {
        latitude <- map["latitude"]
        longitude <- map["longitude"]
        timestamp <- (map["timestamp"], DateTransform())
    }
}