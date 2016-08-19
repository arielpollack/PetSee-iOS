//
//  Service.swift
//  Petsee
//
//  Created by Ariel Pollack on 28/04/2016.
//  Copyright © 2016 Ariel Pollack. All rights reserved.
//

import Foundation
import ObjectMapper

public class Service: Mappable , Identifiable {
    
    public enum Status: String {
        case Pending = "pending"
        case Started = "started"
        case Ended = "ended"
    }
    
    public enum Type: String {
        case Walking = "dogwalk"
        case Sitting = "dogsit"
    }
    
    public var id: Int!
    public var client: Client!
    public var serviceProvider: ServiceProvider?
    public var pet: Pet!
    public var startDate: NSDate!
    public var endDate: NSDate!
    public var status: Status!
    public var type: Type!
    
    required public init?(_ map: Map) {
        
    }
    
    public func mapping(map: Map) {
        client <- map["client"]
        serviceProvider <- map["service_provider"]
        pet <- map["pet"]
        startDate <- map["time_start"]
        endDate <- map["time_end"]
        type <- map["type"]
    }
}