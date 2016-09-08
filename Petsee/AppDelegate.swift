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
            window!.rootViewController = userViewController()
        } else {
            let onboardingVC = OnboardingVC(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
            onboardingVC.loginDelegate = self
            window!.rootViewController = onboardingVC
        }
        window!.makeKeyAndVisible()
        return true
    }
    
    private func userViewController() -> UIViewController {
        let userVC: UIViewController
        switch AuthManager.sharedInstance.authenticatedUser!.type! {
        case .Client:
            userVC = UIStoryboard(name: "Client", bundle: nil).instantiateViewControllerWithIdentifier("ClientStarter")
        case .ServiceProvider:
            userVC = UIStoryboard(name: "Client", bundle: nil).instantiateViewControllerWithIdentifier("ServiceProviderStarter")
        }
        return userVC
    }
}

extension AppDelegate: OnboardingDelegate {
    func didFinishLoginWithUser(user: User) {
        authManager.setAuthenticatedUser(user)
        if let token = user.token {
            PetseeAPI.setAuthenticationToken(token)
            UserDefaultsManager.authenticatedUser = user
            
            let userVC = self.userViewController()
            let transition = CATransition()
            transition.type = kCATransitionPush
            transition.subtype = kCATransitionFromRight
            self.window?.setRootViewController(userVC, transition: transition)
        }
    }
}