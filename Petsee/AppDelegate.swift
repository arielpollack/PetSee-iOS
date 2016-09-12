//
//  AppDelegate.swift
//  Petsee
//
//  Created by Ariel Pollack on 28/04/2016.
//  Copyright © 2016 Ariel Pollack. All rights reserved.
//

import UIKit
import SVProgressHUD
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder {

    var window: UIWindow?
    var authManager: AuthManagerProtocol!

    private func setDefaultAppearance() {
        SVProgressHUD.setDefaultMaskType(.Black)
        UINavigationBar.appearance().titleTextAttributes = [
            NSForegroundColorAttributeName: UIColor.whiteColor(),
            NSFontAttributeName: UIFont.systemFontOfSize(18, weight: UIFontWeightLight)
        ]
        UINavigationBar.appearance().barTintColor = UIColor(hex: "#2196F3")
        UINavigationBar.appearance().tintColor = UIColor.whiteColor()
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
    
    private func registerForPushNotifications() {
        let notificationSettings = UIUserNotificationSettings(forTypes: [.Badge, .Sound, .Alert], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(notificationSettings)
        UIApplication.sharedApplication().registerForRemoteNotifications()
    }
    
    private func clearNotificationsCount() {
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        PetseeAPI.clearNotificationsCount()
    }
    
    private func reloadUser() {
        PetseeAPI.getUser { user, error in
            guard let user = user where error == nil else {
                return
            }
            AuthManager.sharedInstance.setAuthenticatedUser(user)
            UserDefaultsManager.authenticatedUser = user
        }
    }
}

extension AppDelegate: UIApplicationDelegate {
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        authManager = AuthManager.sharedInstance
        
        setDefaultAppearance()
        
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        
        if authManager.isLoggedIn() {
            window!.rootViewController = userViewController()
            LocationHandler.sharedManager.startLocationUpdates()
            reloadUser()
            registerForPushNotifications()
        } else {
            let onboardingVC = OnboardingVC(transitionStyle: .Scroll, navigationOrientation: .Horizontal, options: nil)
            onboardingVC.loginDelegate = self
            window!.rootViewController = onboardingVC
        }
        window!.makeKeyAndVisible()
        
        Fabric.with([Crashlytics.self])
        
        return true
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        if AuthManager.sharedInstance.isLoggedIn() {
            clearNotificationsCount()
        }
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        var token = deviceToken.description.stringByReplacingOccurrencesOfString("-", withString: "")
        token = token.stringByReplacingOccurrencesOfString("<", withString: "")
        token = token.stringByReplacingOccurrencesOfString(">", withString: "")
        token = token.stringByReplacingOccurrencesOfString(" ", withString: "")

        print(token)
        PetseeAPI.updateDeviceToken(token) { _, error in
            
        }
    }
}

extension AppDelegate: OnboardingDelegate {
    
    func didFinishLoginWithUser(user: User) {
        registerForPushNotifications()
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