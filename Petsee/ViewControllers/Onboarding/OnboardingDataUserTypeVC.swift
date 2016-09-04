//
//  OnboardingDataUserTypeVC.swift
//  Petsee
//
//  Created by Ariel Pollack on 03/05/2016.
//  Copyright © 2016 Ariel Pollack. All rights reserved.
//

import UIKit

class OnboardingDataUserTypeVC: OnboardingDataVC {
    
    @IBAction func clientTapped() {
        self.delegate?.dataViewControllerDidEnterData(self, data: UserType.Client.rawValue)
    }
    
    @IBAction func serviceProviderTapped() {
        self.delegate?.dataViewControllerDidEnterData(self, data: UserType.ServiceProvider.rawValue)
    }
}
