//
//  ICache.swift
//  swiftyget
//
//  Created by Nik Rodionov
//  Copyright © 2019 Nik Rodionov. All rights reserved.
//

import Foundation

/// Base protocol for caching storage
protocol ICache {
    associatedtype `Type` : DataTransformable
    /// Stores Cached items in storage
    ///
    /// - Parameter item: cached item
    func store( item: Type, for key: String ) -> Void
    
    
    /// Retrives cached item from storage
    ///
    /// - Parameter for: key for cached item
    /// - Returns: CachedItem if found
    func value( for: String ) -> Type?
    
    
    /// Removes all elements from storage
    func cleanUp() -> Void
    
    var capacity : Int { get }
    var size : Int { get }
}

/// Weak container for DataTransformable - types
class Weakly <Type: DataTransformable> {
    weak var data : Type?
    
    init( with obj: Type ) {
        data = obj
    }
}

/// LRU ( Last Recently Used ) in-Memory cache
class MemCache <Type : DataTransformable> {
    /// Capacity of cache
    var capacity: Int = Int.max
    
    /// Current size of objects in cache
    var size : Int = 0
    
    /// Map of weak references to objects for fast access via identifier
    private var objects = [String: Weakly<Type>]()
    
    
    private let lock = NSLock()
    
    /// List of objects handle strong references to obejcts
    /// Objects are sorted in LRU-order
    private var list = [Type]() 
    
    internal init( ) {
        NotificationCenter.default.addObserver(self, 
                                               selector: #selector(didRecieveMemoryWarning(_:)), 
                                               name: UIApplication.didReceiveMemoryWarningNotification, 
                                               object: nil)
    }
    
    @objc func didRecieveMemoryWarning( _ notification: Notification ) {
        cleanUp()
    }
}

extension MemCache : ICache {
    
    /// Add new element to cache
    /// Also checks for size vs capacity and remove if have any
    /// - Parameter item: item to sotre
    /// - Parameter key: identifier
    func store( item: Type, for key: String ) {
        lock.lock()
        defer { lock.unlock() }
        objects[key] = Weakly(with: item)
        list.append(item)
        size += item.cost
        while size > capacity { removeTail() }
    }
    
    /// Removes last recently used
    func removeTail() {
        lock.lock()
        defer { lock.unlock() }
        if let first = list.first {
            list.removeFirst()
            size -= first.cost
        }
    }
    
    /// Resizes cache to new capacity
    /// - Parameter to: new size
    func resize( to: Int ) {
        capacity = to
        while size > capacity { removeTail() }
    }
    
    /// Retrieves value
    /// - Parameter key: identifier
    func value(for key: String) -> Type? {
        lock.lock()
        defer { lock.unlock() }
        if let weakObj = objects[key], let obj = weakObj.data {
            list.removeAll { (data) -> Bool in
                return data === obj
            }
            
            list.append(obj)
            return obj
        }
        
        return nil
    }
    
    
    /// Removes all element
    func cleanUp() {
        lock.lock()
        defer { lock.unlock() }
        objects.removeAll()
    }
}
