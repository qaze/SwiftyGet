//
//  Downloader.swift
//  swiftyget
//
//  Created by Nik Rodionov
//  Copyright © 2019 Nik Rodionov. All rights reserved.
//

import Foundation

/// Downloader controller for specific data type
internal class Downloader <Type: DataTransformable> {
    /// Session for downloading
    private let session = URLSession(configuration: .default)
    
    /// in-Memory Cache
    private var memCache = MemCache<Type>()
    
    
    /// Pending downloading tasks
    private var pendingTasks = [String: DownloadingTask<Type>]()
    
    /// Lock for sync tasks access
    private let lock = NSLock()
    
    
    /// Retrives FutureObject for URL
    /// - Parameter url: url
    func retrieve(url: URL) -> FutureObject<Type> {
        lock.lock()
        defer { lock.unlock() }
        if let obj = memCache.value(for: url.absoluteString) {
            return FutureObject(identifier: url.absoluteString, succededWith: obj)
        }
        else if let task = pendingTasks[url.absoluteString] {
            let future = FutureObject<Type>(identifier: url.absoluteString)
            future.started()
            task.addFuture(future: future)
            return future
        }
        else {
            let future = FutureObject<Type>(identifier: url.absoluteString)
            future.started()
            let dataTask = session.dataTask(with: url) { [weak self] (data, response, error) in
                self?.dataTaskCompletion(data: data, response: response, error: error)
            }
            
            dataTask.resume()
            let task = DownloadingTask<Type>(with: dataTask)
            task.addFuture(future: future)
            pendingTasks[url.absoluteString] = task
            
            return future
        }
    }
    
    /// Data task completion
    /// - Parameter data: data revieved
    /// - Parameter response: response received
    /// - Parameter error: error occured
    private func dataTaskCompletion( data: Data?, response: URLResponse?, error: Error? ) {
        lock.lock()
        defer { lock.unlock() }
        
        guard let response = response, let url = response.url else { return }
        guard let task = pendingTasks[url.absoluteString] else { return }
        if let data = data, let objData = Type(data: data), error == nil {
            task.complete(with: objData)
        }
        else if let error = error {
            task.fail(with: error)
        }
        pendingTasks[url.absoluteString] = nil
    }
    
    
    /// Resize cache
    /// - Parameter bytes: new size
    func setCacheSize( _ bytes : Int ) {
        memCache.resize(to: bytes)
    }
}
