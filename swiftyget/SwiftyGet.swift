//
//  SwiftyGet.swift
//  swiftyget
//
//  Created by Nik Rodionov
//  Copyright © 2019 Nik Rodionov. All rights reserved.
//

import Foundation
import UIKit

extension UIImage : DataTransformable {
    public var cost: Int {
        return toData()?.count ?? 0
    }
    
    public func toData() -> Data? {
        return pngData()
    }
}

extension NSData : DataTransformable {
    public func toData() -> Data? {
        return self as Data
    }
    
    public var cost: Int {
        return count
    }
}

public protocol DataTransformable : class {
    init?( data: Data )
    func toData() -> Data?
    var cost : Int { get }
}


/// Public interface for SwiftyGet
/// With two predefined downloaders for:
/// - UIImage
/// - NSData
public class SwiftyGet {
    private static let imageDownloader = Downloader<UIImage>()
    private static let dataDownloader = Downloader<NSData>()
}

extension SwiftyGet {
    
    /// Retrives image
    /// - Parameter url: url
    open class func getImage( url: URL ) -> FutureObject<UIImage> {
        return imageDownloader.retrieve(url: url)
    }
    
    /// Retrives data
    /// - Parameter url: url
    open class func getData( url: URL ) -> FutureObject<NSData> {
        return dataDownloader.retrieve(url: url)
    }
    
    /// Resizes image cache
    /// - Parameter bytes: new size
    open class func setImageCacheSize( _ bytes : Int ) {
        imageDownloader.setCacheSize(bytes)
    }
    
    /// Resizes data cache
    /// - Parameter bytes: new sizes
    open class func setDataCacheSize( _ bytes : Int ) {
        imageDownloader.setCacheSize(bytes)
    }
}
