//
//  swiftygetTests.swift
//  swiftygetTests
//
//  Created by Nik Rodionov
//  Copyright © 2019 Nik Rodionov. All rights reserved.
//

import XCTest
@testable import swiftyget

class MockData : DataTransformable {
    convenience init() {
        self.init(data: Data())!
    }
    
    required init?(data: Data) {
        
    }
    
    func toData() -> Data? {
        return nil
    }
    
    var cost: Int = 0
}

class CacheTests: XCTestCase {
    let cache = MemCache<MockData>()
    override func setUp() {
        cache.cleanUp()
        cache.resize(to: 50)
    }

    override func tearDown() {
        cache.cleanUp()
    }

    func testLRUCache() {
        let image1 = MockData()
        image1.cost = 20
        let image2 = MockData()
        image1.cost = 20
        let image3 = MockData()
        image1.cost = 20
        
        cache.store(item: image1, for: "1")
        XCTAssert(cache.value(for: "1") === image1)
        
        cache.store(item: image2, for: "2")
        XCTAssert(cache.value(for: "1") === image1)
        XCTAssert(cache.value(for: "2") === image2)
        
        cache.store(item: image3, for: "3")
        
        XCTAssertFalse(cache.value(for: "1") === image2)
        XCTAssert(cache.value(for: "2") === image2)
        XCTAssert(cache.value(for: "3") === image3)
    }

}
