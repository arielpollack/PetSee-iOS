//
//  ObjectStore.swift
//  Petsee
//
//  Created by Ariel Pollack on 20/08/2016.
//  Copyright © 2016 Ariel Pollack. All rights reserved.
//

import Foundation

class ObjectStore<T: Equatable> {
    
    fileprivate var objects = [T]()
    
    fileprivate let fetchQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "com.petsee.\(T.self)Store.fetchQueue"
        queue.isSuspended = true
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    
    typealias LoaderFunction = (@escaping ([T]?, String?) -> ()) -> ()
    
    fileprivate var objectsLoader: LoaderFunction
    
    init(loader: @escaping LoaderFunction) {
        self.objectsLoader = loader
        self.loadObjects()
    }
    
    fileprivate func retryLoadingObjects() {
        let time = DispatchTime.now() + Double(Int64(2 * NSEC_PER_SEC)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: time) {
            self.loadObjects()
        }
    }
    
    func loadObjects(_ completion: @escaping ()->() = {}) {
        objectsLoader { objects, error in
            self.fetchQueue.isSuspended = true
            completion()
            
            guard let objects = objects else {
                self.retryLoadingObjects()
                return
            }
            
            self.objects = objects
            self.fetchQueue.isSuspended = false
        }
    }
    
    func fetchAll(_ completion: @escaping ([T])->()) {
        self.fetchQueue.addOperation {
            OperationQueue.main.addOperation({
                completion(self.objects)
            })
        }
    }
    
    func fetchPredicate(_ predicate: @escaping (T)->Bool, completion: @escaping ([T])->()) {
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
    
    func add(_ object: T) {
        guard !objects.contains(object) else {
            return
        }
        
        objects.append(object)
    }
    
    func remove(_ object: T) {
        guard let index = objects.index(of: object) else {
            return
        }
        
        objects.remove(at: index)
    }
    
    func replace(_ object: T) {
        if let index = objects.index(of: object) {
            objects[index] = object
        }
    }
}
