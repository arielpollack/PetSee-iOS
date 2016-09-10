//
//  ObjectStore.swift
//  Petsee
//
//  Created by Ariel Pollack on 20/08/2016.
//  Copyright © 2016 Ariel Pollack. All rights reserved.
//

import Foundation

class ObjectStore<T: Equatable> {
    
    private var objects = [T]()
    
    private let fetchQueue: NSOperationQueue = {
        let queue = NSOperationQueue()
        queue.name = "com.petsee.\(T.self)Store.fetchQueue"
        queue.suspended = true
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    typealias LoaderFunction = (([T]?, String?) -> ()) -> ()
    
    private var objectsLoader: LoaderFunction
    
    init(loader: LoaderFunction) {
        self.objectsLoader = loader
        self.loadObjects()
    }
    
    private func retryLoadingObjects() {
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(2 * NSEC_PER_SEC))
        dispatch_after(time, dispatch_get_main_queue()) {
            self.loadObjects()
        }
    }
    
    private func loadObjects() {
        objectsLoader { objects, error in
            self.fetchQueue.suspended = true
            guard let objects = objects else {
                self.retryLoadingObjects()
                return
            }
            
            self.objects = objects
            self.fetchQueue.suspended = false
        }
    }
    
    func fetchAll(completion: [T]->()) {
        self.fetchQueue.addOperationWithBlock {
            NSOperationQueue.mainQueue().addOperationWithBlock({
                completion(self.objects)
            })
        }
    }
    
    func fetchPredicate(predicate: T->Bool, completion: [T]->()) {
        fetchAll { objects in
            var results = [T]()
            for object in objects {
                if predicate(object) {
                    results.append(object)
                }
            }
            completion(results)
        }
    }
    
    func add(object: T) {
        guard !objects.contains(object) else {
            return
        }
        
        objects.append(object)
    }
    
    func remove(object: T) {
        guard let index = objects.indexOf(object) else {
            return
        }
        
        objects.removeAtIndex(index)
    }
    
    func replace(object: T) {
        if let index = objects.indexOf(object) {
            objects[index] = object
        }
    }
}