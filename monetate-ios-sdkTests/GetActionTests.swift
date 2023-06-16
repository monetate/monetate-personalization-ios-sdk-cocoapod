//
//  GetActionTests.swift
//  monetate-ios-sdkTests
//
//  Created by Umar Sayyed on 25/11/20.
//  Copyright © 2020 Monetate. All rights reserved.
//

import XCTest
@testable import Monetate

class GetActionTests: XCTestCase {
    let requestid = "123456"
    override func setUp() {
        setupPersonalizationSDK()
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testGetActionsProductDetailsView () {
        let exp = XCTestExpectation(description: "Testing testGetActions api ")
        var code = 400;
        Personalization.shared.getActions(context: .ProductDetailView, requestId: requestid, arrActionTypes: [.OmniChannelJson], event: ProductDetailView(products: [Product(productId: "PROD-278", sku: "DENIM Jeans")])).on(success: { (res) in
            
            print("response", res.status, res.data?.toString)
            if let key = res.status {
                code = key
            }
            exp.fulfill()
        })
        wait(for: [exp], timeout: 20)
        XCTAssertEqual(code, 200, "testGetActions not working as expected")
    }
    
    func testGetActionsPageEvent () {
        let exp = XCTestExpectation(description: "Testing testGetActions api ")
        var code = 400;
        Personalization.shared.getActions(context: .PageEvents, requestId: requestid, arrActionTypes: [.OmniChannelJson], event: PageEvents(pageEvents: ["Page 1", "Page 2", "Page 3"])).on(success: { (res) in
            
            print("response", res.status, res.data?.toString)
            if let key = res.status {
                code = key
            }
            exp.fulfill()
        })
        wait(for: [exp], timeout: 6)
        XCTAssertEqual(code, 200, "testGetActions not working as expected")
    }
    
    func testGetActionsPageView () {
        let exp = XCTestExpectation(description: "Testing testGetActions api ")
        var code = 400;
        Personalization.shared.getActions(context: .PageView, requestId: requestid, arrActionTypes: [.OmniChannelJson], event: PageView(pageType: "profile", path: "/profile", url: "http:/home", categories: nil, breadcrumbs: nil)).on(success: { (res) in
            
            print("response", res.status, res.data?.toString)
            if let key = res.status {
                code = key
            }
            exp.fulfill()
        })
        wait(for: [exp], timeout: 6)
        XCTAssertEqual(code, 200, "testGetActions not working as expected")
    }
    
    func testGetActionsPurchase () {
        let exp = XCTestExpectation(description: "Testing testGetActions api ")
        var code = 400;
        Personalization.shared.getActions(context: .Purchase, requestId: requestid, arrActionTypes: [.OmniChannelJson], event: Purchase(account: "Flipkart", domain: "www.flipkart.com", instance: "instance-111", purchaseId: "PID-111", purchaseLines: [PurchaseLine(sku: "sku-111", pid: "pid-111", quantity: 2, currency: "USD", value: "111")])).on(success: { (res) in
            
            print("response", res.status, res.data?.toString)
            if let key = res.status {
                code = key
            }
            exp.fulfill()
        })
        wait(for: [exp], timeout: 6)
        XCTAssertEqual(code, 200, "testGetActions not working as expected")
    }
    
    func testGetActionsCart () {
        let exp = XCTestExpectation(description: "Testing testGetActions api ")
        var code = 400;
        Personalization.shared.getActions(context: .Cart, requestId: requestid, arrActionTypes: [.OmniChannelJson], event: Cart(cartLines: [CartLine(sku: "sku-111", pid: "pid-111", quantity: 1, currency: "USD", value: "111")])).on(success: { (res) in
            
            print("response", res.status, res.data?.toString)
            if let key = res.status {
                code = key
            }
            exp.fulfill()
        })
        wait(for: [exp], timeout: 6)
        XCTAssertEqual(code, 200, "testGetActions not working as expected")
    }
    
    func testGetActionsUserAgent () {
        let exp = XCTestExpectation(description: "Testing testGetActions api ")
        var code = 400;
        Personalization.shared.getActions(context: .UserAgent, requestId: requestid, arrActionTypes: [.OmniChannelJson], event: UserAgent(userAgent: "Mozilla")).on(success: { (res) in
            
            print("response", res.status, res.data?.toString)
            if let key = res.status {
                code = key
            }
            exp.fulfill()
        })
        wait(for: [exp], timeout: 6)
        XCTAssertEqual(code, 200, "testGetActions not working as expected")
    }
    
    func testGetActionsIPAddress () {
        let exp = XCTestExpectation(description: "Testing testGetActions api ")
        var code = 400;
        Personalization.shared.getActions(context: .IpAddress, requestId: requestid, arrActionTypes: [.OmniChannelJson], event: IPAddress(ipAddress: "192.168.0.2")).on(success: { (res) in
            
            print("response", res.status, res.data?.toString)
            if let key = res.status {
                code = key
            }
            exp.fulfill()
        })
        wait(for: [exp], timeout: 6)
        XCTAssertEqual(code, 200, "testGetActions not working as expected")
    }
    
    
    func testGetActionsCoordinates () {
        let exp = XCTestExpectation(description: "Testing testGetActions api ")
        var code = 400;
        Personalization.shared.getActions(context: .Coordinates, requestId: requestid, arrActionTypes: [.OmniChannelJson], event: Coordinates(latitude: "92.687689", longitude: "12.78328913")).on(success: { (res) in
            
            print("response", res.status, res.data?.toString)
            if let key = res.status {
                code = key
            }
            exp.fulfill()
        })
        wait(for: [exp], timeout: 6)
        XCTAssertEqual(code, 200, "testGetActions not working as expected")
    }
    
    
    func testGetActionsScreenSize () {
        let exp = XCTestExpectation(description: "Testing testGetActions api ")
        var code = 400;
        Personalization.shared.getActions(context: .ScreenSize, requestId: requestid, arrActionTypes: [.OmniChannelJson], event: ScreenSize(height: 1800, width: 1024)).on(success: { (res) in
            
            print("response", res.status, res.data?.toString)
            if let key = res.status {
                code = key
            }
            exp.fulfill()
        })
        wait(for: [exp], timeout: 6)
        XCTAssertEqual(code, 200, "testGetActions not working as expected")
    }
    
    func testGetActionsMetadata () {
        let exp = XCTestExpectation(description: "Testing testGetActions api ")
        var code = 400;
        Personalization.shared.getActions(context: .Metadata, requestId: requestid, arrActionTypes: [.OmniChannelJson], event: Metadata(metadata: JSONValue.init(dictionaryLiteral: ("fname", "umar"), ("lname", "sayyed")))).on(success: { (res) in
            
            print("response", res.status, res.data?.toString)
            if let key = res.status {
                code = key
            }
            exp.fulfill()
        })
        wait(for: [exp], timeout: 6)
        XCTAssertEqual(code, 200, "testGetActions not working as expected")
    }
    
    func testGetActionsCustomVariables () {
        let exp = XCTestExpectation(description: "Testing testGetActions api ")
        var code = 400;
        Personalization.shared.getActions(context: .CustomVariables, requestId: requestid, arrActionTypes: [.OmniChannelJson], event: CustomVariables(customVariables: [CustomVariablesModel(variable: "Variable1", value: JSONValue(stringLiteral: "Value3"))])).on(success: { (res) in
            
            print("response", res.status, res.data?.toString)
            if let key = res.status {
                code = key
            }
            exp.fulfill()
        })
        wait(for: [exp], timeout: 6)
        XCTAssertEqual(code, 200, "testGetActions not working as expected")
    }

    private func setupPersonalizationSDK () {
        Personalization.setup(
           account: Account(instance: "p", domain: "localhost.org", name: "a-701b337c", shortname: "localhost"),
           user: User(monetateId: "auto")
        )
    }
}
