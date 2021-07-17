//
//  Coordinates.swift

//  monetate-ios-sdk-example
//
//  Created by Umar Sayyed on 30/09/20.
//  Copyright © 2020 Monetate. All rights reserved.
//

import Foundation

/** This is the latitude and longitude provide by the device.  */
public class Coordinates : Context, Codable {
    
    public func isContextSwitched(ctx: Context) -> Bool {
        if let val = ctx as? Coordinates, val.latitude != self.latitude || val.longitude != self.longitude {
            return true
        }
        return false
    }
    /** A value which identifies the type of event. */
    public let eventType: String
    /** Device latitude */
    public var latitude: String = ""
    /** Device longitude */
    public var longitude: String = ""
    
    public init(latitude: String, longitude: String) {
        self.latitude = latitude
        self.longitude = longitude
        self.isAuto = false
        self.eventType = "monetate:context:Coordinates"
    }
    
    public let isAuto: Bool
    
    public init(auto: Bool) {
        //TODO: handle auto initialization logic when location access in enabled
        self.isAuto = auto
        self.eventType = "monetate:context:Coordinates"
    }
    
}
