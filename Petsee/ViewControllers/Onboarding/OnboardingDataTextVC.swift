//
//  OnboardingDataTextVC.swift
//  Petsee
//
//  Created by Ariel Pollack on 03/05/2016.
//  Copyright © 2016 Ariel Pollack. All rights reserved.
//

import UIKit

class OnboardingDataTextVC: OnboardingDataVC {
    
    @IBOutlet var txtData: DataTextField?
    
    @IBInspectable var isRequiredField: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtData?.delegate = self
    }
}

extension OnboardingDataTextVC: DataTextFieldDelegate {
    
    func textFieldDidFinishEnteringData(textField: DataTextField) {
        self.delegate?.dataViewControllerDidEnterData(self, data: textField.text)
    }
    
    func validateTextFieldData(textField: DataTextField) -> Bool {
        guard let text = textField.text where text.characters.count > 0 else {
            return !isRequiredField
        }
        return delegate?.validateDataForController(self, data: text) ?? true
    }
}
