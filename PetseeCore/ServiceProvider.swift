//
//  ServiceProvider.swift
//  Petsee
//
//  Created by Ariel Pollack on 28/04/2016.
//  Copyright © 2016 Ariel Pollack. All rights reserved.
//

import Foundation
import ObjectMapper

class ServiceProvider: User {
    
    var hourlyRate: Int!
    var skills: [ServiceProviderSkill]?
    
    required init?(map: Map) {
        super.init(map: map)
    }
    
    override func mapping(map: Map) {
        super.mapping(map: map)
        
        skills <- map["skills"]
        hourlyRate <- map["hourly_rate"]
    }
}
