//
//  Product.swift
//  monetate-ios-sdk-example
//
//  Created by Umar Sayyed on 30/09/20.
//  Copyright © 2020 Monetate. All rights reserved.
//

import Foundation


/** Represents an item.  */

public struct ProductView: Codable {
    
    /** A value which identifies the type of event. */
    public let eventType: String
    /** The list of products viewed on a product detail page. */
    public var products: [String]?
    
    public init(products: [String]?) {
        eventType = "monetate:context:ProductView"
        self.products = products
    }
}


