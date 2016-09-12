//
//  Service.swift
//  Petsee
//
//  Created by Ariel Pollack on 28/04/2016.
//  Copyright © 2016 Ariel Pollack. All rights reserved.
//

import Foundation
import ObjectMapper

class Service: Mappable , Identifiable {
    
    enum Status: String {
        case Pending = "pending"
        case Confirmed = "confirmed"
        case Started = "started"
        case Ended = "ended"
        case Cancelled = "cancelled"
        
        var readableString: String {
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
        
        var presentingColor: UIColor {
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
    
    enum Type: String {
        case Walking = "dogwalk"
        case Sitting = "dogsit"
        
        var readableString: String {
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
    
    var id: Int!
    var client: Client!
    var serviceProvider: ServiceProvider?
    var pet: Pet!
    var startDate: NSDate!
    var endDate: NSDate!
    var status: Status!
    var location: Location!
    var type: Type!
    
    init() {
        
    }
    
    required init?(_ map: Map) {
        if map.JSONDictionary["id"] == nil {
            return nil
        }
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        client <- map["client"]
        serviceProvider <- map["service_provider"]
        pet <- map["pet"]
        type <- map["type"]
        status <- map["status"]
        location <- map["location"]
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
        startDate <- (map["time_start"], DateFormatterTransform(dateFormatter: dateFormatter))
        endDate <- (map["time_end"], DateFormatterTransform(dateFormatter: dateFormatter))
    }
}