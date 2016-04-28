//
//  Pet.swift
//  Petsee
//
//  Created by Ariel Pollack on 28/04/2016.
//  Copyright © 2016 Ariel Pollack. All rights reserved.
//

import Foundation
import ObjectMapper

class Pet: Mappable {
    
    var name: String!
    var race: String!
    var color: String!
    var about: String?
    var image: String?
    var isTrained: Bool!
    var birthday: NSDate!
    
    required init?(_ map: Map) {
        
    }
    
    func mapping(map: Map) {
        name <- map["name"]
        race <- map["race"]
        color <- map["color"]
        about <- map["about"]
        image <- map["image"]
        isTrained <- map["is_trained"]
        birthday <- map["birthday"]
    }
}