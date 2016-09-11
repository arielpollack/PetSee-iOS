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

public struct PetseeAPI {
    private lazy var authProvider = RxMoyaProvider<PetseeAuth>()
    private lazy var actionsProvider: RxMoyaProvider<PetseeActions> = {
        return RxMoyaProvider<PetseeActions>(endpointClosure: self.authenticatedEndpointClosure())
    }()
    
    private let disposeBag = DisposeBag()
    
    private var authenticationToken: String?
    
    public static var sharedInstance = PetseeAPI()
    
    public static func setAuthenticationToken(token: String?) {
        sharedInstance.authenticationToken = token
    }
    
    // MARK:- Authentication methods
    public static func checkIfEmailExist(email: String, completion: Bool->()) {
        executeRequest(sharedInstance.authProvider, target: .CheckEmailExist(email: email)) { object, error in
            guard let json = object else {
                completion(false)
                return
            }
            
            completion(json["email_exist"] as! Bool)
        }
    }
    
    public static func login(email: String, password: String, completion: (User?, String?)->()) {
        let target = PetseeAuth.Login(email: email, password: password)
        executeRequest(sharedInstance.authProvider, target: target, objectType: User.self, completion: completion)
    }
    
    public static func signup(email: String, password: String, name: String?, type: UserType, completion: (User?, String?)->()) {
        let target = PetseeAuth.Signup(email: email, password: password, name: name, type: type)
        executeRequest(sharedInstance.authProvider, target: target, objectType: User.self, completion: completion)
    }
    
    public static func updateUser(user: User, completion: (User?,String?)->()) {
        let target = PetseeActions.UpdateUser(image: user.image)
        executeRequest(sharedInstance.actionsProvider, target: target, objectType: User.self, completion: completion)
    }
    
    // MARK:- Pets
    public static func myPets(completion: ([Pet]?,String?)->()) {
        let target = PetseeActions.MyPets
        executeRequest(sharedInstance.actionsProvider, target: target, arrayType: Pet.self, completion: completion)
    }
    
    public static func addPet(pet: Pet, completion: (Pet?,String?)->()) {
        let target = PetseeActions.AddPet(pet)
        executeRequest(sharedInstance.actionsProvider, target: target, objectType: Pet.self, completion: completion)
    }
    
    public static func uploadImage(imageData: NSData, completion: (AnyObject?,String?)->()) {
        let target = PetseeActions.UploadImage(imageData)
        executeRequest(sharedInstance.actionsProvider, target: target, completion: completion)
    }
    
    public static func updatePet(pet: Pet, completion: (Pet?,String?)->()) {
        let target = PetseeActions.UpdatePet(pet)
        executeRequest(sharedInstance.actionsProvider, target: target, objectType: Pet.self, completion: completion)
    }
    
    public static func fetchRaces(term: String, completion: ([Race]?,String?)->()) {
        let target = PetseeActions.Races(term)
        executeRequest(sharedInstance.actionsProvider, target: target, arrayType: Race.self, completion: completion)
    }
    
    // MARK:- Reviews
    public static func userReviews(userId: Int, completion: ([Review]?,String?)->()) {
        let target = PetseeActions.UserReviews(userId: userId)
        executeRequest(sharedInstance.actionsProvider, target: target, arrayType: Review.self, completion: completion)
    }
    
    public static func myReviewOnUser(user: User, completion: (Review?,String?)->()) {
        let target = PetseeActions.MyReviewOnUser(user: user)
        executeRequest(sharedInstance.actionsProvider, target: target, objectType: Review.self, completion: completion)
    }
    
    public static func createReview(review: Review, completion: (Review?,String?)->()) {
        assert(review.user != nil, "Must set a user")
        let target: PetseeActions
        if review.id == nil {
            target = PetseeActions.CreateReview(userId: review.user!.id, rate: review.rate, feedback: review.feedback)
        } else {
            target = PetseeActions.UpdateReview(reviewId: review.id, rate: review.rate, feedback: review.feedback)
        }
        executeRequest(sharedInstance.actionsProvider, target: target, objectType: Review.self, completion: completion)
    }
    
    // MARK:- Services
    public static func myServices(completion: ([Service]?,String?)->()) {
        let target = PetseeActions.MyServices
        executeRequest(sharedInstance.actionsProvider, target: target, arrayType: Service.self, completion: completion)
    }
    
    public static func myServiceRequests(completion: ([ServiceRequest]?,String?)->()) {
        let target = PetseeActions.MyServiceRequests
        executeRequest(sharedInstance.actionsProvider, target: target, arrayType: ServiceRequest.self, completion: completion)
    }
    
    public static func addService(service: Service, completion: (Service?,String?)->()) {
        let target = PetseeActions.AddService(service: service)
        executeRequest(sharedInstance.actionsProvider, target: target, objectType: Service.self, completion: completion)
    }
    
    public static func getServiceRequests(service: Service, completion: ([ServiceRequest]?,String?)->()) {
        let target = PetseeActions.GetServiceRequests(service: service)
        executeRequest(sharedInstance.actionsProvider, target: target, arrayType: ServiceRequest.self, completion: completion)
    }
    
    public static func getAvailableServiceProviders(service: Service, completion: ([ServiceProvider]?,String?)->()) {
        let target = PetseeActions.GetAvailableServiceProviders(service: service)
        executeRequest(sharedInstance.actionsProvider, target: target, arrayType: ServiceProvider.self, completion: completion)
    }
    
    public static func requestServiceProvider(service: Service, serviceProvider: ServiceProvider, completion: (ServiceRequest?,String?)->()) {
        let target = PetseeActions.RequestServiceProvider(service: service, provider: serviceProvider)
        executeRequest(sharedInstance.actionsProvider, target: target, objectType: ServiceRequest.self, completion: completion)
    }
    
    public static func chooseServiceRequest(service: Service, serviceRequest: ServiceRequest, completion: (AnyObject?,String?)->()) {
        let target = PetseeActions.ChooseServiceRequest(service: service, request: serviceRequest)
        executeRequest(sharedInstance.actionsProvider, target: target, completion: completion)
    }
    
    public static func updateDeviceToken(token: String, completion: (AnyObject?,String?)->()) {
        let target = PetseeActions.UpdateUserToken(token: token)
        executeRequest(sharedInstance.actionsProvider, target: target, completion: completion)
    }
    
    public static func clearNotificationsCount(completion: (AnyObject?,String?)->() = { _,_ in }) {
        let target = PetseeActions.ClearNotificationsCount
        executeRequest(sharedInstance.actionsProvider, target: target, completion: completion)
    }
    
    public static func locationsForService(service: Service, completion: ([Location]?,String?)->()) {
        let target = PetseeActions.LocationsForService(service: service)
        executeRequest(sharedInstance.actionsProvider, target: target, arrayType: Location.self, completion: completion)
    }
    
    public static func addLocationForService(latitude: Double, longitude: Double, service: Service, completion: (Location?,String?)->() = { _,_ in }) {
        let target = PetseeActions.AddLocationForService(service: service, latitude: latitude, longitude: longitude)
        executeRequest(sharedInstance.actionsProvider, target: target, objectType: Location.self, completion: completion)
    }
    
    public static func cancelService(service: Service, completion: (AnyObject?,String?)->()) {
        let target = PetseeActions.CancelService(service: service)
        executeRequest(sharedInstance.actionsProvider, target: target, completion: completion)
    }
    
    public static func approveServiceRequest(request: ServiceRequest, completion: (AnyObject?,String?)->()) {
        let target = PetseeActions.ApproveServiceRequest(serviceRequest: request)
        executeRequest(sharedInstance.actionsProvider, target: target, completion: completion)
    }
    
    public static func denyServiceRequest(request: ServiceRequest, completion: (AnyObject?,String?)->()) {
        let target = PetseeActions.DenyServiceRequest(serviceRequest: request)
        executeRequest(sharedInstance.actionsProvider, target: target, completion: completion)
    }
    
    public static func startService(service: Service, completion: (AnyObject?,String?)->()) {
        let target = PetseeActions.StartService(service: service)
        executeRequest(sharedInstance.actionsProvider, target: target, completion: completion)
    }
    
    public static func endService(service: Service, completion: (AnyObject?,String?)->()) {
        let target = PetseeActions.EndService(service: service)
        executeRequest(sharedInstance.actionsProvider, target: target, completion: completion)
    }
    
    // MARK:- Private
    private static func executeRequest<TT: TargetType>(provider: RxMoyaProvider<TT>, target: TT, completion: (AnyObject?, String?)->()) {
        let observable = observableRequest(provider, target: target).mapJSON()
        executeObservable(observable, completion: completion)
    }
    
    private static func executeRequest<T: Mappable, TT: TargetType>(provider: RxMoyaProvider<TT>, target: TT, objectType: T.Type, completion: (T?, String?)->()) {
        let observable = observableRequest(provider, target: target).mapObject(objectType)
        executeObservable(observable, completion: completion)
    }
    
    private static func executeRequest<T: Mappable, TT: TargetType>(provider: RxMoyaProvider<TT>, target: TT, arrayType: T.Type, completion: ([T]?, String?)->()) {
        let observable = observableRequest(provider, target: target).mapArray(arrayType)
        executeObservable(observable, completion: completion)
    }
    
    private static func observableRequest<TT: TargetType>(provider: RxMoyaProvider<TT>, target: TT) -> RxSwift.Observable<Moya.Response> {
        return provider.request(target)//.delaySubscription(1, scheduler: MainScheduler.instance)
    }
    
    private static func handleEvent<T>(event: Event<T>, completion: (T?, String?)->()) {
        switch event {
        case .Next(let object):
            completion(object, nil)
        case .Error(let error):
            print(error)
            completion(nil, "something went wrong")
        default:
            break
        }
    }
    
    private static func executeObservable<T>(observable: Observable<T>, completion: (T?, String?)->()) {
        observable.subscribe({ event in
            self.handleEvent(event, completion: completion)
        }).addDisposableTo(sharedInstance.disposeBag)
    }
    
    private func authenticatedEndpointClosure<T: TargetType>() -> (T -> Endpoint<T>) {
        return { target in
            let endpoint = Endpoint<T>(URL: target.baseURL.URLByAppendingPathComponent(target.path).absoluteString,
                                       sampleResponseClosure: { EndpointSampleResponse.NetworkResponse(200, target.sampleData) },
                                       method: target.method,
                                       parameters: target.parameters)
            guard let token = self.authenticationToken else {
                return endpoint
            }
            return endpoint.endpointByAddingHTTPHeaderFields(["Authorization" : "Token token=\(token)"])
        }
    }
}