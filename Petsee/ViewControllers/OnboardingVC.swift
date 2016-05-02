//
//  OnboardingVC.swift
//  Petsee
//
//  Created by Ariel Pollack on 02/05/2016.
//  Copyright © 2016 Ariel Pollack. All rights reserved.
//

import UIKit

class OnboardingVC: UIPageViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let emailVC = UIStoryboard(name: "Login", bundle: nil).instantiateViewControllerWithIdentifier("Email")
        self.setViewControllers([emailVC], direction: .Forward, animated: false, completion: nil)
    }
}

