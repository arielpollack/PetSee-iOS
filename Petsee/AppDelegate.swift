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

    fileprivate func setDefaultAppearance() {
        SVProgressHUD.setDefaultMaskType(.black)
        UINavigationBar.appearance().titleTextAttributes = [
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont.systemFont(ofSize: 18, weight: UIFontWeightLight)
        ]
        UINavigationBar.appearance().barTintColor = UIColor(hex: "#2196F3")
        UINavigationBar.appearance().tintColor = UIColor.white
    }
    
    fileprivate func userViewController() -> UIViewController {
        let userVC: UIViewController
        switch AuthManager.sharedInstance.authenticatedUser!.type! {
        case .Client:
            userVC = UIStoryboard(name: "Client", bundle: nil).instantiateViewController(withIdentifier: "ClientStarter")
        case .ServiceProvider:
            userVC = UIStoryboard(name: "Client", bundle: nil).instantiateViewController(withIdentifier: "ServiceProviderStarter")
        }
        return userVC
    }
    
    fileprivate func registerForPushNotifications() {
        let notificationSettings = UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil)
        UIApplication.shared.registerUserNotificationSettings(notificationSettings)
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    fileprivate func clearNotificationsCount() {
        UIApplication.shared.applicationIconBadgeNumber = 0
        PetseeAPI.clearNotificationsCount()
    }
    
    fileprivate func reloadUser() {
        PetseeAPI.getUser { user, error in
            guard let user = user, error == nil else {
                return
            }
            AuthManager.sharedInstance.setAuthenticatedUser(user)
            UserDefaultsManager.authenticatedUser = user
        }
    }
}

extension AppDelegate: UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        authManager = AuthManager.sharedInstance
        
        setDefaultAppearance()
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        if authManager.isLoggedIn() {
            window!.rootViewController = userViewController()
            LocationHandler.sharedManager.startLocationUpdates()
            reloadUser()
            registerForPushNotifications()
        } else {
            let onboardingVC = OnboardingVC(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
            onboardingVC.loginDelegate = self
            window!.rootViewController = onboardingVC
        }
        window!.makeKeyAndVisible()
        
        Fabric.with([Crashlytics.self])
        
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        if AuthManager.sharedInstance.isLoggedIn() {
            clearNotificationsCount()
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        var token = deviceToken.description.replacingOccurrences(of: "-", with: "")
        token = token.replacingOccurrences(of: "<", with: "")
        token = token.replacingOccurrences(of: ">", with: "")
        token = token.replacingOccurrences(of: " ", with: "")

        DLog(token)
        PetseeAPI.updateDeviceToken(token) { _, error in
            
        }
    }
}

extension AppDelegate: OnboardingDelegate {
    
    func didFinishLoginWithUser(_ user: User) {
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
