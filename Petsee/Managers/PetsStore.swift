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

class PetsStore {
    
    static let sharedManager = PetsStore()
    
    private var pets = [Pet]()
    
    private let fetchQueue: NSOperationQueue = {
        let queue = NSOperationQueue()
        queue.name = "com.petsee.petsStore.fetchQueue"
        queue.suspended = true
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    private init() {
        self.loadPets()
    }
    
    private func retryLoadingPets() {
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(2 * NSEC_PER_SEC))
        dispatch_after(time, dispatch_get_main_queue()) {
            self.loadPets()
        }
    }
    
    private func loadPets() {
        PetseeAPI.myPets { (pets, error) in
            self.fetchQueue.suspended = true
            guard let pets = pets else {
                self.retryLoadingPets()
                return
            }
            
            self.pets = pets
            self.fetchQueue.suspended = false
        }
    }
    
    func fetchAllPets(completion: [Pet]->()) {
        self.fetchQueue.addOperationWithBlock {
            NSOperationQueue.mainQueue().addOperationWithBlock({ 
                completion(self.pets)
            })
        }
    }
}