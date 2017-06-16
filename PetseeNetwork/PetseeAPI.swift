//
//  PetseeAPI.swift
//  Petsee
//
//  Created by Ariel Pollack on 30/04/2016.
//  Copyright © 2016 Ariel Pollack. All rights reserved.
//

import Foundation
import RxSwift
import ObjectMapper
import Moya
import Moya_ObjectMapper

struct PetseeAPI {
    fileprivate lazy var authProvider: RxMoyaProvider<PetseeAuth> = RxMoyaProvider<PetseeAuth>()
    fileprivate lazy var actionsProvider: RxMoyaProvider<PetseeActions> = {
        return RxMoyaProvider<PetseeActions>(endpointClosure: self.authenticatedEndpointClosure())
    }()
    
    fileprivate let disposeBag = DisposeBag()
    
    fileprivate var authenticationToken: String?
    
    static var sharedInstance = PetseeAPI()
    
    static func setAuthenticationToken(_ token: String?) {
        sharedInstance.authenticationToken = token
    }
    
    // MARK:- Authentication methods
    static func checkIfEmailExist(_ email: String, completion: @escaping (Bool)->()) {
        executeRequest(sharedInstance.authProvider, target: .checkEmailExist(email: email)) { object, error in
            guard let json = object as? JSON else {
                completion(false)
                return
            }
            
            completion(json["email_exist"] as! Bool)
        }
    }
    
    static func login(_ email: String, password: String, completion: @escaping (User?, String?)->()) {
        let target = PetseeAuth.login(email: email, password: password)
        executeRequest(sharedInstance.authProvider, target: target, objectType: User.self, completion: completion)
    }
    
    static func signup(_ email: String, password: String, name: String?, type: UserType, completion: @escaping (User?, String?)->()) {
        let target = PetseeAuth.signup(email: email, password: password, name: name, type: type)
        executeRequest(sharedInstance.authProvider, target: target, objectType: User.self, completion: completion)
    }
    
    static func updateUser(_ user: User, completion: @escaping (User?,String?)->()) {
        let target = PetseeActions.updateUser(image: user.image)
        executeRequest(sharedInstance.actionsProvider, target: target, objectType: User.self, completion: completion)
    }
    
    static func getUser(_ completion: @escaping (User?,String?)->()) {
        let target = PetseeActions.getUser
        executeRequest(sharedInstance.actionsProvider, target: target, objectType: User.self, completion: completion)
    }
    
    static func getNotifications(_ completion: @escaping ([Notification]?,String?)->()) {
        let target = PetseeActions.getNotifications
        executeRequest(sharedInstance.actionsProvider, target: target, arrayType: Notification.self, completion: completion)
    }
    
    static func clearNotifications(_ completion: @escaping (Any?,String?)->() = {_,_ in}) {
        let target = PetseeActions.clearNotificationsRead
        executeRequest(sharedInstance.actionsProvider, target: target, completion: completion)
    }
    
    // MARK:- Pets
    static func myPets(_ completion: @escaping ([Pet]?,String?)->()) {
        let target = PetseeActions.myPets
        executeRequest(sharedInstance.actionsProvider, target: target, arrayType: Pet.self, completion: completion)
    }
    
    static func addPet(_ pet: Pet, completion: @escaping (Pet?,String?)->()) {
        let target = PetseeActions.addPet(pet)
        executeRequest(sharedInstance.actionsProvider, target: target, objectType: Pet.self, completion: completion)
    }
    
    static func uploadImage(_ imageData: Data, completion: @escaping (Any?,String?)->()) {
        let target = PetseeActions.uploadImage(imageData)
        executeRequest(sharedInstance.actionsProvider, target: target, completion: completion)
    }
    
    static func updatePet(_ pet: Pet, completion: @escaping (Pet?,String?)->()) {
        let target = PetseeActions.updatePet(pet)
        executeRequest(sharedInstance.actionsProvider, target: target, objectType: Pet.self, completion: completion)
    }
    
    static func fetchRaces(_ term: String, completion: @escaping ([Race]?,String?)->()) {
        let target = PetseeActions.races(term)
        executeRequest(sharedInstance.actionsProvider, target: target, arrayType: Race.self, completion: completion)
    }
    
    // MARK:- Reviews
    static func userReviews(_ userId: Int, completion: @escaping ([Review]?,String?)->()) {
        let target = PetseeActions.userReviews(userId: userId)
        executeRequest(sharedInstance.actionsProvider, target: target, arrayType: Review.self, completion: completion)
    }
    
    static func myReviewOnUser(_ user: User, completion: @escaping (Review?,String?)->()) {
        let target = PetseeActions.myReviewOnUser(user: user)
        executeRequest(sharedInstance.actionsProvider, target: target, objectType: Review.self, completion: completion)
    }
    
    static func createReview(_ review: Review, completion: @escaping (Review?,String?)->()) {
        assert(review.user != nil, "Must set a user")
        let target: PetseeActions
        if review.id == nil {
            target = PetseeActions.createReview(userId: review.user!.id, rate: review.rate, feedback: review.feedback)
        } else {
            target = PetseeActions.updateReview(reviewId: review.id, rate: review.rate, feedback: review.feedback)
        }
        executeRequest(sharedInstance.actionsProvider, target: target, objectType: Review.self, completion: completion)
    }
    
    // MARK:- Services
    static func myServices(_ completion: @escaping ([Service]?,String?)->()) {
        let target = PetseeActions.myServices
        executeRequest(sharedInstance.actionsProvider, target: target, arrayType: Service.self, completion: completion)
    }
    
    static func myServiceRequests(_ completion: @escaping ([ServiceRequest]?,String?)->()) {
        let target = PetseeActions.myServiceRequests
        executeRequest(sharedInstance.actionsProvider, target: target, arrayType: ServiceRequest.self, completion: completion)
    }
    
    static func addService(_ service: Service, completion: @escaping (Service?,String?)->()) {
        let target = PetseeActions.addService(service: service)
        executeRequest(sharedInstance.actionsProvider, target: target, objectType: Service.self, completion: completion)
    }
    
    static func getServiceRequests(_ service: Service, completion: @escaping ([ServiceRequest]?,String?)->()) {
        let target = PetseeActions.getServiceRequests(service: service)
        executeRequest(sharedInstance.actionsProvider, target: target, arrayType: ServiceRequest.self, completion: completion)
    }
    
    static func getAvailableServiceProviders(_ service: Service, completion: @escaping ([ServiceProvider]?,String?)->()) {
        let target = PetseeActions.getAvailableServiceProviders(service: service)
        executeRequest(sharedInstance.actionsProvider, target: target, arrayType: ServiceProvider.self, completion: completion)
    }
    
    static func requestServiceProvider(_ service: Service, serviceProvider: ServiceProvider, completion: @escaping (ServiceRequest?,String?)->()) {
        let target = PetseeActions.requestServiceProvider(service: service, provider: serviceProvider)
        executeRequest(sharedInstance.actionsProvider, target: target, objectType: ServiceRequest.self, completion: completion)
    }
    
    static func chooseServiceRequest(_ service: Service, serviceRequest: ServiceRequest, completion: @escaping (Any?,String?)->()) {
        let target = PetseeActions.chooseServiceRequest(service: service, request: serviceRequest)
        executeRequest(sharedInstance.actionsProvider, target: target, completion: completion)
    }
    
    static func updateDeviceToken(_ token: String, completion: @escaping (Any?,String?)->()) {
        let target = PetseeActions.updateUserToken(token: token)
        executeRequest(sharedInstance.actionsProvider, target: target, completion: completion)
    }
    
    static func clearNotificationsCount(_ completion: @escaping (Any?,String?)->() = { _,_ in }) {
        let target = PetseeActions.clearNotificationsCount
        executeRequest(sharedInstance.actionsProvider, target: target, completion: completion)
    }
    
    static func locationsForService(_ service: Service, completion: @escaping ([Location]?,String?)->()) {
        let target = PetseeActions.locationsForService(service: service)
        executeRequest(sharedInstance.actionsProvider, target: target, arrayType: Location.self, completion: completion)
    }
    
    static func addLocationForService(_ latitude: Double, longitude: Double, service: Service, completion: @escaping (Location?,String?)->() = { _,_ in }) {
        let target = PetseeActions.addLocationForService(service: service, latitude: latitude, longitude: longitude)
        executeRequest(sharedInstance.actionsProvider, target: target, objectType: Location.self, completion: completion)
    }
    
    static func cancelService(_ service: Service, completion: @escaping (Any?,String?)->()) {
        let target = PetseeActions.cancelService(service: service)
        executeRequest(sharedInstance.actionsProvider, target: target, completion: completion)
    }
    
    static func approveServiceRequest(_ request: ServiceRequest, completion: @escaping (Any?,String?)->()) {
        let target = PetseeActions.approveServiceRequest(serviceRequest: request)
        executeRequest(sharedInstance.actionsProvider, target: target, completion: completion)
    }
    
    static func denyServiceRequest(_ request: ServiceRequest, completion: @escaping (Any?,String?)->()) {
        let target = PetseeActions.denyServiceRequest(serviceRequest: request)
        executeRequest(sharedInstance.actionsProvider, target: target, completion: completion)
    }
    
    static func startService(_ service: Service, completion: @escaping (Any?,String?)->()) {
        let target = PetseeActions.startService(service: service)
        executeRequest(sharedInstance.actionsProvider, target: target, completion: completion)
    }
    
    static func endService(_ service: Service, completion: @escaping (Any?,String?)->()) {
        let target = PetseeActions.endService(service: service)
        executeRequest(sharedInstance.actionsProvider, target: target, completion: completion)
    }
    
    // MARK:- Private
    fileprivate static func executeRequest<TT: TargetType>(_ provider: RxMoyaProvider<TT>, target: TT, completion: @escaping (Any?, String?)->()) {
        let observable = observableRequest(provider, target: target).mapJSON()
        executeObservable(observable, completion: completion)
    }
    
    fileprivate static func executeRequest<T: Mappable, TT: TargetType>(_ provider: RxMoyaProvider<TT>, target: TT, objectType: T.Type, completion: @escaping (T?, String?)->()) {
        let observable = observableRequest(provider, target: target).mapObject(objectType)
        executeObservable(observable, completion: completion)
    }
    
    fileprivate static func executeRequest<T: Mappable, TT: TargetType>(_ provider: RxMoyaProvider<TT>, target: TT, arrayType: T.Type, completion: @escaping ([T]?, String?)->()) {
        let observable = observableRequest(provider, target: target).mapArray(arrayType)
        executeObservable(observable, completion: completion)
    }
    
    fileprivate static func observableRequest<TT: TargetType>(_ provider: RxMoyaProvider<TT>, target: TT) -> RxSwift.Observable<Moya.Response> {
        return provider.request(target)//.delaySubscription(1, scheduler: MainScheduler.instance)
    }
    
    fileprivate static func handleEvent<T>(_ event: Event<T>, completion: (T?, String?)->()) {
        switch event {
        case .next(let object):
            completion(object, nil)
        case .error(let error):
            DLog(error)
            completion(nil, "something went wrong")
        default:
            break
        }
    }
    
    fileprivate static func executeObservable<T>(_ observable: Observable<T>, completion: @escaping (T?, String?)->()) {
        observable.subscribe({ event in
            self.handleEvent(event, completion: completion)
        }).addDisposableTo(sharedInstance.disposeBag)
    }
    
    fileprivate func authenticatedEndpointClosure<T: TargetType>() -> ((T) -> Endpoint<T>) {
        return { (target: TargetType) in
            let endpoint = Endpoint<T>(url: target.baseURL.appendingPathComponent(target.path).absoluteString,
                                       sampleResponseClosure: { EndpointSampleResponse.networkResponse(200, target.sampleData) },
                                       method: target.method,
                                       parameters: target.parameters)
            guard let token = self.authenticationToken else {
                return endpoint
            }
            return endpoint.adding(newHTTPHeaderFields: ["Authorization" : "Token token=\(token)"])
        }
    }
}
