//
//  PetseeAPI.swift
//  Petsee
//
//  Created by Ariel Pollack on 30/04/2016.
//  Copyright © 2016 Ariel Pollack. All rights reserved.
//

import Foundation
import PetseeCore
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
    
    // MARK:- Pets
    public static func myPets(completion: ([Pet]?,String?)->()) {
        let target = PetseeActions.MyPets
        executeRequest(sharedInstance.actionsProvider, target: target, arrayType: Pet.self, completion: completion)
    }
    
    public static func addPet(pet: Pet, completion: (Pet?,String?)->()) {
        let target = PetseeActions.AddPet(pet)
        executeRequest(sharedInstance.actionsProvider, target: target, objectType: Pet.self, completion: completion)
    }
    
    public static func updatePet(pet: Pet, completion: (Pet?,String?)->()) {
        let target = PetseeActions.UpdatePet(pet)
        executeRequest(sharedInstance.actionsProvider, target: target, objectType: Pet.self, completion: completion)
    }
    
    // MARK:- Reviews
    public static func userReviews(userId: Int, completion: ([Review]?,String?)->()) {
        let target = PetseeActions.UserReviews(userId: userId)
        executeRequest(sharedInstance.actionsProvider, target: target, arrayType: Review.self, completion: completion)
    }
    
    public static func createReview(review: Review, completion: (Review?,String?)->()) {
        assert(review.user != nil, "Must set a user")
        let target = PetseeActions.CreateReview(userId: review.user!.id, rate: review.rate, feedback: review.feedback)
        executeRequest(sharedInstance.actionsProvider, target: target, objectType: Review.self, completion: completion)
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
        return provider.request(target).delaySubscription(1, scheduler: MainScheduler.instance)
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