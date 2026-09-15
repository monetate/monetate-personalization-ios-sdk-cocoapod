//
//  RequestTraceRegistry.swift
//  monetate-ios-sdk
//
//  Created by Hasanul Benna(UST,IN) on 31/08/26.
//  Copyright © 2026 Monetate. All rights reserved.
//

import Foundation

 final class RequestTraceRegistry {

    private var traces: [String: RequestTrace] = [:]
    private let lock = NSLock()

    @discardableResult
    func createTrace( requestId: String,
                      status: TraceStatus = .created,
                      createdAt: Date = Date(),
                      endpoint: String,
                      method: Method = .POST,
                      environment: Environment = .production,
                      requestType: RequestType = .recommendation) -> RequestTrace {
        let trace = RequestTrace(
            requestId: requestId,
            traceId: "trace_\(requestId)",
            status: status,
            createdAt: createdAt,
            endpoint: endpoint,
            method: method,
            environment: environment,
            requestType: requestType
        )

        lock.lock()
        defer { lock.unlock() }
        traces[requestId] = trace

        return trace
    }

    func getTrace(requestId: String) -> RequestTrace? {
        lock.lock()
        defer { lock.unlock() }

        return traces[requestId]
    }

    func updateTrace(_ trace: RequestTrace) {
        lock.lock()
        defer { lock.unlock() }

        guard traces[trace.requestId] != nil else {
            return
        }

        traces[trace.requestId] = trace
    }

    func removeTrace(requestId: String) {
        lock.lock()
        defer { lock.unlock() }

        traces.removeValue(forKey: requestId)
    }
}
