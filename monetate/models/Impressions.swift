//
//  Impressions.swift
//  monetate-ios-sdk
//
//  Created by Umar Sayyed on 12/10/20.
//  Copyright © 2020 Monetate. All rights reserved.
//

import Foundation

/** Used to record impressions.  Each impressionId is a token that is associated with an action from an earlier request. */

public struct Impressions: Codable, MEvent {
    
    /** A value which identifies the type of event. */
    public let eventType: String 
    /** A list of impression identifier strings. */
    public var impressionIds: [String]
    
    public init(impressionIds: [String]) {
        eventType = "monetate:record:Impressions"
        self.impressionIds = impressionIds
    }
    
    
}
