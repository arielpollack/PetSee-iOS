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
    case signup(email: String, password: String, name: String?, type: UserType)
    case login(email: String, password: String)
    case checkEmailExist(email: String)
}

extension PetseeAuth: TargetType {
    var baseURL: URL { return URL(string: "https://petsee.herokuapp.com/auth")! }
//    var baseURL: NSURL { return NSURL(string: "http://localhost:3000/auth")! }
    var path: String {
        switch self {
        case .signup:
            return "/signup"
        case .login:
            return "/login"
        case .checkEmailExist:
            return "/is_email_exist"
        }
    }
    var method: Moya.Method {
        switch self {
        case .checkEmailExist:
            return .get
        default:
            return .post
        }
    }
    var parameters: [String : Any]? {
        switch self {
        case .signup(let email, let password, let name, let type):
            var params = ["email": email, "password": password, "type": type.rawValue]
            params["name"] = name
            return params as [String : AnyObject]
        case .login(let email, let password):
            return ["email": email as AnyObject, "password": password as AnyObject]
        case .checkEmailExist(let email):
            return ["email": email as AnyObject]
        }
    }
    var parameterEncoding: ParameterEncoding {
        switch self {
        case .checkEmailExist:
            return URLEncoding()
        default:
            return JSONEncoding()
        }
    }
    var task: Task {
        return .request
    }
    var sampleData: Data {
        return Data()
    }
}
