//
//  DataTextField.swift
//  Petsee
//
//  Created by Ariel Pollack on 30/04/2016.
//  Copyright © 2016 Ariel Pollack. All rights reserved.
//

import UIKit

@objc protocol DataTextFieldDelegate {
    func textFieldDidFinishEnteringData(textField: DataTextField)
    func validateTextFieldData(textField: DataTextField) -> Bool
}

@IBDesignable
class DataTextField: UIView {
    
    @IBInspectable var color: UIColor! = UIColor.blackColor() {
        didSet {
            self.label.textColor = color
            self.setNeedsDisplay()
        }
    }
    @IBInspectable var borderWidth: Float = 3.0 {
        didSet {
            self.setNeedsDisplay()
        }
    }
    @IBInspectable var securedText: Bool = false {
        didSet {
            self.textField.secureTextEntry = self.securedText;
        }
    }
    @IBInspectable var keyboardType: Int = UIKeyboardType.Default.rawValue {
        didSet {
            self.textField.keyboardType = UIKeyboardType(rawValue: self.keyboardType) ?? .Default
        }
    }
    @IBInspectable var placeholder: String = "" {
        didSet {
            self.label.text = placeholder;
        }
    }
    
    weak var delegate: DataTextFieldDelegate? {
        didSet {
            self.textField.delegate = self
        }
    }
    
    private lazy var label: UILabel = {
        let label = UILabel(frame: self.bounds)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.italicSystemFontOfSize(18)
        self.addSubview(label)
        
        label.leadingAnchor.constraintEqualToAnchor(self.leadingAnchor).active = true
        label.trailingAnchor.constraintEqualToAnchor(self.trailingAnchor).active = true
        label.topAnchor.constraintEqualToAnchor(self.topAnchor).active = true
        label.bottomAnchor.constraintEqualToAnchor(self.bottomAnchor, constant: 3).active = true
        
        return label
    }()
    
    private lazy var textField: UITextField = {
        let txtField = UITextField(frame: self.bounds)
        txtField.translatesAutoresizingMaskIntoConstraints = false
        txtField.font = UIFont.boldSystemFontOfSize(20)
        txtField.returnKeyType = .Done
        txtField.autocorrectionType = .No
        self.addSubview(txtField)
        
        txtField.leadingAnchor.constraintEqualToAnchor(self.leadingAnchor).active = true
        txtField.trailingAnchor.constraintEqualToAnchor(self.trailingAnchor).active = true
        txtField.topAnchor.constraintEqualToAnchor(self.topAnchor).active = true
        txtField.bottomAnchor.constraintEqualToAnchor(self.bottomAnchor, constant: 3).active = true
        
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

extension DataTextField: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        guard let valid = delegate?.validateTextFieldData(self) else {
            // if delegate not implemented, return true by default
            delegate?.textFieldDidFinishEnteringData(self)
            return true
        }
        if valid {
            delegate?.textFieldDidFinishEnteringData(self)
        }
        return valid
    }
}
