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
    
    fileprivate var notifications = [Notification]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableNotifications.estimatedRowHeight = 50
        tableNotifications.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // reload from server
        NotificationsStore.sharedStore.loadObjects()
        
        // load from local storage
        loadNotifications()
        
        // mark all notifications as read
        PetseeAPI.clearNotifications { _, _ in
            
            // tell the home view controller to clear the notifications badge
            NotificationCenter.default.post(name: Foundation.Notification.Name(rawValue: HomeVC.Notification.ClearBadge), object: nil)
        }
    }
    
    fileprivate func loadNotifications() {
        NotificationsStore.sharedStore.fetchAll { notifications in
            self.notifications = notifications
            self.tableNotifications.reloadData()
        }
    }
}

extension NotificationsVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Notification") as! NotificationCell
        let notification = notifications[indexPath.row]
        cell.notification = notification
        return cell
    }
}


extension NotificationsVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let notification = notifications[indexPath.row]
        DeepLinkManager.openNotification(notification, fromViewController: self, push: true)
    }
}
