//
//  Service.swift
//  Petsee
//
//  Created by Ariel Pollack on 28/04/2016.
//  Copyright © 2016 Ariel Pollack. All rights reserved.
//

import Foundation
import ObjectMapper

enum ServiceStatus: String {
    case Pending = "pending"
    case Confirmed = "confirmed"
    case InProgress = "in_progress"
    case Ended = "ended"
}

enum ServiceType: String {
    case Walking = "walking"
    case Sitting = "sitting"
}

class Service: Mappable {
    
    var client: Client!
    var serviceProvider: ServiceProvider?
    var pet: Pet!
    var startDate: NSDate!
    var endDate: NSDate!
    var status: ServiceStatus!
    var type: ServiceType!
    
    required init?(_ map: Map) {
        
    }
    
    func mapping(map: Map) {
        client <- map["client"]
        serviceProvider <- map["service_provider"]
        pet <- map["pet"]
        startDate <- map["time_start"]
        endDate <- map["time_end"]
        type <- map["type"]
    }
}