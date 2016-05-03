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
        authProvider.request(.CheckEmailExist(email: email)).mapJSON().subscribe({ event in
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
        authProvider.request(.Login(email: email, password: password)).mapObject(User).subscribe({ event in
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