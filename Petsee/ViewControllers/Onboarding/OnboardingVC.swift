//
//  OnboardingVC.swift
//  Petsee
//
//  Created by Ariel Pollack on 02/05/2016.
//  Copyright © 2016 Ariel Pollack. All rights reserved.
//

import UIKit

protocol OnboardingDelegate {
    func didFinishLoginWithUser(_ user: User)
}

class OnboardingVC: UIPageViewController {
    
    var loginDelegate: OnboardingDelegate?
    
    lazy var emailVC: OnboardingDataVC = {
        let vc = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "Email") as! OnboardingDataVC
        vc.delegate = self
        return vc
    }()
    
    lazy var passwordVC: OnboardingDataVC = {
        let vc = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: self.isExistingUser ? "Password" : "NewPassword") as! OnboardingDataVC
        vc.delegate = self
        return vc
    }()
    
    lazy var nameVC: OnboardingDataVC = {
        let vc = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "Name") as! OnboardingDataVC
        vc.delegate = self
        return vc
    }()
    
    lazy var photoVC: OnboardingDataVC = {
        let vc = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "Photo") as! OnboardingDataVC
        vc.delegate = self
        return vc
    }()
    
    lazy var typeVC: OnboardingDataVC = {
        let vc = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "Type") as! OnboardingDataVC
        vc.delegate = self
        return vc
    }()
    
    lazy var loadingView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(white: 0, alpha: 0.2)
        view.isHidden = true
        view.alpha = 0
        self.view.addSubview(view)
        
        view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        view.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.color = UIColor.black
        indicator.startAnimating()
        view.addSubview(indicator)
        
        indicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        indicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        return view
    }()
    
    fileprivate var email: String!
    fileprivate var password: String!
    fileprivate var name: String?
    fileprivate var imageData: Data?
    fileprivate var type: UserType!
    fileprivate var isExistingUser: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        showNextViewController(emailVC, animated: false)
    }
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    fileprivate func showNextViewController(_ vc: UIViewController, animated: Bool = true) {
        setViewControllers([vc], direction: .forward, animated: animated, completion: nil)
    }
    
    fileprivate func login() {
        showActivityIndicator()
        PetseeAPI.login(email, password: password) { user, error in
            self.hideActivityIndicator()
            guard let user = user else {
                return
            }
            
            self.loginDelegate?.didFinishLoginWithUser(user)
        }
    }
    
    fileprivate func signup() {
        showActivityIndicator()
        PetseeAPI.signup(email, password: password, name: name, type: type) { user, error in
            self.hideActivityIndicator()
            guard let user = user else {
                return
            }
            
            self.loginDelegate?.didFinishLoginWithUser(user)
            
            // upload image after login
            if let data = self.imageData {
                PetseeAPI.uploadImage(data, completion: { res, error in
                    guard let res = res as? JSON, let url = res["url"] as? String else {
                        return
                    }
                    
                    user.image = url
                    PetseeAPI.updateUser(user, completion: { user, error in
                        if let user = user, error == nil {
                            AuthManager.sharedInstance.authenticatedUser = user
                        }
                    })
                })
            }
        }
    }
    
    fileprivate func isValidEmail(_ testStr: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    fileprivate func showActivityIndicator() {
        loadingView.isHidden = false
        UIView.animate(withDuration: 0.2, animations: { 
            self.loadingView.alpha = 1
        }) 
    }
    
    fileprivate func hideActivityIndicator() {
        UIView.animate(withDuration: 0.2, animations: { 
            self.loadingView.alpha = 0
        }, completion: { finished in
            if finished {
                self.loadingView.isHidden = true
            }
        }) 
    }
}

extension OnboardingVC: OnboardingDataDelegate {
    func dataViewControllerDidEnterData(_ controller: OnboardingDataVC, data: Any?) {
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
                showNextViewController(photoVC)
            }
        }
        else if controller == photoVC {
            imageData = data as? Data
            showNextViewController(typeVC)
        }
        else if controller == typeVC {
            type = UserType(rawValue: data as! String)!
            signup()
        }
    }
    
    func validateDataForController(_ controller: OnboardingDataVC, data: Any?) -> Bool {
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

