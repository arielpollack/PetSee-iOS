//
//  ClientHomeVC.swift
//  Petsee
//
//  Created by Ariel Pollack on 12/09/2016.
//  Copyright © 2016 Ariel Pollack. All rights reserved.
//

import UIKit

class HomeVC: UITabBarController {
    
    struct Notification {
        static let ClearBadge = "ClearNotificationsBadgeNotification"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadNotificationsCount()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: Notification.ClearBadge), object: nil, queue: nil) { [weak self] _ in
            self?.setNotificationsBadgeCount(0)
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationDidBecomeActive, object: nil, queue: nil, using: { [weak self] _ in
            self?.loadNotificationsCount()
            })
    }
    
    fileprivate func loadNotificationsCount() {
        NotificationsStore.sharedStore.loadObjects() {
            NotificationsStore.sharedStore.fetchAll { notifications in
                let unreadNotifications = notifications.filter { !$0.read }
                self.setNotificationsBadgeCount(unreadNotifications.count)
            }
        }
    }
    
    fileprivate func setNotificationsBadgeCount(_ count: Int) {
        let notificationItem = self.tabBar.items![1]
        notificationItem.badgeValue = count > 0 ? "\(count)" : nil
    }
}
