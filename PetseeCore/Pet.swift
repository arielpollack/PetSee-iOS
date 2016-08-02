//
//  Pet.swift
//  Petsee
//
//  Created by Ariel Pollack on 28/04/2016.
//  Copyright © 2016 Ariel Pollack. All rights reserved.
//

import Foundation
import ObjectMapper

public class Pet: Mappable, Identifiable {
    
    public var id: Int!
    public var name: String!
    public var race: Race!
    public var color: String!
    public var about: String?
    public var image: String?
    public var isTrained: Bool!
    public var birthday: NSDate!
    
    private var map: JSON?
    
    public init() {
        
    }
    
    required public init?(_ map: Map) {
        
    }
    
    public func mapping(map: Map) {
        name <- map["name"]
        race <- map["race"]
        color <- map["color"]
        about <- map["about"]
        image <- map["image"]
        isTrained <- map["is_trained"]
        birthday <- map["birthday"]
        
        #if DEBUG
            self.map = map.JSONDictionary
        #endif
    }
}

extension Pet: CustomStringConvertible {
    public var description: String {
        if let map = self.map {
            return map.description
        }
        
        let comps = ["name": name,
                     "race": race,
                     "color": color]
        return comps.description
    }
}