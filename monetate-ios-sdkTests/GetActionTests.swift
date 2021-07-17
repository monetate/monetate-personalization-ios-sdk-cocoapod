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
        Personalization.shared.getActions(context: .ProductDetailView, event: ProductDetailView(products: [Product(productId: "PROD-278", sku: "DENIM Jeans")])).on(success: { (res) in
            
            print("response", res.status, res.data?.toString)
            if let key = res.status {
                code = key
            }
            exp.fulfill()
        })
        wait(for: [exp], timeout: 6)
        XCTAssertEqual(code, 200, "testGetActions not working as expected")
    }
    
    func testGetActionsPageEvent () {
        let exp = XCTestExpectation(description: "Testing testGetActions api ")
        var code = 400;
        Personalization.shared.getActions(context: .PageEvents, event: PageEvents(pageEvents: ["Page 1", "Page 2", "Page 3"])).on(success: { (res) in
            
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
        Personalization.shared.getActions(context: .PageView, event: PageView(pageType: "profile", path: "/profile", url: "http:/home", categories: nil, breadcrumbs: nil)).on(success: { (res) in
            
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
        Personalization.shared.getActions(context: .Purchase, event: Purchase(account: "Flipkart", domain: "www.flipkart.com", instance: "instance-111", purchaseId: "PID-111", purchaseLines: [PurchaseLine(sku: "sku-111", pid: "pid-111", quantity: 2, currency: "USD", value: "111")])).on(success: { (res) in
            
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
        Personalization.shared.getActions(context: .Cart, event: Cart(cartLines: [CartLine(sku: "sku-111", pid: "pid-111", quantity: 1, currency: "USD", value: "111")])).on(success: { (res) in
            
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
        Personalization.shared.getActions(context: .UserAgent, event: UserAgent(userAgent: "Mozilla")).on(success: { (res) in
            
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
        Personalization.shared.getActions(context: .IpAddress, event: IPAddress(ipAddress: "192.168.0.2")).on(success: { (res) in
            
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
        Personalization.shared.getActions(context: .Coordinates, event: Coordinates(latitude: "92.687689", longitude: "12.78328913")).on(success: { (res) in
            
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
        Personalization.shared.getActions(context: .ScreenSize, event: ScreenSize(height: 1800, width: 1024)).on(success: { (res) in
            
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
        Personalization.shared.getActions(context: .Metadata, event: Metadata(metadata: JSONValue.init(dictionaryLiteral: ("fname", "umar"), ("lname", "sayyed")))).on(success: { (res) in
            
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
        Personalization.shared.getActions(context: .CustomVariables, event: CustomVariables(customVariables: [CustomVariablesModel(variable: "Variable1", value: JSONValue(stringLiteral: "Value3"))])).on(success: { (res) in
            
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
            account: Account(instance: "instanceID", domain: "com.test.domain", name: "FlipKart", shortname: "flip"),
            user: User(kiboId: "com.test.id.app"),
            contextMap: setupContextMap()
        )
    }
    
    private func setupContextMap () -> ContextMap {
        return ContextMap(
            userAgent: UserAgent("Mozilla Firefox"),
            ipAddress: IPAddress(ipAddress: "192.168.0.1"),
            coordinates: Coordinates.init(auto: true),
            screenSize: ScreenSize(auto: true),
            
            cart: {() in
                let promise = Promise<Cart, Error>()
                promise.succeed(value: Cart(cartLines: [CartLine(sku: "SKU-111", pid: "PID-111", quantity: 2, currency: "USD", value: "460"), CartLine(sku: "SKU-222", pid: "PID-222", quantity: 4, currency: "USD", value: "560")]))
                
                return promise.future
            },
            purchase: {
                let promise = Promise<Purchase, Error>()
                let p = Purchase(account: "account-232", domain: "tem.dom.main", instance: "temp", purchaseId: "pur-23232", purchaseLines: [
                    PurchaseLine(sku: "SKU-123", pid: "Prod-1232", quantity: 2, currency: "USD", value: "2.99")
                ])
                promise.succeed(value: p)
                
                return promise.future
            },
            productDetailView: { () in
                let promise = Promise<ProductDetailView, Error>()
                let result = ProductDetailView.init(products: [
                    Product.init(productId: "PROD-9898", sku: "SKU-9898"),
                    Product.init(productId: "PROD-8989", sku: "SKU-8989")
                ])
                promise.succeed(value: result)
                return promise.future
            },
            productThumbnailView: {
                let promise = Promise<ProductThumbnailView, Error>()
                let result =     ProductThumbnailView.init(products: [""])
                promise.succeed(value: result)
                return promise.future
            },
            pageView: { () in
                let promise = Promise<PageView, Error>()
                let r = PageView(pageType: "profile", path: "/profile", url: "http:/home", categories: nil, breadcrumbs: nil)
                promise.succeed(value: r)
                return promise.future
            },
            metadata: { () in
                let promise = Promise<Metadata, Error>()
                let r = Metadata(metadata: JSONValue(dictionaryLiteral: ("Key1", "Val1"), ("Key2", "Val2")))
                promise.succeed(value: r)
                return promise.future
            },
            customVariables: { () in
                let promise = Promise<CustomVariables, Error>()
                let r = CustomVariables(customVariables: [
                    CustomVariablesModel(variable: "TempVariable", value: JSONValue.init(dictionaryLiteral: ("String", "JSONValue"))),
                    CustomVariablesModel(variable: "KEY", value: JSONValue.init(dictionaryLiteral: ("String", "JSONValue")))
                ])
                promise.succeed(value: r)
                return promise.future
            })
        
    }
}
