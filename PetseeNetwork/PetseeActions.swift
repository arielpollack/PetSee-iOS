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
    case userPets(userId: Int)
    case userReviews(userId: Int)
    case getUser
    case updateUser(image: String?)
    case updateUserToken(token: String)
    case clearNotificationsCount
    case getNotifications
    case clearNotificationsRead
    
    case createReview(userId: Int, rate: Int, feedback: String?)
    case updateReview(reviewId: Int, rate: Int, feedback: String?)
    
    case myPets
    case addPet(Pet)
    case updatePet(Pet)
    case uploadImage(Data)
    case races(String)
    
    case myReviews
    case myReviewOnUser(user: User)
    
    case searchRace(query: String)
    case addRace(name: String)
    
    case myServices
    case addService(service: Service)
    case getServiceRequests(service: Service)
    case getAvailableServiceProviders(service: Service)
    case chooseServiceRequest(service: Service, request: ServiceRequest)
    case cancelService(service: Service)
    
    case requestServiceProvider(service: Service, provider: ServiceProvider)
    
    // service provider methods
    case myServiceRequests
    case approveServiceRequest(serviceRequest: ServiceRequest)
    case denyServiceRequest(serviceRequest: ServiceRequest)
    case startService(service: Service)
    case endService(service: Service)

    case locationsForService(service: Service)
    case addLocationForService(service: Service, latitude: Double, longitude: Double)
}

extension PetseeActions: TargetType {
    var baseURL: URL { return URL(string: "https://petsee.herokuapp.com")! }
//    var baseURL: NSURL { return NSURL(string: "http://localhost:3000")! }
    var path: String {
        switch self {
        case .getNotifications:
            return "/notifications"
        case .clearNotificationsRead:
            return "/notifications/read_all"
        case .getUser:
            return "/users"
        case .userPets(let userId):
            return "/users/\(userId)/pets"
        case .userReviews(let userId):
            return "/users/\(userId)/reviews"
        case .updateUser:
            return "/users"
        case .updateUserToken:
            return "/users/device_token"
        case .clearNotificationsCount:
            return "/users/reset_badge_count"
        case .createReview(let userId, _, _):
            return "/users/\(userId)/reviews"
        case .updateReview(_, _, _):
            return "/users/reviews/update_existing_review"
        case .myReviewOnUser(let user):
            return "/users/\(user.id)/reviews/review_about_user"
        case .myPets:
            fallthrough
        case .addPet:
            return "/users/pets"
        case .updatePet(let pet):
            return "/users/pets/\(pet.id)"
        case .uploadImage:
            return "/users/pets/upload_image"
        case .races:
            return "/races"
        case .myReviews:
            return "/users/reviews/my_reviews"
        case .searchRace(let query):
            return "/races?query=" + query.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        case .addRace:
            return "/races"
        case .myServices:
            return "/services"
        case .addService:
            return "/services"
        case .cancelService(let service):
            return "/services/\(service.id)/cancel"
        case .getAvailableServiceProviders(let service):
            return "/services/\(service.id)/available_service_providers"
        case .getServiceRequests(let service):
            return "/services/\(service.id)/requests"
        case .requestServiceProvider(let service, _):
            return "/services/\(service.id)/requests"
        case .chooseServiceRequest(let service, _):
            return "/services/\(service.id)/choose_service_provider"
        case .myServiceRequests:
            return "/services/my_requests"
        case .approveServiceRequest(let serviceRequest):
            return "/services/\(serviceRequest.service!.id)/approve"
        case .denyServiceRequest(let serviceRequest):
            return "/services/\(serviceRequest.service!.id)/deny"
        case .locationsForService(let service):
            return "/services/\(service.id)/locations"
        case .addLocationForService(let service, _, _):
            return "/services/\(service.id)/add_location"
        case .startService(let service):
            return "/services/\(service.id)/start"
        case .endService(let service):
            return "/services/\(service.id)/end"
        }
    }
    var method: Moya.Method {
        switch self {
        case .getNotifications:
            return .get
        case .clearNotificationsRead:
            return .put
        case .getUser:
            return .get
        case .userPets:
            return .get
        case .userReviews:
            return .get
        case .updateUser:
            return .put
        case .updateUserToken:
            return .put
        case .clearNotificationsCount:
            return .put
        case .createReview:
            return .post
        case .updateReview:
            return .put
        case .myPets:
            return .get
        case .addPet:
            return .post
        case .updatePet:
            return .put
        case .uploadImage:
            return .post
        case .races:
            return .get
        case .myReviews:
            return .get
        case .myReviewOnUser:
            return .get
        case .searchRace:
            return .get
        case .addRace:
            return .post
        case .myServices:
            return .get
        case .addService:
            return .post
        case .cancelService:
            return .delete
        case .getServiceRequests:
            return .get
        case .requestServiceProvider:
            return .post
        case .chooseServiceRequest:
            return .put
        case .myServiceRequests:
            return .get
        case .approveServiceRequest:
            return .put
        case .denyServiceRequest:
            return .put
        case .locationsForService:
            return .get
        case .addLocationForService:
            return .post
        case .getAvailableServiceProviders:
            return .get
        case .startService:
            return .put
        case .endService:
            return .put
        }
    }
    var parameters: [String : Any]? {
        switch self {
        case .updateUser(let image):
            var params = JSON()
            params["image"] = image as AnyObject
            return params
        case .updateUserToken(let token):
            return ["token": token as AnyObject]
        case .addPet(let pet):
            var params = pet.toJSON()
            params["race"] = nil
            params["race_id"] = pet.race.id
            return ["pet": params]
        case .updatePet(let pet):
            return ["pet": pet.toJSON()]
        case .addRace(let name):
            return ["race": ["name": name]]
        case .createReview(_, let rate, let feedback):
            return ["rate": rate as AnyObject, "feedback": feedback ?? ""]
        case .updateReview(let reviewId, let rate, let feedback):
            return ["review_id": reviewId as AnyObject, "rate": rate as AnyObject, "feedback": feedback ?? ""]
        case .uploadImage(let imageData):
            return ["image": imageData.base64EncodedString(options: []) as AnyObject]
        case .races(let term):
            return ["query": term as AnyObject]
        case .addService(let service):
            var params = service.toJSON()
            params["lat"] = service.location.latitude
            params["lng"] = service.location.longitude
            params["address"] = service.location.address
            params["pet_id"] = service.pet.id
            params["pet"] = nil
            return params
        case .requestServiceProvider(_, let provider):
            return ["service_provider_id": provider.id as AnyObject]
        case .chooseServiceRequest(_, let request):
            return ["request_id": request.id as AnyObject]
        case .addLocationForService(_, let latitude, let longitude):
            return ["latitude": latitude as AnyObject, "longitude": longitude as AnyObject]
        case .approveServiceRequest(let serviceRequest):
            return ["request_id": serviceRequest.id as AnyObject]
        case .denyServiceRequest(let serviceRequest):
            return ["request_id": serviceRequest.id as AnyObject]
        default:
            return nil
        }
    }

    var parameterEncoding: ParameterEncoding {
        switch self.method {
        case .get:
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
