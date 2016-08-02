//
//  AuthManager.swift
//  Petsee
//
//  Created by Ariel Pollack on 04/05/2016.
//  Copyright © 2016 Ariel Pollack. All rights reserved.
//

import PetseeCore
import PetseeNetwork

protocol AuthManagerProtocol {
    var authenticatedUser: User? { get }
    
    func isLoggedIn() -> Bool
    
    func setAuthenticatedUser(user: User)
    func clearAuthenticatedUser()
}

class AuthManager: AuthManagerProtocol {
    var authenticatedUser: User?
    
    static var sharedInstance = AuthManager()
    
    init() {
        authenticatedUser = UserDefaultsManager.authenticatedUser
        if let user = authenticatedUser {
            PetseeAPI.setAuthenticationToken(user.token!)
        }
    }
    
    func isLoggedIn() -> Bool {
        return authenticatedUser != nil
    }
    
    func setAuthenticatedUser(user: User) {
        authenticatedUser = user
        UserDefaultsManager.userToken = user.token
    }
    
    func clearAuthenticatedUser() {
        authenticatedUser = nil
        UserDefaultsManager.userToken = nil
    }
}