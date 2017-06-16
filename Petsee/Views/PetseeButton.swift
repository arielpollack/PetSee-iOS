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
    
    @IBInspectable var color: UIColor = UIColor.black {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        switch self.state {
        case UIControlState.selected:
            fallthrough
        case UIControlState.highlighted:
            backgroundColor = self.color.withAlphaComponent(0.8)
        case UIControlState.disabled:
            backgroundColor = self.color.withAlphaComponent(0.2)
        default:
            backgroundColor = self.color
        }
        
        layer.shadowColor = color.darker().cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 0
        layer.shadowOpacity = 1
    }
}
