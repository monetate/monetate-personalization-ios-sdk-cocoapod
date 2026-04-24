//
//  File.swift
//  monetate-ios-sdk
//
//  Created by Umar Sayyed on 05/10/20.
//  Copyright © 2020 Monetate. All rights reserved.
//

import Foundation

public struct Account:Codable {
    private var instance: String?
    private var domain: String?
    private var name: String?
    private var shortname: String?
    private var engineHost: MonetateHostDomain
    
    /**
     Contains standard domain name instance and shortname
     */
    
    public init(instance: String, domain:String, name:String, shortname:String, engineHostName:String? = nil) {
        self.instance = instance
        self.domain = domain
        self.name = name
        self.shortname = shortname
        if let domain = engineHostName?.trimmingCharacters(in: .whitespacesAndNewlines),
           !domain.isEmpty {
            self.engineHost = .custom(domain)
        } else {
            self.engineHost = .engine
        }
        
        do {
            try checkAccountInfo()
        } catch {
            Log.error(error.localizedDescription)
        }
    }
    
    func checkAccountInfo() throws {
        if instance?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true {
            throw AccountError.instance(description: "Invalid Account instance")
        }
        if domain?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true {
            throw AccountError.domain(description: "Invalid Account domain")
        }
        if name?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true {
            throw AccountError.name(description: "Invalid Account name")
        }
        if shortname?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?? true {
            throw AccountError.shortname(description: "Invalid Account shortname")
        }
    }


    
    func getSDKVersion() -> String {
        #if SWIFT_PACKAGE
        guard let url = Bundle.module.url(forResource: "Version", withExtension: "plist"),
              let dict = NSDictionary(contentsOf: url),
              let version = dict["CFBundleShortVersionString"] as? String else {
            return "Unknown"
        }
        return version
        #else
        return Bundle(for: Personalization.self)
            .infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        #endif
    }
    
    func getChannel () -> String {
        return "\(name ?? "")/\(instance ?? "")/\(domain ?? "")"
    }
    
    func getShortName () -> String {
        return self.shortname ?? ""
    }
    
    func getDomain () -> String {
        return self.domain ?? ""
    }
    
    func getEngineHost() -> MonetateHostDomain {
        return self.engineHost
    }
}

enum AccountError : Error {
    case instance(description: String)
    case domain(description: String)
    case name(description: String)
    case shortname(description: String)
}
