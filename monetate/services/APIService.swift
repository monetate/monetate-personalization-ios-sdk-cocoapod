//
//  APIService.swift
//  monetate-ios-sdk
//
//  Created by Umar Sayyed on 13/10/20.
//  Copyright © 2020 Monetate. All rights reserved.
//

import Foundation

enum TypeOfRequest: String, Codable {
    case search = "SEARCH"
}

enum Method:String {
    case GET
    case POST
    case PUT
    case DELETE
}

class Service {
    static func getDecision(
        url: String,
        body: [String: Any]?,
        headers: [String: String]?,
        success: @escaping (Data, Int, URLResponse) -> Void,
        failure: @escaping (Error?, Data?, Int?, URLResponse?) -> Void
    ) {
        guard let url = URL(string: url) else {
            failure(nil, nil, nil, nil) // Invalid URL error can be customized
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = Method.POST.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let headers = headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
            }
        }
        
        if let body = body {
            request.httpBody = body.toData
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            // 1. Handle network error first
            if let error = error {
                failure(error, data, nil, response)
                return
            }
            
            // 2. Ensure response is HTTPURLResponse
            guard let httpResponse = response as? HTTPURLResponse else {
                failure(nil, data, nil, response)
                return
            }
            
            let statusCode = httpResponse.statusCode
            
            // 3. Check for success status code (200–299)
            guard (200...299).contains(statusCode) else {
                failure(nil, data, statusCode, httpResponse)
                return
            }
            
            // 4. Ensure data exists
            guard let data = data else {
                failure(nil, nil, statusCode, httpResponse)
                return
            }
            
            
            // 5. Success callback
            success(data, statusCode, httpResponse)
        }.resume()
    }
}
