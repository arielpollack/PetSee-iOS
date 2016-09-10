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
        case Confirmed = "confirmed"
        case Started = "started"
        case Ended = "ended"
        case Cancelled = "cancelled"
        
        public var readableString: String {
            get {
                switch self {
                case .Pending:
                    return "Pending"
                case .Confirmed:
                    return "Confirmed"
                case .Started:
                    return "In Progress"
                case .Ended:
                    return "Ended"
                case .Cancelled:
                    return "Cancelled"
                }
            }
        }
        
        public var presentingColor: UIColor {
            switch self {
            case .Pending:
                return UIColor.orangeColor()
            case .Confirmed:
                return UIColor.blueColor()
            case .Started:
                return UIColor.greenColor()
            case .Ended:
                return UIColor.greenColor()
            case .Cancelled:
                return UIColor.redColor()
            }
        }
    }
    
    public enum Type: String {
        case Walking = "dogwalk"
        case Sitting = "dogsit"
        
        public var readableString: String {
            get {
                switch self {
                case .Sitting:
                    return "Dogsit"
                case .Walking:
                    return "Dogwalk"
                }
            }
        }
    }
    
    public var id: Int!
    public var client: Client!
    public var serviceProvider: ServiceProvider?
    public var pet: Pet!
    public var startDate: NSDate!
    public var endDate: NSDate!
    public var status: Status!
    public var location: Location!
    public var type: Type!
    
    public init() {
        
    }
    
    required public init?(_ map: Map) {
        if map.JSONDictionary["id"] == nil {
            return nil
        }
    }
    
    public func mapping(map: Map) {
        id <- map["id"]
        client <- map["client"]
        serviceProvider <- map["service_provider"]
        pet <- map["pet"]
        startDate <- (map["time_start"], DateTransform())
        endDate <- (map["time_end"], DateTransform())
        type <- map["type"]
        status <- map["status"]
        location <- map["location"]
    }
}