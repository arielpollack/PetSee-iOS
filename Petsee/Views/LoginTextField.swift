//
//  LoginTextField.swift
//  Petsee
//
//  Created by Ariel Pollack on 30/04/2016.
//  Copyright © 2016 Ariel Pollack. All rights reserved.
//

import UIKit

@IBDesignable
class LoginTextField: UIView {
    
    @IBInspectable var color: UIColor! = UIColor.blackColor() {
        didSet {
            self.label.textColor = color
            self.setNeedsDisplay()
        }
    }
    @IBInspectable var borderWidth: Float! = 5.0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    private lazy var label: UILabel = {
        let label = UILabel(frame: self.frame)
        label.font = UIFont.italicSystemFontOfSize(18)
        label.textColor = UIColor.darkGrayColor()
        self.addSubview(label)
        return label
    }()
    
    @IBInspectable var placeholder: String = "" {
        didSet {
            self.label.text = placeholder;
        }
    }
    
    override func drawRect(rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        CGContextSetLineWidth(context, CGFloat(self.borderWidth))
        CGContextSetStrokeColorWithColor(context, self.color.CGColor)
        CGContextMoveToPoint(context, 0, CGRectGetMaxY(rect) - (CGFloat(self.borderWidth) / 2.0))
        CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMaxY(rect) - (CGFloat(self.borderWidth) / 2.0))
        CGContextStrokePath(context)
    }
}
