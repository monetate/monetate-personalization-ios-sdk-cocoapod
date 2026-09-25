//
//  TraceManager.swift
//  monetate-ios-sdk
//
//  Created by Hasanul Benna(UST,IN) on 21/09/26.
//  Copyright © 2026 Monetate. All rights reserved.
//

import Foundation

final class TraceManager {

    private var traceRegistry: TraceRegistry?
    private let lock = NSLock()
    
    init() {
        
    }
    
    init(traceRegistry: TraceRegistry) {
        self.traceRegistry = traceRegistry
    }

    func getTraceRegistry() -> TraceRegistry? {
        lock.lock()
        defer { lock.unlock() }
        return traceRegistry
    }

    func setTraceRegistry(_ traceRegistry: TraceRegistry) {
        lock.lock()
        defer { lock.unlock() }
        self.traceRegistry = traceRegistry
    }
    
    func generateTraceId() -> String {
        return "trace_" + UUID().uuidString
    }

    func generateRequestId() -> String {
        return "req_" + UUID().uuidString
    }
    
    func createRequestTrace() -> RequestTrace {
        let requestId = generateRequestId()
        let traceId = generateTraceId()
        let status = TraceStatus.created
        let createdAt = Date()

        return RequestTrace(
            requestId: requestId,
            traceId: traceId,
            status: status,
            createdAt: createdAt
        )
    }
    
    func createJsonFromObject(_ trace: RequestTrace) -> String? {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .withoutEscapingSlashes]

        guard let data = try? encoder.encode(trace) else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }

}
