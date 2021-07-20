//
//  ClosedSession.swift
//  monetate-ios-sdk
//
//  Created by Umar Sayyed on 12/10/20.
//  Copyright © 2020 Monetate. All rights reserved.
//

import Foundation

/** This is the ClosedSession event from the session stream.  */

public struct ClosedSession: Codable, MEvent {
    
    /** A value which identifies the type of event. */
    public let eventType: String
    /** A closed session object as retrieved from the closed session stream. */
    public var closedSession: JSONValue?
    /** The version of the closed session object. */
    public var version: String?
    
    public init(closedSession: JSONValue, version: String) {
        eventType = "monetate:context:ClosedSession"
        self.closedSession = closedSession
        self.version = version
    }
}
