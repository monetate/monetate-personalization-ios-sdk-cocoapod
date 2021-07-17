//
//  EnccapClicks.swift
//  monetate-ios-sdk
//
//  Created by Umar Sayyed on 12/10/20.
//  Copyright © 2020 Monetate. All rights reserved.
//

import Foundation

/** Used to record endcap clicks. A click is recorded for each product sent. */

public struct EndcapClicks: Codable, MEvent {
    
    /** A value which identifies the type of event. */
    public let eventType: String
    /** Array of endcap product clicks to be recorded. */
    public var endcapClicks: [EndcapEvent]
    
    public init(endcapClicks: [EndcapEvent]) {
        eventType = "monetate:record:EndcapClicks"
        self.endcapClicks = endcapClicks
    }

}



public struct EndcapEvent: Codable {
    
    /** The action id associated with the endcap event. */
    public var actionId: String
    /** The list of products and product specific details. */
    public var products: [Product]
    
    public init(actionId: String, products: [Product]) {
        self.actionId = actionId
        self.products = products
    }
    
    
}
