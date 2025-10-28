//
//  SearchData.swift
//  monetate-ios-sdk
//
//  Created by Hasanul Benna(UST,IN) on 30/06/25.
//  Copyright © 2025 Monetate. All rights reserved.
//

import Foundation

/// Search prerequisite data
struct SearchPreRequisite: Equatable {
    var channelData: String
    var searchToken: String?
    var actionId: String?
    
    public init(channelData: String, searchToken: String? = nil, actionId: String? = nil) {
        self.channelData = channelData
        self.searchToken = searchToken
        self.actionId = actionId
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
        let id: RequestIdEnum?
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
        let suggestionID: RequestIdEnum?
        let typeOfQuery: TypeOfRequest?
        let query: String?

        enum CodingKeys: String, CodingKey {
            case suggestionID = "id"
            case typeOfQuery
            case query
        }
    }
}

/// Report search token click
struct TokenClickRequest: Codable {
    let searchClickToken: String
}

/// Search error handler
enum SearchError: LocalizedError {
    case invalidInput
    case noActionsFound
    case noSearchActionFound(domain: String)
    case missingSearchToken
    case missingActionId
    case configurationFailed
    case fetchFailed
    case invalidClickToken

    var errorDescription: String? {
        switch self {
        case .invalidInput:
            return "Search input was empty or invalid limit. Please provide a valid search query."
        case .noActionsFound:
            return "Execution Alert: No actions found in response data during search."
        case .noSearchActionFound(let domain):
            return "Execution Alert: No active search actions of type \"\(ActionTypeEnum.searchAction.rawValue)\" found for domain \"\(domain)\"."
        case .missingSearchToken:
            return "Execution Alert: Missing required searchToken parameter in action."
        case .missingActionId:
            return "Execution Alert: Missing required actionId parameter."
        case .configurationFailed:
            return "Configuration or network issue encountered. Ensure SDK is properly configured."
        case .fetchFailed:
            return "Failed to fetch search results: input invalid or no data returned."
        case .invalidClickToken:
            return "Input token was empty or invalid, Please provide a valid token"
        }
    }
}
