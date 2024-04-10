//
//  RecClicks.swift
//  monetate-ios-sdk
//
//  Created by Rajan Marathe on 04/07/22.
//  Copyright © 2022 Monetate. All rights reserved.
//

import Foundation

/** Used to record rec clicks. A click is recorded for each token sent. */

public struct RecClicks: Codable, MEvent {
    
    /** A value which identifies the type of event. */
    public let eventType: String
    
    /** An Array of rec tokens to be recorded.*/
    public var recClicks: [String]
    
    public init(recClicks: [String]) {
        eventType = "monetate:record:RecClicks"
        self.recClicks = recClicks
        try! checkRecClicks()
    }
    
    func checkRecClicks () throws {
        if (!recClicks.isEmpty) {
            for strRecClicks in recClicks {
                if (strRecClicks == "") {throw RecClicksError.recClicks(description: "Array contains Invalid RecClick")}
            }
        }
    }
}

enum RecClicksError : Error {
    case recClicks(description: String)
}
