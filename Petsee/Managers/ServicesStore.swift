//
//  ServicesStore.swift
//  Petsee
//
//  Created by Ariel Pollack on 20/08/2016.
//  Copyright © 2016 Ariel Pollack. All rights reserved.
//

import Foundation
import PetseeCore
import PetseeNetwork

struct ServicesStore {
    
    static let sharedStore: ObjectStore<Service> = {
        return ObjectStore<Service>(loader: { callback in
            PetseeAPI.myServices(callback)
        })
    }()
    
}