//
//  swiftygetTests.swift
//  swiftygetTests
//
//  Created by Nik Rodionov
//  Copyright © 2019 Nik Rodionov. All rights reserved.
//

import XCTest
@testable import swiftyget

class DownloaderTests: XCTestCase {
    let downloader = Downloader<UIImage>()
    
    override func setUp() {
    }
    
    override func tearDown() {
        
    }
    
    func testDownload() {
        let urlStr = "https://images.unsplash.com/photo-1464550883968-cec281c19761"
        guard let url = URL(string: urlStr) else { XCTFail(); return }
        
        let expectation = XCTestExpectation(description: "Downloading task")
        downloader
            .retrieve(url: url)
            .then{ 
                XCTAssertNotNil($0)
                expectation.fulfill()
        }
        
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    
    func testAsyncGetWithCancel() {
        let urlStr = "https://images.unsplash.com/photo-1464550838636-1a3496df938b"
        guard let url = URL(string: urlStr) else { XCTFail(); return }
        
        let expectation = XCTestExpectation(description: "Canceling task")
        let expectationGet = XCTestExpectation(description: "Downloading task")
        let future = downloader.retrieve(url: url)
        future.failed{ 
            XCTAssert($0 == .cancel)
            expectation.fulfill()
        }
        
        future.cancel()
        
        let futureGet = downloader.retrieve(url: url)
        futureGet.then{ 
            XCTAssertNotNil($0)
            expectationGet.fulfill()
        }
        
        wait(for: [expectation, expectationGet], timeout: 10.0)
    }
    
    func testCancel() {
        let urlStr = "https://images.unsplash.com/photo-1464550838636-1a3496df938b"
        guard let url = URL(string: urlStr) else { XCTFail(); return }
        
        let expectation = XCTestExpectation(description: "Canceling task")
        let future = downloader.retrieve(url: url)
        future.failed{ 
            XCTAssert($0 == .cancel)
            expectation.fulfill()
        }
        
        future.cancel()
        
        wait(for: [expectation], timeout: 10.0)
    }
}
