//
//  ServiceProviderSkill.swift
//  Petsee
//
//  Created by Ariel Pollack on 28/04/2016.
//  Copyright © 2016 Ariel Pollack. All rights reserved.
//

import Foundation
import ObjectMapper

class ServiceProviderSkill: Mappable {
    
    var name: String!
    var yearsOfExperience: Int?
    var details: String?
    
    required init?(_ map: Map) {
        
    }
    
    func mapping(map: Map) {
        name <- map["name"]
        yearsOfExperience <- map["years_of_experience"]
        details <- map["details"]
    }
}