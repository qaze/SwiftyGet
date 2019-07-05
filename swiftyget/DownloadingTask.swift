//
//  DownloadingTask.swift
//  swiftyget
//
//  Created by Nik Rodionov
//  Copyright © 2019 Nik Rodionov. All rights reserved.
//

import Foundation

/// Task wrapper for downloading data 
internal class DownloadingTask <Type : DataTransformable> {
    
    /// Futures to complete or fail on download completion
    private var futures = [FutureObject<Type>]()
    
    
    /// Native task
    private let task : URLSessionDataTask
    
    required init( with dataTask : URLSessionDataTask ) {
        task = dataTask
    }
    
    
    /// Adds new future object to complete or fail
    /// - Parameter future: future object
    func addFuture( future: FutureObject<Type> ) {
        futures.append(future)
    }
    
    
    /// Complete task
    /// - Parameter object: result object
    func complete(with object: Type) {
        futures.filter{ !$0.isFailed() }.forEach{ $0.complete(with: object) }
    }
    
    
    /// Fails task
    /// - Parameter error: error occured
    func fail( with error: Error ) {
        futures.filter{ !$0.isFailed() }.forEach{ $0.fail(with: error) }
    }
}
