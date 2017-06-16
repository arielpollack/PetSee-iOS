//
//  DeepLinkManager.swift
//  Petsee
//
//  Created by Ariel Pollack on 12/09/2016.
//  Copyright © 2016 Ariel Pollack. All rights reserved.
//

import Foundation

struct DeepLinkManager {
    
    static func openNotification(_ notification: Notification, fromViewController fromVC: UIViewController, push: Bool = false) {
        
        let viewController: UIViewController
        var push = push
        var animated = true
        let storyboard = UIStoryboard(name: "Client", bundle: nil)
        
        switch notification.type! {
        case .requestYourService:
            viewController = storyboard.instantiateViewController(withIdentifier: "ServiceRequests")
            push = false // override push
            
        case .approvedYourRequest:
            guard let service = notification.object as? Service else {
                return
            }
            
            let serviceVC = storyboard.instantiateViewController(withIdentifier: "ServiceVC") as! ServiceVC
            serviceVC.showServiceProvidersOnOpen = true
            serviceVC.service = service
            viewController = serviceVC
            animated = false
            
        default:
            guard let service = notification.object as? Service else {
                return
            }
            
            let serviceVC = storyboard.instantiateViewController(withIdentifier: "ServiceVC") as! ServiceVC
            serviceVC.service = service
            viewController = serviceVC
        }
        
        if push {
            fromVC.navigationController?.pushViewController(viewController, animated: animated)
        } else {
            fromVC.present(viewController, animated: animated, completion: nil)
        }
    }
}
