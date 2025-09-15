//
//  SearchData.swift
//  monetate-ios-sdk
//
//  Created by Hasanul Benna(UST,IN) on 30/06/25.
//  Copyright © 2025 Monetate. All rights reserved.
//

import Foundation

/// Search prerequisite data
public struct SearchPreRequisite {
    public var searchToken: String?
    public var channelData: String

    public init(searchToken: String?, channelData: String) {
        self.searchToken = searchToken
        self.channelData = channelData
    }
}

/// Search API request model
struct SearchRequest: Codable {
    let recordQueries: [RecordQuery]?
    let suggestions: [Suggestion]?
    let searchToken: String?
    
    private enum CodingKeys: String, CodingKey {
        case recordQueries
        case suggestions
        case searchToken
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        // Default encoding for recordQueries and suggestions
        try container.encodeIfPresent(recordQueries, forKey: .recordQueries)
        try container.encodeIfPresent(suggestions, forKey: .suggestions)
        
        // Explicitly encode searchToken even if nil
        if let token = searchToken {
            try container.encode(token, forKey: .searchToken)
        } else {
            try container.encodeNil(forKey: .searchToken)
        }
    }
    
    struct RecordQuery: Codable {
        let id: ActionIdEnum?
        let typeOfRequest: TypeOfRequest?
        let settings: RecordSettings?
        
        private enum CodingKeys: String, CodingKey {
            case id
            case typeOfRequest
            case settings
        }
    }
    
    struct RecordSettings: Codable {
        let query: QueryTerm?
        let limit: Int?
    }
    
    struct QueryTerm: Codable {
        let term: String?
    }
    
    struct Suggestion: Codable {
        let suggestionID: ActionIdEnum?
        let typeOfQuery: TypeOfRequest?
        let query: String?

        enum CodingKeys: String, CodingKey {
            case suggestionID = "id"
            case typeOfQuery
            case query
        }
    }
}

/// Search error handler
enum SearchError: LocalizedError {
    case invalidInput
    case noActionsFound
    case noSearchActionFound(domain: String)
    case missingActionProperties
    case configurationFailed
    case fetchFailed

    var errorDescription: String? {
        switch self {
        case .invalidInput:
            return "Search input was empty or invalid limit. Please provide a valid search query."
        case .noActionsFound:
            return "Execution Alert: No actions found in response data during search."
        case .noSearchActionFound(let domain):
            return "Execution Alert: No active search actions of type \"\(ActionTypeEnum.searchAction.rawValue)\" found for domain \"\(domain)\"."
        case .missingActionProperties:
            return "Execution Alert: Missing required searchToken parameter in action."
        case .configurationFailed:
            return "Configuration or network issue encountered. Ensure SDK is properly configured."
        case .fetchFailed:
            return "Failed to fetch search results: input invalid or no data returned."
        }
    }
}
