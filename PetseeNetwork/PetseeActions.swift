//
//  PetseeActions.swift
//  Petsee
//
//  Created by Ariel Pollack on 07/05/2016.
//  Copyright © 2016 Ariel Pollack. All rights reserved.
//

import Foundation
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
    
    case MyServices
    case AddService(service: Service)
    case GetServiceRequests(service: Service)
    case GetAvailableServiceProviders(service: Service)
    case ChooseServiceRequest(service: Service, request: ServiceRequest)
    
    case RequestServiceProvider(service: Service, provider: ServiceProvider)
    
    // service provider methods
    case MyServiceRequests
    case ApproveServiceRequest(serviceRequest: ServiceRequest)
    case DenyServiceRequest(serviceRequest: ServiceRequest)
    case StartService(service: Service)
    case EndService(service: Service)

    case LocationsForService(service: Service)
    case AddLocationForService(service: Service, latitude: Double, longitude: Double)
}

extension PetseeActions: TargetType {
//    var baseURL: NSURL { return NSURL(string: "https://petsee.herokuapp.com")! }
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
        case .MyServices:
            return "/services"
        case .AddService:
            return "/services"
        case .GetAvailableServiceProviders(let service):
            return "/services/\(service.id)/available_service_providers"
        case .GetServiceRequests(let service):
            return "/services/\(service.id)/requests"
        case .RequestServiceProvider(let service, _):
            return "/services/\(service.id)/requests"
        case .ChooseServiceRequest(let service, _):
            return "/services/\(service.id)/choose_service_provider"
        case .MyServiceRequests:
            return "/services/my_requests"
        case .ApproveServiceRequest(let serviceRequest):
            return "/services/\(serviceRequest.service!.id)/approve"
        case .DenyServiceRequest(let serviceRequest):
            return "/services/\(serviceRequest.service!.id)/deny"
        case .LocationsForService(let service):
            return "/services/\(service.id)/locations"
        case .AddLocationForService(let service, _, _):
            return "/services/\(service.id)/add_location"
        case .StartService(let service):
            return "/services/\(service.id)/start"
        case .EndService(let service):
            return "/services/\(service.id)/end"
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
        case .MyServices:
            return .GET
        case .AddService:
            return .POST
        case .GetServiceRequests:
            return .GET
        case .RequestServiceProvider:
            return .POST
        case .ChooseServiceRequest:
            return .PUT
        case .MyServiceRequests:
            return .GET
        case .ApproveServiceRequest:
            return .PUT
        case .DenyServiceRequest:
            return .PUT
        case .LocationsForService:
            return .GET
        case .AddLocationForService:
            return .POST
        case .GetAvailableServiceProviders:
            return .GET
        case .StartService:
            return .PUT
        case .EndService:
            return .PUT
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
        case .AddService(let service):
            var params = service.toJSON()
            params["lat"] = service.location.latitude
            params["lng"] = service.location.longitude
            params["pet_id"] = service.pet.id
            params["pet"] = nil
            return params
        case .RequestServiceProvider(_, let provider):
            return ["service_provider_id": provider.id]
        case .ChooseServiceRequest(_, let request):
            return ["service_request_id": request.id]
        case .AddLocationForService(_, let latitude, let longitude):
            return ["latitude": latitude, "longitude": longitude]
        case .ApproveServiceRequest(let serviceRequest):
            return ["request_id": serviceRequest.id]
        case .DenyServiceRequest(let serviceRequest):
            return ["request_id": serviceRequest.id]
        default:
            return nil
        }
    }
    
    var sampleData: NSData {
        return NSData()
    }
}