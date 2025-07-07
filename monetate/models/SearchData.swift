//
//  SearchData.swift
//  monetate-ios-sdk
//
//  Created by Hasanul Benna(UST,IN) on 30/06/25.
//  Copyright © 2025 Monetate. All rights reserved.
//

import Foundation

public struct SearchPreRequisite {
    public var searchToken: String
    public var channelData: String

    public init(searchToken: String, channelData: String) {
        self.searchToken = searchToken
        self.channelData = channelData
    }
}
enum SearchError: LocalizedError {
    case invalidInput
    case noActionsFound
    case noSearchActionFound(domain: String)
    case missingActionProperties
    case prerequisiteFetchFailed
    case fetchFailed

    var errorDescription: String? {
        switch self {
        case .invalidInput:
            return "Search input was empty or invalid limit. Please provide a valid search query."
        case .noActionsFound:
            return "Execution Interrupted: No actions found in response data during search."
        case .noSearchActionFound(let domain):
            return "Execution Interrupted: No active search actions of type \"\(ContextEnum.search.rawValue)\" found for domain \"\(domain)\"."
        case .missingActionProperties:
            return "Execution Interrupted: Missing required searchToken parameter."
        case .prerequisiteFetchFailed:
            return "Search prerequisite fetch failed: configuration or network issue encountered. Ensure SDK is properly configured."
        case .fetchFailed:
            return "Failed to fetch search results: input invalid or no data returned."
        }
    }
}
