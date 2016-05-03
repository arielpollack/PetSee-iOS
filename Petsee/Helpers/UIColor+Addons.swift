//
//  UIColor+Addons.swift
//  Petsee
//
//  Created by Ariel Pollack on 04/05/2016.
//  Copyright © 2016 Ariel Pollack. All rights reserved.
//

import UIKit

extension UIColor {
    func darkerColor() -> UIColor {
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        self.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return UIColor(hue: h, saturation: s, brightness: b * 0.7, alpha: a)
    }
}