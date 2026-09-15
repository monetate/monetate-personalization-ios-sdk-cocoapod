//
//  RequestTrace.swift
//  monetate-ios-sdk
//
//  Created by Hasanul Benna(UST,IN) on 31/08/26.
//  Copyright © 2026 Monetate. All rights reserved.
//

import Foundation

public enum Environment: String {
    case production
    case staging
    case development
}
public enum TraceStatus: String {
    case created
    case inProgress
    case completed
    case failed
}
public enum RequestType: String {
    case recommendation = "Recommendation Request"
    case search = "Search Request"
    case event = "Event Request"
    case contextUpdate = "Context Update Request"
    case configuration = "Configuration Request"
}



 struct RequestTrace {
    let requestId: String
    let traceId: String
    var status: TraceStatus
    let createdAt: Date
    let endpoint: String
    let method: Method
    let environment: Environment
    let requestType: RequestType
    
    // Reserved for future observability
    private var request: Any?
    private var response: Any?
    private var timing: Any?
    private var lifecycle: Any?
    private var error: Any?

    init(
        requestId: String,
        traceId: String,
        status: TraceStatus,
        createdAt: Date,
        endpoint: String,
        method: Method,
        environment: Environment,
        requestType: RequestType
    ) {
        self.requestId = requestId
        self.traceId = traceId
        self.status = status
        self.createdAt = createdAt
        self.endpoint = endpoint
        self.method = method
        self.environment = environment
        self.requestType = requestType
    }
}
