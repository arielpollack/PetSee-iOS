//
//  UIViewController+Additions.swift
//  Petsee
//
//  Created by Ariel Pollack on 08/05/2016.
//  Copyright © 2016 Ariel Pollack. All rights reserved.
//

import UIKit

extension UIViewController {
    func embededInNavigationController() -> UINavigationController {
        return UINavigationController(rootViewController: self)
    }
    
    class func topMostViewController() -> UIViewController? {
        if var topController = UIApplication.shared.keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            
            return topController
        }
        return nil
    }
}
