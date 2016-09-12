//
//  NotificationsStore.swift
//  Petsee
//
//  Created by Ariel Pollack on 12/09/2016.
//  Copyright © 2016 Ariel Pollack. All rights reserved.
//

import Foundation

struct NotificationsStore {
    
    static let sharedStore: ObjectStore<Notification> = {
        return ObjectStore<Notification>(loader: { callback in
            PetseeAPI.getNotifications(callback)
        })
    }()
    
}