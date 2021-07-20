//
//  File.swift
//  monetate-ios-sdk-example
//
//  Created by Umar Sayyed on 30/09/20.
//  Copyright © 2020 Monetate. All rights reserved.
//

import Foundation

/** This visitor&#39;s screen size, height and width in pixels.  */
public class ScreenSize : Context,Codable {
    
    public func isContextSwitched(ctx: Context) -> Bool {
        if let val = ctx as? ScreenSize, (val.width != self.width || val.height != self.height) {
            return true
        }
        return false
    }
    
    /** A value which identifies the type of event. */
    public let eventType: String
    /** screen height in pixels */
    public var height: Int
    /** screen width in pixels */
    public var width: Int
    
    public init(height: Int, width: Int) {
        eventType = "monetate:context:ScreenSize"
        self.height = height
        self.width = width
    }
    
    public init(auto: Bool) {
        eventType = "monetate:context:ScreenSize"
        if auto {
            let (width, height) = Device.getDeviceSize()
            self.width = Int(truncating: width)
            self.height = Int(truncating: height)
        } else {
            self.width = 0
            self.height = 0
        }
    }
}
