//
//  Pet.swift
//  Petsee
//
//  Created by Ariel Pollack on 28/04/2016.
//  Copyright © 2016 Ariel Pollack. All rights reserved.
//

import Foundation
import ObjectMapper

class Pet: Mappable, Identifiable {
    
    var id: Int!
    var name: String!
    var race: Race!
    var color: String!
    var about: String?
    var image: String?
    var isTrained: Bool!
    var birthday: NSDate!
    
    private var map: JSON?
    
    init() {
        
    }
    
    required init?(_ map: Map) {
        if map.JSONDictionary["id"] == nil {
            return nil
        }
    }
    
    func mapping(map: Map) {
        id <- map["id"]
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
    var description: String {
        if let map = self.map {
            return map.description
        }
        
        let comps = ["name": name,
                     "race": race,
                     "color": color]
        return comps.description
    }
}

extension Pet: Equatable {}

func ==(lhs: Pet, rhs: Pet) -> Bool {
    return lhs.id == rhs.id
}