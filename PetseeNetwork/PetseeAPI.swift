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
import Moya
import Moya_ObjectMapper

public struct PetseeAPI {
    private lazy var authProvider = RxMoyaProvider<PetseeAuth>()
    private let disposeBag = DisposeBag()
    
    private var authenticationToken: String?
    
    public static var sharedInstance = PetseeAPI()
    
    public static func setAuthenticationToken(token: String?) {
        sharedInstance.authenticationToken = token
    }
    
    // MARK:- Authentication methods
    public static func checkIfEmailExist(email: String, completion: Bool->()) {
        sharedInstance.authProvider.request(.CheckEmailExist(email: email)).delaySubscription(1, scheduler: MainScheduler.instance).mapJSON().subscribe({ event in
            switch event {
            case .Next(let json):
                completion(json["email_exist"] as! Bool)
            case .Error(let error):
                print(error)
                completion(false)
            default:
                break
            }
        }).addDisposableTo(sharedInstance.disposeBag)
    }
    
    public static func login(email: String, password: String, completion: (User?, String?)->()) {
        sharedInstance.authProvider.request(.Login(email: email, password: password)).delaySubscription(1, scheduler: MainScheduler.instance).mapObject(User).subscribe({ event in
            switch event {
            case .Next(let user):
                completion(user, nil)
            case .Error(let error):
                print(error)
                completion(nil, "something went wrong")
            default:
                break
            }
        }).addDisposableTo(sharedInstance.disposeBag)
    }
    
    public static func signup(email: String, password: String, name: String?, type: UserType, completion: (User?, String?)->()) {
        sharedInstance.authProvider.request(.Signup(email: email, password: password, name: name, type: type)).delaySubscription(1, scheduler: MainScheduler.instance).mapObject(User).subscribe({ event in
            switch event {
            case .Next(let user):
                completion(user, nil)
            case .Error(let error):
                print(error)
                completion(nil, "something went wrong")
            default:
                break
            }
        }).addDisposableTo(sharedInstance.disposeBag)
    }
    
    // MARK:- Private
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