//
//  NotificationCell.swift
//  Petsee
//
//  Created by Ariel Pollack on 12/09/2016.
//  Copyright © 2016 Ariel Pollack. All rights reserved.
//

import UIKit

class NotificationCell: UITableViewCell {
    
    @IBOutlet weak var lblText: UILabel!
    @IBOutlet weak var lblCreated: UILabel!
    @IBOutlet weak var unreadView: UIView!
    
    var notification: Notification! {
        didSet {
            loadNotification()
        }
    }
    
    fileprivate func loadNotification() {
        lblText.text = notification.text
        lblCreated.text = notification.createdAt.timeAgo
        unreadView.isHidden = notification.read
    }
}
