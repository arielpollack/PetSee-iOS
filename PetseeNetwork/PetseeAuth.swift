//
//  PSRouter.swift
//  Petsee
//
//  Created by Ariel Pollack on 30/04/2016.
//  Copyright © 2016 Ariel Pollack. All rights reserved.
//

import Foundation
import Moya

enum PetseeAuth {
    case Signup(email: String, password: String, name: String?, type: UserType)
    case Login(email: String, password: String)
    case CheckEmailExist(email: String)
}

extension PetseeAuth: TargetType {
    var baseURL: NSURL { return NSURL(string: "https://petsee.herokuapp.com/auth")! }
//    var baseURL: NSURL { return NSURL(string: "http://localhost:3000/auth")! }
    var path: String {
        switch self {
        case .Signup:
            return "/signup"
        case .Login:
            return "/login"
        case .CheckEmailExist:
            return "/is_email_exist"
        }
    }
    var method: Moya.Method {
        switch self {
        case .CheckEmailExist:
            return .GET
        default:
            return .POST
        }
    }
    var parameters: [String : AnyObject]? {
        switch self {
        case .Signup(let email, let password, let name, let type):
            var params = ["email": email, "password": password, "type": type.rawValue]
            params["name"] = name
            return params
        case .Login(let email, let password):
            return ["email": email, "password": password]
        case .CheckEmailExist(let email):
            return ["email": email]
        }
    }
    var sampleData: NSData {
        return NSData()
    }
}