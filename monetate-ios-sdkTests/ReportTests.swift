//
//  ReportTests.swift
//  monetate-ios-sdkTests
//
//  Created by Umar Sayyed on 23/11/20.
//  Copyright © 2020 Monetate. All rights reserved.
//

import XCTest
@testable import Monetate

class PersonalizationTests: XCTestCase {
    
    override func setUp() {
        setupPersonalizationSDK()
        super.setUp()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    
    func testReportCustomVariableEvent () {
        let var1 = CustomVariables(customVariables: [CustomVariablesModel(variable: "Variable1", value: JSONValue(stringLiteral: "Value1")), CustomVariablesModel(variable: "Variable2", value: JSONValue(stringLiteral: "Value2"))])
        let var2 = CustomVariables(customVariables: [CustomVariablesModel(variable: "Variable1", value: JSONValue(stringLiteral: "Value3"))])
        
        let output1 = Personalization.shared.isContextSwitched(ctx: .CustomVariables, event: var1)
        Personalization.shared.report(context: .CustomVariables, event: var1)
        let output2 = Personalization.shared.isContextSwitched(ctx: .CustomVariables, event: var2)
        
        XCTAssertEqual(output1, false, "CustomVariables context is not switched")
        XCTAssertEqual(output2, true, "CustomVariables context is switched")
    }
    
    func testReportMetadataEvent () {
        let var1 = Metadata(metadata: JSONValue.init(dictionaryLiteral: ("fname", "umar"), ("lname", "sayyed")))
        let var2 = Metadata(metadata: JSONValue.init(dictionaryLiteral: ("fname", "val")))
        
        let output1 = Personalization.shared.isContextSwitched(ctx: .Metadata, event: var1)
        Personalization.shared.report(context: .Metadata, event: var1)
        let output2 = Personalization.shared.isContextSwitched(ctx: .Metadata, event: var2)
        
        XCTAssertEqual(output1, false, "Metadata context is not switched")
        XCTAssertEqual(output2, true, "Metadata context is switched")
    }
    
    func testReportUserAgentEvent () {
        let var1 = UserAgent(userAgent: "Mozilla")
        let var2 = UserAgent(userAgent: "Safari")
        
        let output1 = Personalization.shared.isContextSwitched(ctx: .UserAgent, event: var1)
        Personalization.shared.report(context: .UserAgent, event: var1)
        let output2 = Personalization.shared.isContextSwitched(ctx: .UserAgent, event: var2)
        
        XCTAssertEqual(output1, false, "UserAgent context is not switched")
        XCTAssertEqual(output2, true, "UserAgent context is switched")
    }
    
    func testReportIpadressEvent () {
        let var1 = IPAddress(ipAddress: "192.168.0.1")
        let var2 = IPAddress(ipAddress: "192.168.0.2")
        
        let output1 = Personalization.shared.isContextSwitched(ctx: .IpAddress, event: var1)
        Personalization.shared.report(context: .IpAddress, event: var1)
        let output2 = Personalization.shared.isContextSwitched(ctx: .IpAddress, event: var2)
        
        XCTAssertEqual(output1, false, "IpAddress context is not switched")
        XCTAssertEqual(output2, true, "IpAddress context is switched")
    }
    
    func testReportScreensizeEvent () {
        
        let var1 = ScreenSize(height: 1800, width: 1024)
        let var2 = ScreenSize(height: 2500, width: 1400)
        
        let output1 = Personalization.shared.isContextSwitched(ctx: .ScreenSize, event: var1)
        Personalization.shared.report(context: .ScreenSize, event: var1)
        let output2 = Personalization.shared.isContextSwitched(ctx: .ScreenSize, event: var2)
        
        XCTAssertEqual(output1, false, "ScreenSize context is not switched")
        XCTAssertEqual(output2, true, "ScreenSize context is switched")
    }
    
    func testReportCoordinatesEvent () {
        
        let var1 = Coordinates(latitude: "92.687689", longitude: "12.78328913")
        let var2 = Coordinates(latitude: "92.687689", longitude: "13.78328913")
        
        let output1 = Personalization.shared.isContextSwitched(ctx: .Coordinates, event: var1)
        Personalization.shared.report(context: .Coordinates, event: var1)
        let output2 = Personalization.shared.isContextSwitched(ctx: .Coordinates, event: var2)
        
        XCTAssertEqual(output1, false, "Coordinates context is not switched")
        XCTAssertEqual(output2, true, "Coordinates context is switched")
    }
    
    func testReportCartEvent () {
        let var1 = Cart(cartLines: [CartLine(sku: "sku-111", pid: "pid-111", quantity: 1, currency: "USD", value: "111")])
        let var2 = Cart(cartLines: [CartLine(sku: "sku-222", pid: "pid-222", quantity: 2, currency: "USD", value: "222")])
        
        let output1 = Personalization.shared.isContextSwitched(ctx: .Cart, event: var1)
        let output2 = Personalization.shared.isContextSwitched(ctx: .Cart, event: var2)
        
        XCTAssertEqual(output1, false, "Cart context is not switched")
        XCTAssertEqual(output2, false, "Cart context is switched")
    }
    
    func testReportPurchaseEvent () {
        let var1 = Purchase(account: "Flipkart", domain: "www.flipkart.com", instance: "instance-111", purchaseId: "PID-111", purchaseLines: [PurchaseLine(sku: "sku-111", pid: "pid-111", quantity: 2, currency: "USD", value: "111")])
        
        let var2 = Purchase(account: "Flipkart", domain: "www.flipkart.com", instance: "instance-222", purchaseId: "PID-222", purchaseLines: [PurchaseLine(sku: "sku-222", pid: "pid-222", quantity: 2, currency: "USD", value: "222")])
        
        let output1 = Personalization.shared.isContextSwitched(ctx: .Purchase, event: var1)
        let output2 = Personalization.shared.isContextSwitched(ctx: .Purchase, event: var2)
        
        XCTAssertEqual(output1, false, "Purchase context is not switched")
        XCTAssertEqual(output2, false, "Purchase context is not switched")
    }
    
    func testReportProductDetailsViewEvent () {
        let var1 = ProductDetailView(products: [Product(productId: "prod-111", sku: "sku-111")])
        let var2 = ProductDetailView(products: [Product(productId: "prod-222", sku: "sku-222")])
        
        let output1 = Personalization.shared.isContextSwitched(ctx: .ProductDetailView, event: var1)
        let output2 = Personalization.shared.isContextSwitched(ctx: .ProductDetailView, event: var2)
        
        XCTAssertEqual(output1, false, "ProductDetailView context is not switched")
        XCTAssertEqual(output2, false, "ProductDetailView context is not switched")
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
