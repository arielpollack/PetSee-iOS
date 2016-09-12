//
//  NotificationsVC.swift
//  Petsee
//
//  Created by Ariel Pollack on 12/09/2016.
//  Copyright © 2016 Ariel Pollack. All rights reserved.
//

import UIKit

class NotificationsVC: UIViewController {
    
    @IBOutlet weak var tableNotifications: UITableView!
    
    private var notifications = [Notification]()
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // reload from server
        NotificationsStore.sharedStore.loadObjects()
        
        // load from local storage
        loadNotifications()
        
        // mark all notifications as read
        PetseeAPI.clearNotifications { _, _ in
            
            // tell the home view controller to clear the notifications badge
            NSNotificationCenter.defaultCenter().postNotificationName(HomeVC.Notification.ClearBadge, object: nil)
        }
    }
    
    private func loadNotifications() {
        NotificationsStore.sharedStore.fetchAll { notifications in
            self.notifications = notifications
            self.tableNotifications.reloadData()
        }
    }
}

extension NotificationsVC: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Notification") as! NotificationCell
        let notification = notifications[indexPath.row]
        cell.notification = notification
        return cell
    }
}
