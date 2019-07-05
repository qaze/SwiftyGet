//
//  SwiftyGetTest.swift
//  swiftygetTests
//
//  Created by Nik Rodionov
//  Copyright © 2019 Nik Rodionov. All rights reserved.
//

import XCTest

class SwiftyGetTest: XCTestCase {
    
    override func setUp() {
        
    }

    override func tearDown() {
        
    }

    func testImageDownload() {
        let urlStr = "https://images.unsplash.com/photo-1464550883968-cec281c19761"
        guard let url = URL(string: urlStr) else { XCTFail(); return }
        
        let expectation = XCTestExpectation(description: "Downloading task")
        SwiftyGet.getImage(url: url)
            .then{ 
                XCTAssertNotNil($0)
                expectation.fulfill()
        }
        
        
        wait(for: [expectation], timeout: 10.0)
    }

}
