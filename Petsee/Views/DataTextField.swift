//
//  DataTextField.swift
//  Petsee
//
//  Created by Ariel Pollack on 30/04/2016.
//  Copyright © 2016 Ariel Pollack. All rights reserved.
//

import UIKit

@objc protocol DataTextFieldDelegate {
    func textFieldDidFinishEnteringData(_ textField: DataTextField)
    func validateTextFieldData(_ textField: DataTextField) -> Bool
}

@IBDesignable
class DataTextField: UIView {
    
    @IBInspectable var color: UIColor! = UIColor.black {
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
            self.textField.isSecureTextEntry = self.securedText;
        }
    }
    @IBInspectable var keyboardType: Int = UIKeyboardType.default.rawValue {
        didSet {
            self.textField.keyboardType = UIKeyboardType(rawValue: self.keyboardType) ?? .default
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
    
    fileprivate lazy var label: UILabel = {
        let label = UILabel(frame: self.bounds)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.italicSystemFont(ofSize: 18)
        self.addSubview(label)
        
        label.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        label.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        label.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        label.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 3).isActive = true
        
        return label
    }()
    
    fileprivate lazy var textField: UITextField = {
        let txtField = UITextField(frame: self.bounds)
        txtField.translatesAutoresizingMaskIntoConstraints = false
        txtField.font = UIFont.boldSystemFont(ofSize: 20)
        txtField.returnKeyType = .done
        txtField.autocorrectionType = .no
        self.addSubview(txtField)
        
        txtField.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        txtField.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        txtField.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        txtField.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 3).isActive = true
        
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
        NotificationCenter.default.addObserver(self, selector: #selector(UITextInputDelegate.textDidChange(_:)), name: NSNotification.Name.UITextFieldTextDidChange, object: textField)
    }
    
    func textDidChange(_ notification: Foundation.Notification) {
        guard let text = textField.text, text.characters.count > 0 else {
            showPlaceholder()
            return
        }
        
        hidePlaceholder()
    }
    
    fileprivate func showPlaceholder() {
        UIView.animate(withDuration: 0.1, animations: { 
            self.label.alpha = 1
        }) 
    }
    
    fileprivate func hidePlaceholder() {
        UIView.animate(withDuration: 0.1, animations: {
            self.label.alpha = 0
        }) 
    }
    
    fileprivate func vibrateForInvalid() {
        let animation = CABasicAnimation(keyPath: "position.x")
        animation.duration = 0.06
        animation.byValue = 10
        animation.autoreverses = true
        animation.repeatCount = 3
        layer.add(animation, forKey: "Vibrate")
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        let context = UIGraphicsGetCurrentContext()
        context?.setLineWidth(CGFloat(self.borderWidth))
        context?.setStrokeColor(self.color.cgColor)
        context?.move(to: CGPoint(x: 0, y: rect.maxY - (CGFloat(self.borderWidth) / 2.0)))
        context?.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - (CGFloat(self.borderWidth) / 2.0)))
        context?.strokePath()
    }
}

extension DataTextField: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let valid = delegate?.validateTextFieldData(self) else {
            // if delegate not implemented, return true by default
            DispatchQueue.main.async(execute: {
                self.delegate?.textFieldDidFinishEnteringData(self)
            })
            return true
        }
        DispatchQueue.main.async(execute: {
            if valid {
                self.delegate?.textFieldDidFinishEnteringData(self)
            } else {
                self.vibrateForInvalid()
            }
        })
        return valid
    }
}
