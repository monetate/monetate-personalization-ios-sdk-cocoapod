//
//  DecisionRequest.swift
//  monetate-ios-sdk
//
//  Created by Umar Sayyed on 30/12/20.
//  Copyright © 2020 Monetate. All rights reserved.
//

import Foundation

public enum ActionTypeEnum: String, Codable {
    case OmniChannelJson = "monetate:action:OmnichannelJson"
    case OmniChannelRecommendation = "monetate:action:OmnichannelRecommendation"
    case OmniSocialProofData = "monetate:action:SocialProofDataV2"
    case OmniImageBadging = "monetate:action:OmniChannelImageBadging"
    case OmniDataCollection = "monetate:action:DataCollection"
}

public class DecisionRequest: MEvent, Codable {
    let requestId:String
    var includeReporting : Bool
    public let eventType: String
    var actionTypes:[ActionTypeEnum]?
    
    init (requestId:String, includeReporting:Bool, actionTypes:[ActionTypeEnum]) {
        self.requestId = requestId
        self.includeReporting = includeReporting
        self.eventType = "monetate:decision:DecisionRequest"
        self.actionTypes = actionTypes
    }
}
