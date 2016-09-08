//
//  AppDelegate.swift
//  Petsee
//
//  Created by Ariel Pollack on 28/04/2016.
//  Copyright © 2016 Ariel Pollack. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var authManager: AuthManagerProtocol!

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        authManager = AuthManager.sharedInstance
        
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        if authManager.isLoggedIn() {
            let userVC = UIStoryboard(name: "Client", bundle: nil).instantiateInitialViewController()
            window!.rootViewController = userVC
        } else {
            let onboardingVC = OnboardingVC(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
            onboardingVC.loginDelegate = self
            window!.rootViewController = onboardingVC
        }
        window!.makeKeyAndVisible()
        return true
    }
}

extension AppDelegate: OnboardingDelegate {
    func didFinishLoginWithUser(user: User) {
        authManager.setAuthenticatedUser(user)
        if let token = user.token {
            PetseeAPI.setAuthenticationToken(token)
            UserDefaultsManager.authenticatedUser = user
            
            let userVC = UIStoryboard(name: "Client", bundle: nil).instantiateInitialViewController()!
            
            let transition = CATransition()
            transition.type = kCATransitionPush
            transition.subtype = kCATransitionFromRight
            self.window?.setRootViewController(userVC, transition: transition)
        }
    }
}

