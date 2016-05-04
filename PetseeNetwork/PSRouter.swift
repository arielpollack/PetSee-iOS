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
    case Login(email: String, password: String)
    case CheckEmailExist(email: String)
}

extension PetseeAuth: TargetType {
    var baseURL: NSURL { return NSURL(string: "http://localhost:3000/auth")! }
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

enum PetseeUsers {
    case UserPets(userId: Int)
    case UserReviews(userId: Int)
    
    case CreateReview(userId: Int, rate: Int, feedback: String?)
    
    case MyPets
    case AddPet(name: String, raceId: Int)
    case UpdatePet(Pet)
    
    case MyReviews
    
    case SearchRace(query: String)
    case AddRace(name: String)
}

extension PetseeUsers: TargetType {
    var baseURL: NSURL { return NSURL(string: "http://localhost:3000")! }
    var path: String {
        switch self {
        case .UserPets(let userId):
            return "/users/\(userId)/pets"
        case .UserReviews(let userId):
            return "/users/\(userId)/reviews"
        case .CreateReview(let userId, _, _):
            return "/users/\(userId)/reviews"
        case .MyPets:
            fallthrough
        case .AddPet:
            fallthrough
        case .UpdatePet:
            return "/users/pets"
        case .MyReviews:
            return "/users/reviews/my_reviews"
        case .SearchRace(let query):
            return "/races?query=" + query.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        case .AddRace:
            return "/races"
        }
    }
    var method: Moya.Method {
        switch self {
        case .UserPets:
            return .GET
        case .UserReviews:
            return .GET
        case .CreateReview:
            return .POST
        case .MyPets:
            return .GET
        case .AddPet:
            return .POST
        case .UpdatePet:
            return .PUT
        case .MyReviews:
            return .GET
        case .SearchRace:
            return .GET
        case .AddRace:
            return .POST
        
        }
    }
    var parameters: [String : AnyObject]? {
        switch self {
        case .AddPet(let name, let raceId):
            return ["pet": ["name": name, "race_id": raceId]]
        case .AddRace(let name):
            return ["race": ["name": name]]
        case .CreateReview(_, let rate, let feedback):
            return ["review": ["rate": rate, "feedback": feedback ?? ""]]
        default:
            return nil
        }
    }
    
    var sampleData: NSData {
        return NSData()
    }
}