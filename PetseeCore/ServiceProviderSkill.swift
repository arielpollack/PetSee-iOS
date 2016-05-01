//
//  ServiceProviderSkill.swift
//  Petsee
//
//  Created by Ariel Pollack on 28/04/2016.
//  Copyright © 2016 Ariel Pollack. All rights reserved.
//

import Foundation
import ObjectMapper

public class ServiceProviderSkill: Mappable {
    
    public var name: String!
    public var yearsOfExperience: Int?
    public var details: String?
    
    required public init?(_ map: Map) {
        if map["name"].value() == nil {
            return nil
        }
    }
    
    public func mapping(map: Map) {
        name <- map["name"]
        yearsOfExperience <- map["years_of_experience"]
        details <- map["details"]
    }
}