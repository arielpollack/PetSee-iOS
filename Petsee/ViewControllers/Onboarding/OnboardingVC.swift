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

protocol OnboardingDelegate {
    func didFinishLoginWithUser(user: User)
}

class OnboardingVC: UIPageViewController {
    
    var loginDelegate: OnboardingDelegate?
    
    lazy var emailVC: OnboardingDataVC = {
        let vc = UIStoryboard(name: "Login", bundle: nil).instantiateViewControllerWithIdentifier("Email") as! OnboardingDataVC
        vc.delegate = self
        return vc
    }()
    
    lazy var passwordVC: OnboardingDataVC = {
        let vc = UIStoryboard(name: "Login", bundle: nil).instantiateViewControllerWithIdentifier(self.isExistingUser ? "Password" : "NewPassword") as! OnboardingDataVC
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
    
    lazy var loadingView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(white: 0, alpha: 0.2)
        view.hidden = true
        view.alpha = 0
        self.view.addSubview(view)
        
        view.leadingAnchor.constraintEqualToAnchor(self.view.leadingAnchor).active = true
        view.trailingAnchor.constraintEqualToAnchor(self.view.trailingAnchor).active = true
        view.topAnchor.constraintEqualToAnchor(self.view.topAnchor).active = true
        view.bottomAnchor.constraintEqualToAnchor(self.view.bottomAnchor).active = true
        
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.color = UIColor.blackColor()
        indicator.startAnimating()
        view.addSubview(indicator)
        
        indicator.centerXAnchor.constraintEqualToAnchor(view.centerXAnchor).active = true
        indicator.centerYAnchor.constraintEqualToAnchor(view.centerYAnchor).active = true
        
        return view
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
        showActivityIndicator()
        PetseeAPI.login(email, password: password) { user, error in
            self.hideActivityIndicator()
            guard let user = user else {
                return
            }
            
            self.loginDelegate?.didFinishLoginWithUser(user)
        }
    }
    
    private func signup() {
        showActivityIndicator()
        PetseeAPI.signup(email, password: password, name: name, type: type) { user, error in
            self.hideActivityIndicator()
            guard let user = user else {
                return
            }
            
            self.loginDelegate?.didFinishLoginWithUser(user)
        }
    }
    
    private func isValidEmail(testStr: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }
    
    private func showActivityIndicator() {
        loadingView.hidden = false
        UIView.animateWithDuration(0.2) { 
            self.loadingView.alpha = 1
        }
    }
    
    private func hideActivityIndicator() {
        UIView.animateWithDuration(0.2, animations: { 
            self.loadingView.alpha = 0
        }) { finished in
            if finished {
                self.loadingView.hidden = true
            }
        }
    }
}

extension OnboardingVC: OnboardingDataDelegate {
    func dataViewControllerDidEnterData(controller: OnboardingDataVC, data: AnyObject?) {
        print(data)
        if controller == emailVC {
            email = data as! String
            showActivityIndicator()
            PetseeAPI.checkIfEmailExist(email, completion: { exist in
                self.hideActivityIndicator()
                if exist {
                    self.isExistingUser = true
                    self.showNextViewController(self.passwordVC)
                } else {
                    self.showNextViewController(self.nameVC)
                }
            })
        }
        else if controller == nameVC {
            name = data as? String
            showNextViewController(passwordVC)
        }
        else if controller == passwordVC {
            password = data as! String
            if self.isExistingUser {
                login()
            } else {
                showNextViewController(typeVC)
            }
        }
        else if controller == typeVC {
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

