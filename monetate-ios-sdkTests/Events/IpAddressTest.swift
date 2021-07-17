//
//  IpAddressTest.swift
//  monetate-ios-sdkTests
//
//  Created by Umar Sayyed on 03/11/20.
//  Copyright © 2020 Monetate. All rights reserved.
//

import XCTest
@testable import Monetate

class IpAddressTest: XCTestCase {   
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testIsFlushNotRequired () {
        let val1 = IPAddress(ipAddress: "192.168.0.1")
        let val2 = IPAddress(ipAddress: "192.168.0.1")
        
        let result = val1.isContextSwitched(ctx: val2)
        XCTAssertTrue(result == false, "Flush was not required")
    }
    
    func testIsFlushRequired () {
        let val1 = IPAddress(ipAddress: "192.168.0.1")
        let val2 = IPAddress(ipAddress: "192.168.0.9")
        
        let result = val1.isContextSwitched(ctx: val2)
        XCTAssertTrue(result == true, "Flush was required")
    }
}
