//
//  PetsStore.swift
//  Petsee
//
//  Created by Ariel Pollack on 02/08/2016.
//  Copyright © 2016 Ariel Pollack. All rights reserved.
//

import Foundation
import PetseeCore
import PetseeNetwork

struct PetsStore {
    
    static let sharedStore: ObjectStore<Pet> = {
        return ObjectStore<Pet>(loader: { callback in
            PetseeAPI.myPets(callback)
        })
    }()
    
}