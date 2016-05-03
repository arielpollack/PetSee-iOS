//
//  OnboardingVC.swift
//  Petsee
//
//  Created by Ariel Pollack on 02/05/2016.
//  Copyright © 2016 Ariel Pollack. All rights reserved.
//

import UIKit

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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setViewControllers([emailVC], direction: .Forward, animated: false, completion: nil)
    }
}

extension OnboardingVC: OnboardingDataDelegate {
    func dataViewControllerDidEnterData(controller: OnboardingDataVC, data: AnyObject?) {
        print(data)
        if controller == emailVC {
            setViewControllers([nameVC], direction: .Forward, animated: true, completion: nil)
            // 1. check if email exist in server
            // 2. yes -> continue to password screen
            // 3. no -> continue to sign up flow
        }
        if controller == nameVC {
            setViewControllers([passwordVC], direction: .Forward, animated: true, completion: nil)
            // save user name and get password
        }
        if controller == passwordVC {
            // login flow -> verify password in server
            // signup flow -> continue to type selection
        }
    }
    
    func validateDataForController(controller: OnboardingDataVC, data: AnyObject?) -> Bool {
        if controller == emailVC {
            // validate email
        }
        
        return true
    }
}

