//
//  Race.swift
//  Petsee
//
//  Created by Ariel Pollack on 07/05/2016.
//  Copyright © 2016 Ariel Pollack. All rights reserved.
//

import Foundation
import ObjectMapper

class Race: Mappable, Identifiable {
    var id: Int!
    var name: String!
    var image: String?
    
    required init?(map: Map) {
        if map.JSON["id"] == nil {
            return nil
        }
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
        image <- map["image"]
    }
}

extension Race: CustomStringConvertible {
    var description: String {
        return name
    }
}
