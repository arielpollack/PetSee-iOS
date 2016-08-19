//
//  PetseeActions.swift
//  Petsee
//
//  Created by Ariel Pollack on 07/05/2016.
//  Copyright © 2016 Ariel Pollack. All rights reserved.
//

import Foundation
import PetseeCore
import Moya

enum PetseeActions {
    case UserPets(userId: Int)
    case UserReviews(userId: Int)
    
    case CreateReview(userId: Int, rate: Int, feedback: String?)
    
    case MyPets
    case AddPet(Pet)
    case UpdatePet(Pet)
    case UploadImage(NSData)
    case Races(String)
    
    case MyReviews
    
    case SearchRace(query: String)
    case AddRace(name: String)
}

extension PetseeActions: TargetType {
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
            return "/users/pets"
        case .UpdatePet(let pet):
            return "/users/pets/\(pet.id)"
        case .UploadImage:
            return "/users/pets/upload_image"
        case .Races:
            return "/races"
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
        case .UploadImage:
            return .POST
        case .Races:
            return .GET
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
        case .AddPet(let pet):
            var params = pet.toJSON()
            params["race"] = nil
            params["race_id"] = pet.race.id
            return ["pet": params]
        case .UpdatePet(let pet):
            return ["pet": pet.toJSON()]
        case .AddRace(let name):
            return ["race": ["name": name]]
        case .CreateReview(_, let rate, let feedback):
            return ["review": ["rate": rate, "feedback": feedback ?? ""]]
        case .UploadImage(let imageData):
            return ["image": imageData.base64EncodedStringWithOptions([])]
        case .Races(let term):
            return ["query": term]
        default:
            return nil
        }
    }
    
    var sampleData: NSData {
        return NSData()
    }
}