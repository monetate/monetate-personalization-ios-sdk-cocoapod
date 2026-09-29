//
//  TraceRequest.swift
//  monetate-ios-sdk
//
//  Created by Hasanul Benna(UST,IN) on 21/09/26.
//  Copyright © 2026 Monetate. All rights reserved.
//

struct TraceRequest: Codable {
    var method: String?
    var url: String?
    var headers: [String: String]?
    var body: JSONValue?
}


