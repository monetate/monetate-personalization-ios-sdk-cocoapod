//
//  EndcapImpressions.swift
//  monetate-ios-sdk
//
//  Created by Umar Sayyed on 12/10/20.
//  Copyright © 2020 Monetate. All rights reserved.
//

import Foundation

/** Used to record endcap impressions. A click is recorded for each product sent. */

public struct EndcapImpressions: Codable, MEvent {
    
    /** A value which identifies the type of event. */
    public let eventType: String
    /** Array of endcap product clicks to be recorded. */
    public var endcapImpressions: [EndcapEvent]
    
    public init(endcapImpressions: [EndcapEvent]) {
        eventType = "monetate:record:EndcapImpressions"
        self.endcapImpressions = endcapImpressions
    }
}

