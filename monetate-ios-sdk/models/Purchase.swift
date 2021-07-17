//
//  File.swift
//  monetate-ios-sdk-example
//
//  Created by Umar Sayyed on 30/09/20.
//  Copyright © 2020 Monetate. All rights reserved.
//

import Foundation

/** Used to communicate a purchase. Must include line items.  */

public class Purchase: Codable, MEvent {
    
    /** A value which identifies the type of event. */
    public let eventType: String
    /** The account id */
    public var account: String
    /** The account domain (i.e. fifthlevelfashion.com) */
    public var domain: String
    /** The type of instance (i.e. p for production) */
    public var instance: String
    /** Unique identifier for the purchase. */
    public var purchaseId: String
    /** The purchase lines defining the contents of the purchase. */
    public var purchaseLines: [PurchaseLine]?
    
    public init(account: String, domain: String, instance: String, purchaseId: String, purchaseLines: [PurchaseLine]?) {
        eventType = "monetate:context:Purchase"
        self.account = account
        self.domain = domain
        self.instance = instance
        self.purchaseId = purchaseId
        self.purchaseLines = purchaseLines
    }
    
    static func merge (first: [PurchaseLine], second: [PurchaseLine]) -> [PurchaseLine] {
        let merged = Array(Dictionary([first, second].joined().map { ($0.pid, $0)}, uniquingKeysWith: { $1 }).values)
        return merged
    }
    
}



/** Represents an item in a purchase.  */

public struct PurchaseLine: Codable {
    
    /** The unique identifier for the product. */
    public var sku: String
    /** The parent identifier for a related set of skus. */
    public var pid: String
    /** The number of items purchased. */
    public var quantity: Int
    /** The currency of the purchase value. */
    public var currency: String
    /** The total value of the items. */
    public var value: String
    
    public init(sku: String, pid: String, quantity: Int, currency: String, value: String) {
        self.sku = sku
        self.pid = pid
        self.quantity = quantity
        self.currency = currency
        self.value = value
    }
    
    
}
