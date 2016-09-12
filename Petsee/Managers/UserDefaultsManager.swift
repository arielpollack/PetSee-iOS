//
//  UserDefaultsManager.swift
//  Petsee
//
//  Created by Ariel Pollack on 08/05/2016.
//  Copyright © 2016 Ariel Pollack. All rights reserved.
//

import Foundation
import ObjectMapper

struct UserDefaultsManager {
    
    private struct Keys {
        static let userTokenKey = "ps_user_token"
        static let authenticatedUserKey = "ps_authenticated_user"
        static let lastTrackedServices = "ps_last_tracked_services"
        static let lastNotificationsUpdate = "ps_last_notifications_update"
    }
    
    static var userToken: String? {
        get {
            return NSUserDefaults.standardUserDefaults().objectForKey(Keys.userTokenKey) as? String
        }
        set {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: Keys.userTokenKey)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    static var authenticatedUser: User? {
        get {
            guard let json = NSUserDefaults.standardUserDefaults().objectForKey(Keys.authenticatedUserKey) as? JSON else {
                return nil
            }
            guard let user = User(JSON: json) else {
                self.authenticatedUser = nil
                return nil
            }
            return user
        }
        set {
            guard let user = newValue else {
                NSUserDefaults.standardUserDefaults().setObject(nil, forKey: Keys.authenticatedUserKey)
                NSUserDefaults.standardUserDefaults().synchronize()
                return
            }
            let json = user.toJSON()
            NSUserDefaults.standardUserDefaults().setObject(json, forKey: Keys.authenticatedUserKey)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    static var lastTrackedServices: [Service] {
        get {
            guard let jsonArray = NSUserDefaults.standardUserDefaults().objectForKey(Keys.lastTrackedServices) as? [JSON] else {
                return []
            }
            var services = [Service]()
            for json in jsonArray {
                if let service = Service(JSON: json) {
                    services.append(service)
                }
            }
            return services
        }
        set {
            var servicesJSON = [JSON]()
            for service in newValue {
                servicesJSON.append(service.toJSON())
            }
            NSUserDefaults.standardUserDefaults().setObject(servicesJSON, forKey: Keys.lastTrackedServices)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
}