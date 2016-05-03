//
//  OnboardingVC.swift
//  Petsee
//
//  Created by Ariel Pollack on 02/05/2016.
//  Copyright © 2016 Ariel Pollack. All rights reserved.
//

import UIKit
import PetseeCore
import PetseeNetwork

class OnboardingVC: UIPageViewController {
    
    lazy var emailVC: OnboardingDataVC = {
        let vc = UIStoryboard(name: "Login", bundle: nil).instantiateViewControllerWithIdentifier("Email") as! OnboardingDataVC
        vc.delegate = self
        return vc
    }()
    
    lazy var passwordVC: OnboardingDataVC = {
        let vc = UIStoryboard(name: "Login", bundle: nil).instantiateViewControllerWithIdentifier("Password") as! OnboardingDataVC
        vc.delegate = self
        return vc
    }()
    
    lazy var nameVC: OnboardingDataVC = {
        let vc = UIStoryboard(name: "Login", bundle: nil).instantiateViewControllerWithIdentifier("Name") as! OnboardingDataVC
        vc.delegate = self
        return vc
    }()
    
    lazy var typeVC: OnboardingDataVC = {
        let vc = UIStoryboard(name: "Login", bundle: nil).instantiateViewControllerWithIdentifier("Type") as! OnboardingDataVC
        vc.delegate = self
        return vc
    }()
    
    private var email: String!
    private var password: String!
    private var name: String?
    private var type: UserType!
    private var isExistingUser: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showNextViewController(emailVC, animated: false)
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    private func showNextViewController(vc: UIViewController, animated: Bool = true) {
        setViewControllers([vc], direction: .Forward, animated: animated, completion: nil)
    }
    
    private func login() {
        PetseeAPI.sharedInstance.login(email, password: password) { user, error in
            guard let user = user else {
                return
            }
            
            let alert = UIAlertController(title: "Hello \(user.name!)", message: nil, preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "Close", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    private func signup() {
        
    }
    
    private func isValidEmail(testStr: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }
}

extension OnboardingVC: OnboardingDataDelegate {
    func dataViewControllerDidEnterData(controller: OnboardingDataVC, data: AnyObject?) {
        print(data)
        if controller == emailVC {
            email = data as! String
            PetseeAPI.sharedInstance.checkIfEmailExist(email, completion: { exist in
                if exist {
                    self.isExistingUser = true
                    self.showNextViewController(self.passwordVC)
                } else {
                    self.showNextViewController(self.nameVC)
                }
            })
        }
        if controller == nameVC {
            showNextViewController(passwordVC)
            // save user name and get password
        }
        if controller == passwordVC {
            password = data as! String
            if self.isExistingUser {
                login()
            } else {
                showNextViewController(typeVC)
            }
        }
        if controller == typeVC {
            type = UserType(rawValue: data as! String)!
            signup()
        }
    }
    
    func validateDataForController(controller: OnboardingDataVC, data: AnyObject?) -> Bool {
        if controller == emailVC {
            let email = data as! String // assume length is validated because it's a required field
            return isValidEmail(email)
        }
        
        if controller == passwordVC {
            // validate password
        }
        
        return true
    }
}

