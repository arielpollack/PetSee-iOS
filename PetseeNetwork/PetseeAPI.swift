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
    let authProvider = RxMoyaProvider<PetseeAuth>()
    let disposeBag = DisposeBag()
    
    public static var sharedInstance = PetseeAPI()
    
    public func checkIfEmailExist(email: String, completion: Bool->()) {
        authProvider.request(.CheckEmailExist(email: email)).delaySubscription(1, scheduler: MainScheduler.instance).mapJSON().subscribe({ event in
            switch event {
            case .Next(let json):
                completion(json["email_exist"] as! Bool)
            case .Error(let error):
                print(error)
                completion(false)
            default:
                break
            }
        }).addDisposableTo(disposeBag)
    }
    
    public func login(email: String, password: String, completion: (User?, String?)->()) {
        authProvider.request(.Login(email: email, password: password)).delaySubscription(1, scheduler: MainScheduler.instance).mapObject(User).subscribe({ event in
            switch event {
            case .Next(let user):
                completion(user, nil)
            case .Error(let error):
                print(error)
                completion(nil, "something went wrong")
            default:
                break
            }
        }).addDisposableTo(disposeBag)
    }
    
    public func signup(email: String, password: String, name: String?, type: UserType, completion: (User?, String?)->()) {
        authProvider.request(.Signup(email: email, password: password, name: name, type: type)).delaySubscription(1, scheduler: MainScheduler.instance).mapObject(User).subscribe({ event in
            switch event {
            case .Next(let user):
                completion(user, nil)
            case .Error(let error):
                print(error)
                completion(nil, "something went wrong")
            default:
                break
            }
        }).addDisposableTo(disposeBag)
    }
}