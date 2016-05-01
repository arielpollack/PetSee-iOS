//
//  PSRouter.swift
//  Petsee
//
//  Created by Ariel Pollack on 30/04/2016.
//  Copyright © 2016 Ariel Pollack. All rights reserved.
//

import Foundation
import PetseeCore
import Moya

enum PetseeAuth {
    case Signup(email: String, password: String, name: String?, type: UserType)
    case Login(email: String, password: String) // email, password
}

extension PetseeAuth: TargetType {
    var baseURL: NSURL { return NSURL(string: "http://localhost:3000")! }
    var path: String {
        switch self {
        case .Signup:
            return "/auth/signup"
        case .Login:
            return "/auth/login"
        }
    }
    var method: Moya.Method {
        return .POST
    }
    var parameters: [String : AnyObject]? {
        switch self {
        case .Signup(let email, let password, let name, let type):
            var params = ["email": email, "password": password, "type": type.rawValue]
            params["name"] = name
            return params
        case .Login(let email, let password):
            return ["email": email, "password": password]
        }
    }
    var sampleData: NSData {
        return NSData()
    }
}