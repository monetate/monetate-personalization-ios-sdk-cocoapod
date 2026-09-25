//
//  TraceResponse.swift
//  monetate-ios-sdk
//
//  Created by Hasanul Benna(UST,IN) on 21/09/26.
//  Copyright © 2026 Monetate. All rights reserved.
//

struct TraceResponse: Codable {
    var statusCode: Int
    var headers: [String: String]?
    var body: JSONValue?
}
