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
    
    enum `Type`: Int {
        case requestYourService = 1
        case approvedYourRequest = 2
        case confirmedYouAsProvider = 3
        case serviceStarted = 4
        case serviceEnded = 5
        case serviceCancelled = 6
    }
    
    var id: Int!
    var text: String!
    var type: Type!
    var read: Bool!
    var object: AnyObject?
    var createdAt: Date!
    
    required init?(map: Map) {
        if map.JSON["id"] == nil {
            return nil
        }
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        text <- map["text"]
        type <- map["type"]
        read <- map["read"]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
        createdAt <- (map["created_at"], DateFormatterTransform(dateFormatter: dateFormatter))
        
        switch type! {
        case .requestYourService:
            var request: ServiceRequest?
            request <- map["object"]
            object = request
            
        default:
            var service: Service?
            service <- map["object"]
            object = service
        }
    }
}
