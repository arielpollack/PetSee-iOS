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
        let hexColor = hex.stringByReplacingOccurrencesOfString("#", withString: "")
        
        let scanner = NSScanner(string: hexColor)
        var hexNum: UInt32 = 0
        if !scanner.scanHexInt(&hexNum) {
            return nil
        }
        
        let r = CGFloat((hexNum >> 16) & 0xFF) / 255;
        let g = CGFloat((hexNum >> 8) & 0xFF) / 255;
        let b = CGFloat((hexNum) & 0xFF) / 255;
        self.init(red: r, green: g, blue: b, alpha: 1)
    }
    
    func image(size: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()
        
        CGContextSetFillColorWithColor(context, CGColor)
        CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height))
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
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
            return UIColor.whiteColor()
        } else {
            return UIColor.blackColor()
        }
    }
}