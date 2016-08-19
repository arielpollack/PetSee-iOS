//
//  ServiceRequest.swift
//  Petsee
//
//  Created by Ariel Pollack on 20/08/2016.
//  Copyright © 2016 Ariel Pollack. All rights reserved.
//

import Foundation
import ObjectMapper

public class ServiceRequest: Mappable, Identifiable {
    
    public enum Status: String {
        case Pending = "pending"
        case Approved = "approved"
        case Denied = "denied"
    }
    
    public var id: Int!
    public var serviceProvider: ServiceProvider!
    public var status: Status!
    
    required public init?(_ map: Map) {
        
    }
    
    public func mapping(map: Map) {
        serviceProvider <- map["service_provider"]
        status <- map["status"]
    }
}