
//
//  File.swift
//  monetate-ios-sdk-example
//
//  Created by Umar Sayyed on 30/09/20.
//  Copyright © 2020 Monetate. All rights reserved.
//

import Foundation

/** Represents an item in a cart.  */
public class Cart: Codable, MEvent {
    
    public let eventType: String
    
    public var cartLines: [CartLine]?
    
    public init(cartLines: [CartLine]?) {
        eventType = "monetate:context:Cart"
        self.cartLines = cartLines
    }
    
    static func merge (first: [CartLine], second: [CartLine]) -> [CartLine] {
        let merged = Array(Dictionary([first, second].joined().map { ($0.pid, $0)}, uniquingKeysWith: { $1 }).values)
        return merged
    }
    
}

public struct CartLine: Codable {
    
    
    /** The unique identifier for the product. */
    public var sku: String
    /** The parent identifier for a related set of skus. */
    public var pid: String
    /** The number of products matching this SKU that are in the cart. */
    public var quantity: Int
    /** The currency of the item value. */
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
    
    func serialize () -> NSDictionary {
        var dic:[String:Any] = [:]
        let mirrored_object = Mirror(reflecting: self)
        for (_, attr) in mirrored_object.children.enumerated() {
            if let key = attr.label {
                dic.updateValue(attr.value, forKey: key)
            }
        }
        return dic as NSDictionary
    }
    
}

extension Dictionary {
    mutating func merge(dict: [Key: Value]){
        for (k, v) in dict {
            updateValue(v, forKey: k)
        }
    }
    mutating func merge1(dict: [Key: Value]?){
        guard let dict = dict else {return}
        for (k, v) in dict {
            updateValue(v, forKey: k)
        }
    }
}

