//
//  OnboardingDataVC.swift
//  Petsee
//
//  Created by Ariel Pollack on 03/05/2016.
//  Copyright © 2016 Ariel Pollack. All rights reserved.
//

import UIKit

protocol OnboardingDataDelegate: NSObjectProtocol {
    func dataViewControllerDidEnterData(controller: OnboardingDataVC, data: AnyObject?)
    func validateDataForController(controller: OnboardingDataVC, data: AnyObject?) -> Bool
}


class OnboardingDataVC: UIViewController {
    
    weak var delegate: OnboardingDataDelegate?
}