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
    
    fileprivate struct Keys {
        static let userTokenKey = "ps_user_token"
        static let authenticatedUserKey = "ps_authenticated_user"
        static let lastTrackedServices = "ps_last_tracked_services"
        static let lastNotificationsUpdate = "ps_last_notifications_update"
    }
    
    static var userToken: String? {
        get {
            return UserDefaults.standard.object(forKey: Keys.userTokenKey) as? String
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.userTokenKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    static var authenticatedUser: User? {
        get {
            guard let json = UserDefaults.standard.object(forKey: Keys.authenticatedUserKey) as? JSON else {
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
                UserDefaults.standard.set(nil, forKey: Keys.authenticatedUserKey)
                UserDefaults.standard.synchronize()
                return
            }
            let json = user.toJSON()
            UserDefaults.standard.set(json, forKey: Keys.authenticatedUserKey)
        }
    }
    
    static var lastTrackedServices: [Service] {
        get {
            guard let jsonArray = UserDefaults.standard.object(forKey: Keys.lastTrackedServices) as? [JSON] else {
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
            UserDefaults.standard.set(servicesJSON, forKey: Keys.lastTrackedServices)
            UserDefaults.standard.synchronize()
        }
    }
}
