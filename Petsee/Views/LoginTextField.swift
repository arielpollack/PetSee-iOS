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
    @IBInspectable var borderWidth: Float! = 3.0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    @IBInspectable var securedText: Bool = false {
        didSet {
            self.textField.secureTextEntry = self.securedText;
        }
    }
    @IBInspectable var placeholder: String = "" {
        didSet {
            self.label.text = placeholder;
        }
    }
    
    private lazy var label: UILabel = {
        let label = UILabel(frame: self.bounds)
        label.font = UIFont.italicSystemFontOfSize(18)
        self.addSubview(label)
        return label
    }()
    
    private lazy var textField: UITextField = {
        let txtField = UITextField(frame: self.bounds)
        txtField.font = UIFont.boldSystemFontOfSize(18)
        self.addSubview(txtField)
        return txtField
    }()
    
    var text: String? {
        get {
            return self.textField.text
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadView()
    }
    
    func loadView() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UITextInputDelegate.textDidChange(_:)), name: UITextFieldTextDidChangeNotification, object: textField)
    }
    
    func textDidChange(notification: NSNotification) {
        guard let text = textField.text where text.characters.count > 0 else {
            showPlaceholder()
            return
        }
        
        hidePlaceholder()
    }
    
    private func showPlaceholder() {
        UIView.animateWithDuration(0.1) { 
            self.label.alpha = 1
        }
    }
    
    private func hidePlaceholder() {
        UIView.animateWithDuration(0.1) {
            self.label.alpha = 0
        }
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        let context = UIGraphicsGetCurrentContext()
        CGContextSetLineWidth(context, CGFloat(self.borderWidth))
        CGContextSetStrokeColorWithColor(context, self.color.CGColor)
        CGContextMoveToPoint(context, 0, CGRectGetMaxY(rect) - (CGFloat(self.borderWidth) / 2.0))
        CGContextAddLineToPoint(context, CGRectGetMaxX(rect), CGRectGetMaxY(rect) - (CGFloat(self.borderWidth) / 2.0))
        CGContextStrokePath(context)
    }
}
