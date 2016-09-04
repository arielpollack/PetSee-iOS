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
    
    private static let userTokenKey = "ps_user_token"
    private static let authenticatedUserKey = "ps_authenticated_user"
    
    static var userToken: String? {
        get {
            return NSUserDefaults.standardUserDefaults().objectForKey(userTokenKey) as? String
        }
        set {
            NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: userTokenKey)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    static var authenticatedUser: User? {
        get {
            guard let json = NSUserDefaults.standardUserDefaults().objectForKey(authenticatedUserKey) as? JSON else {
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
                NSUserDefaults.standardUserDefaults().setObject(nil, forKey: authenticatedUserKey)
                NSUserDefaults.standardUserDefaults().synchronize()
                return
            }
            let json = user.toJSON()
            NSUserDefaults.standardUserDefaults().setObject(json, forKey: authenticatedUserKey)
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
}