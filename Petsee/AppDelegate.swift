//
//  AppDelegate.swift
//  Petsee
//
//  Created by Ariel Pollack on 28/04/2016.
//  Copyright © 2016 Ariel Pollack. All rights reserved.
//

import UIKit
import PetseeCore
import PetseeNetwork

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var authManager: AuthManagerProtocol!

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        //
        authManager = AuthManager.sharedInstance
        
        let onboardingVC = OnboardingVC(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
        onboardingVC.loginDelegate = self
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window!.rootViewController = onboardingVC
        window!.makeKeyAndVisible()
        return true
    }
}

extension AppDelegate: OnboardingDelegate {
    func didFinishLoginWithUser(user: User) {
        authManager.setAuthenticatedUser(user)
        if let token = user.token {
            PetseeAPI.setAuthenticationToken(token)
            print(user)
        }
        
        // test pets endpoint
        PetseeAPI.myPets { pets, error in
            print(pets)
        }
    }
}

