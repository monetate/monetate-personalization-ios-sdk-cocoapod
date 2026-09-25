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

    var request: TraceRequest?
    var response: TraceResponse?
    var timing: TraceTiming?
    var lifecycle: TraceLifecycle?
    var error: TraceError?
}
