//
//  Notification.swift
//  Petsee
//
//  Created by Ariel Pollack on 12/09/2016.
//  Copyright © 2016 Ariel Pollack. All rights reserved.
//

import Foundation
import ObjectMapper

class Notification: Mappable, Identifiable {
    
    enum Type: Int {
        case RequestYourService = 1
        case ApprovedYourRequest = 2
        case ConfirmedYouAsProvider = 3
        case ServiceStarted = 4
        case ServiceEnded = 5
        case ServiceCancelled = 6
    }
    
    var id: Int!
    var text: String!
    var type: Type!
    var read: Bool!
    var object: AnyObject?
    var createdAt: NSDate!
    
    required init?(_ map: Map) {
        if map.JSONDictionary["id"] == nil {
            return nil
        }
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        text <- map["text"]
        type <- map["notification_type"]
        read <- map["read"]
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
        createdAt <- (map["created_at"], DateFormatterTransform(dateFormatter: dateFormatter))
    }
}