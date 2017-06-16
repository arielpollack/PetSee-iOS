//
//  UIColor+Addons.swift
//  Petsee
//
//  Created by Ariel Pollack on 04/05/2016.
//  Copyright © 2016 Ariel Pollack. All rights reserved.
//

import UIKit

extension UIColor {
    
    convenience init?(hex: String) {
        let hexColor = hex.replacingOccurrences(of: "#", with: "")
        
        let scanner = Scanner(string: hexColor)
        var hexNum: UInt32 = 0
        if !scanner.scanHexInt32(&hexNum) {
            return nil
        }
        
        let r = CGFloat((hexNum >> 16) & 0xFF) / 255;
        let g = CGFloat((hexNum >> 8) & 0xFF) / 255;
        let b = CGFloat((hexNum) & 0xFF) / 255;
        self.init(red: r, green: g, blue: b, alpha: 1)
    }
    
    func image(_ size: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()
        
        context?.setFillColor(self.cgColor)
        context?.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    func darker() -> UIColor {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return UIColor(hue: h, saturation: s, brightness: b * 0.6, alpha: a)
    }
    
    func lighter() -> UIColor {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return UIColor(hue: h, saturation: s, brightness: b * 1.4, alpha: a)
    }
    
    func onTopTextColor() -> UIColor {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let d = 0.299 * r + 0.587 * g + 0.114 * b;
        if (d < 0.5 && a > 0.5) {
            return UIColor.white
        } else {
            return UIColor.black
        }
    }
}
