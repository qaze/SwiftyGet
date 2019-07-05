//
//  swiftygetTests.swift
//  swiftygetTests
//
//  Created by Nik Rodionov
//  Copyright © 2019 Nik Rodionov. All rights reserved.
//

import XCTest
@testable import swiftyget

class CacheTests: XCTestCase {
    let cache = MemCache<UIImage>(capacity: 60)
    override func setUp() {
        cache.cleanUp()
    }

    override func tearDown() {
        cache.cleanUp()
    }

    func testSmoke() {
        let image1 = UIImage()
        let image2 = UIImage()
        let image3 = UIImage()
        
        cache.store(item: image1, for: "1")
        cache.store(item: image2, for: "2")
        cache.store(item: image3, for: "3")
        
        XCTAssert(cache.value(for: "2") === image2)
        XCTAssert(cache.value(for: "3") === image3)
    }

}
