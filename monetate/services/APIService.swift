//
//  APIService.swift
//  monetate-ios-sdk
//
//  Created by Umar Sayyed on 13/10/20.
//  Copyright © 2020 Monetate. All rights reserved.
//

import Foundation

enum Method:String {
    case GET
    case POST
    case PUT
    case DELETE
}

class Service {
    static func getDecision (url: String, body: [String: Any]?, headers: [String: String]?, success: @escaping (Data, Int, URLResponse) -> Void, failure: @escaping (Error?, Data?, Int?, URLResponse?)->Void) {
        
        let url = URL(string: url)!
        let contentType = "application/json"
        let type = "Content-Type"
        var request = URLRequest(url: url)
        request.httpMethod = Method.POST.rawValue
        if let d = body {
            request.httpBody = d.toData
        }
        request.addValue(contentType, forHTTPHeaderField: type)
        request.allHTTPHeaderFields = headers
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200 || httpURLResponse.statusCode == 201,
                  let d = data, let res = response, error == nil
            else {
                if let res = response as? HTTPURLResponse, let data = data {
                    failure(error, data, res.statusCode, res)
                } else {
                    failure(error, nil, nil, response)
                }
                return
            }
            success(d, httpURLResponse.statusCode, res)
        }.resume()
    }
    
    
}
