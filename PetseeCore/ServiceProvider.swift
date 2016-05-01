//
//  ServiceProvider.swift
//  Petsee
//
//  Created by Ariel Pollack on 28/04/2016.
//  Copyright © 2016 Ariel Pollack. All rights reserved.
//

import Foundation
import ObjectMapper

public class ServiceProvider: User {
    
    public var skills: [ServiceProviderSkill]?
    
    required public init?(_ map: Map) {
        super.init(map)
    }
    
    override public func mapping(map: Map) {
        super.mapping(map)
        
        skills <- map["skills"]
    }
}