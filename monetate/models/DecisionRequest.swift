//
//  DecisionRequest.swift
//  monetate-ios-sdk
//
//  Created by Umar Sayyed on 30/12/20.
//  Copyright © 2020 Monetate. All rights reserved.
//

import Foundation

public class DecisionRequest: MEvent, Codable {
    let requestId:String
    public let eventType: String
    init (requestId:String) {
        self.requestId = requestId
        self.eventType = "monetate:decision:DecisionRequest"
    }
}
