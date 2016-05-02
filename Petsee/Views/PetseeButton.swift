//
//  PetseeButton.swift
//  Petsee
//
//  Created by Ariel Pollack on 02/05/2016.
//  Copyright © 2016 Ariel Pollack. All rights reserved.
//

import UIKit

@IBDesignable
class PetseeButton: UIButton {
    
    @IBInspectable var color: UIColor = UIColor.blackColor() {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        switch self.state {
        case UIControlState.Selected:
            fallthrough
        case UIControlState.Highlighted:
            self.backgroundColor = self.color.colorWithAlphaComponent(0.8)
        case UIControlState.Disabled:
            self.backgroundColor = self.color.colorWithAlphaComponent(0.2)
        default:
            self.backgroundColor = self.color
        }
    }
}
