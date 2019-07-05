//
//  FutureObject.swift
//  swiftyget
//
//  Created by Nik Rodionov
//  Copyright © 2019 Nik Rodionov. All rights reserved.
//

import Foundation

/// State of future object
public enum FutureObjectState {
    case idle, active, ready, failed
}

/// Future object specific errors
public enum FutureObjectError : Error {
    case cancel
}

/// Future object represents:
/// Objects of specific type inherited from DataTransformable
/// That can be transformed to and from Data 
/// That currently may exists or not 
public final class FutureObject < Type : DataTransformable > {
    public typealias SuccessFutureHandler = ( _ object: Type ) -> Void
    public typealias FailureFutureHandler = ( _ error: FutureObjectError ) -> Void
    public typealias StateFutureHandler = ( _ state: FutureObjectState ) -> Void
    
    internal var object : Type? {
        didSet {
            if object != nil { state = .ready }
        }
    }
    
    internal var error : FutureObjectError? {
        didSet {
            if error != nil { state = .failed }
        }
    }
    
    private var successHandler : [SuccessFutureHandler?] = []
    private var failureHandler : [FailureFutureHandler?] = []
    private var stateHandler : [StateFutureHandler?] = []
    
    let id : String 
    init( identifier : String ) {
        id = identifier
    }
    
    init( identifier : String, succededWith: Type ) {
        object = succededWith
        id = identifier
        state = .ready
    }
    
    private var state : FutureObjectState = .idle {
        didSet {
            stateHandler.forEach{ $0?(state) }
            if state == .ready, let obj = object {
                successHandler.forEach{ $0?(obj) }
                successHandler.removeAll()
            }
            
            if state == .failed, let err = error {
                failureHandler.forEach{ $0?(err) }
                failureHandler.removeAll()
            }
        }
    }
    
    internal func started() {
        state = .active
    }
    
    /// Represents if object is ready to use
    public func isReady() -> Bool {
        return state == .ready
    }
    
    /// Represents if object is failed
    public func isFailed() -> Bool {
        return state == .failed
    }
    
    /// Cancels downloading of current object
    public func cancel() {
        if !isReady() {
            fail(with: FutureObjectError.cancel)
        }
    }
    
    /// Subscribe via this method
    /// and it will notify when object will be ready to use
    /// - Parameter completion: notification-handler
    public func then( _ completion : @escaping SuccessFutureHandler ) {
        if isReady(), let obj = object {
            completion(obj)
        }
        else {
            successHandler.append(completion)
        }
    }
    
    /// Subscribe via this method
    /// and it will notify when object will fail
    /// - Parameter completion: notification-handler
    public func failed( _ completion : @escaping FailureFutureHandler ) {
        if isFailed(), let err = error {
            completion(err)
        }
        else {
            failureHandler.append(completion)
        }
    }
    
    /// Subscribe via this method
    /// and it will notify when object state will change
    /// - Parameter completion: notification-handler
    public func onStateChanged( _ handler: @escaping StateFutureHandler ) {
        stateHandler.append(handler)
    }
}

internal extension FutureObject {
    func fail( with error: Error ) {
        self.error = error as? FutureObjectError
        state = .failed
    }
    
    func complete( with data: Type ) {
        object = data
        state = .ready
    }
}
