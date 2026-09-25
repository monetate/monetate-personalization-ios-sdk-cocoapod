//
//  TraceRegistry.swift
//  monetate-ios-sdk
//
//  Created by Hasanul Benna(UST,IN) on 21/09/26.
//  Copyright © 2026 Monetate. All rights reserved.
//
import Foundation

final class TraceRegistry {

    private var activeTraces: [String: RequestTrace]?
    private let lock = NSLock()


    init(activeTraces: [String: RequestTrace]) {
        self.activeTraces = activeTraces
    }

    func getActiveTraces() -> [String: RequestTrace]? {
        lock.lock()
        defer { lock.unlock() }
        return activeTraces
    }

    func setActiveTraces(_ activeTraces: [String: RequestTrace]) {
        lock.lock()
        defer { lock.unlock() }
        self.activeTraces = activeTraces
    }
}
