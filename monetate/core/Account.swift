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
        if let text = Bundle(for: Personalization.self).infoDictionary?["CFBundleShortVersionString"] as? String {
            print(text)
        }
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
}
