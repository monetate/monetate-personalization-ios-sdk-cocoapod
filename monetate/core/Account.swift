//
//  File.swift
//  monetate-ios-sdk
//
//  Created by Umar Sayyed on 05/10/20.
//  Copyright © 2020 Monetate. All rights reserved.
//

import Foundation

public struct Account:Codable {
    private var instance: String
    private var domain: String
    private var name: String
    private var shortname: String
    
    /**
     Contains standard domain name instance and shortname
     */
    
    public init(instance: String, domain:String, name:String, shortname:String) {
        self.instance = instance
        self.domain = domain
        self.name = name
        self.shortname = shortname
        try! checkAccountInfo()
    }
    
    func checkAccountInfo () throws {
        if (instance == "") {throw AccountError.instance(description: "Invalid Account instance")}
        if (domain == "") {throw AccountError.domain(description: "Invalid Account domain")}
        if (name == "") {throw AccountError.name(description: "Invalid Account name")}
        if (shortname == "") {throw AccountError.shortname(description: "Invalid Account shortname")}
    }
    
    func getSDKVersion() -> String {
        return (Bundle(for: Personalization.self).infoDictionary?["CFBundleShortVersionString"] as? String)!
    }
    
    func getChannel () -> String {
        return "\(name)/\(instance)/\(domain)"
    }
    
    func getShortName () -> String {
        return self.shortname
    }
    
    func getDomain () -> String {
        return self.domain
    }
}

enum AccountError : Error {
    case instance(description: String)
    case domain(description: String)
    case name(description: String)
    case shortname(description: String)
}
