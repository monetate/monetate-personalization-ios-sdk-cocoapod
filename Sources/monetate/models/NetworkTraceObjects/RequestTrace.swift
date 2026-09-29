//
//  RequestTrace.swift
//  monetate-ios-sdk
//
//  Created by Hasanul Benna(UST,IN) on 21/09/26.
//  Copyright © 2026 Monetate. All rights reserved.
//

import Foundation

struct RequestTrace: Codable {
    var requestId: String
    var traceId: String
    var status: TraceStatus
    var createdAt: Date

    var request: TraceRequest? = nil
    var response: TraceResponse? = nil
    var timing: TraceTiming? = nil
    var lifecycle: TraceLifecycle? = nil
    var error: TraceError? = nil
}
