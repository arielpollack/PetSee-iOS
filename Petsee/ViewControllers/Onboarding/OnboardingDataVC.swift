//
//  OnboardingDataVC.swift
//  Petsee
//
//  Created by Ariel Pollack on 03/05/2016.
//  Copyright © 2016 Ariel Pollack. All rights reserved.
//

import UIKit

protocol OnboardingDataDelegate: NSObjectProtocol {
    func dataViewControllerDidEnterData(_ controller: OnboardingDataVC, data: Any?)
    func validateDataForController(_ controller: OnboardingDataVC, data: Any?) -> Bool
}


class OnboardingDataVC: UIViewController {
    
    weak var delegate: OnboardingDataDelegate?
}
