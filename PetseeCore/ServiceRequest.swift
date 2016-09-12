//
//  ServiceRequest.swift
//  Petsee
//
//  Created by Ariel Pollack on 20/08/2016.
//  Copyright © 2016 Ariel Pollack. All rights reserved.
//

import Foundation
import ObjectMapper

class ServiceRequest: Mappable, Identifiable {
    
    enum Status: String {
        case Pending = "pending"
        case Approved = "approved"
        case Denied = "denied"
        
        var readableString: String {
            switch self {
            case .Pending:
                return "Pending"
            case .Approved:
                return "Approved"
            case .Denied:
                return "Denied"
            }
        }
    }
    
    var id: Int!
    var service: Service?
    var serviceProvider: ServiceProvider!
    var status: Status!
    
    required init?(_ map: Map) {
        if map.JSONDictionary["id"] == nil {
            return nil
        }
    }
    
    func mapping(map: Map) {
        id <- map["id"]
        serviceProvider <- map["service_provider"]
        service <- map["service"]
        status <- map["status"]
    }
}