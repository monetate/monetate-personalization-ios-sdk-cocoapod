//
//  KeychainAccess.swift
//  monetate-ios-sdk-example
//
//  Created by Umar Sayyed on 29/09/20.
//  Copyright © 2020 Monetate. All rights reserved.
//

import Foundation


public func getKiboId() -> String {
    
    // create a keychain helper instance
    let keychain = KeychainAccess()
    
    // this is the key we'll use to store the uuid in the keychain
    
    //TODO: write the logic to make uuidkey as dynamic to handle multiple sdk based app scenario
    let uuidKey = "com.myorg.myappid.unique_uuid"
    
    
    // check if we already have a uuid stored, if so return it
    let uuid = try? keychain.queryKeychainData(itemKey: uuidKey)
    if uuid != nil, let uuid = uuid {
        return uuid
    }
    
    // generate a new id
    //    guard let newId = UIDevice.current.identifierForVendor?.uuidString else {
    //        return nil
    //    }
    let newId = UUID().uuidString
    
    // store new identifier in keychain
    try? keychain.addKeychainData(itemKey: uuidKey, itemValue: newId)
    
    // return new id
    return newId
}

public func getDeviceId(key: String) -> String {
    
    // create a keychain helper instance
    let keychain = KeychainAccess()
    
    // this is the key we'll use to store the uuid in the keychain
    
    //TODO: write the logic to make uuidkey as dynamic to handle multiple sdk based app scenario
    let uuidKey = key
    
    // check if we already have a uuid stored, if so return it
    let uuid = try? keychain.queryKeychainData(itemKey: uuidKey)
    if uuid != nil, let uuid = uuid {
        return uuid
    }
    
    // generate a new id
    //    guard let newId = UIDevice.current.identifierForVendor?.uuidString else {
    //        return nil
    //    }
    let newId = UUID().uuidString
    
    // store new identifier in keychain
    try? keychain.addKeychainData(itemKey: uuidKey, itemValue: newId)
    
    // return new id
    return newId
}

class KeychainAccess {
    
    func addKeychainData(itemKey: String, itemValue: String) throws {
        guard let valueData = itemValue.data(using: .utf8) else {
            Log.debug("Keychain: Unable to store data, invalid input - key: \(itemKey), value: \(itemValue)")
            
            return
        }
        
        //delete old value if stored first
        do {
            try deleteKeychainData(itemKey: itemKey)
        } catch {
            Log.debug("Keychain: nothing to delete...")
            
        }
        
        let queryAdd: [String: AnyObject] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: itemKey as AnyObject,
            kSecValueData as String: valueData as AnyObject,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
        ]
        let resultCode: OSStatus = SecItemAdd(queryAdd as CFDictionary, nil)
        
        if resultCode != 0 {
            Log.debug("Keychain: value not added - Error: \(resultCode)")
            
        } else {
            Log.debug("Keychain: value added successfully")
            
        }
    }
    
    func deleteKeychainData(itemKey: String) throws {
        let queryDelete: [String: AnyObject] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: itemKey as AnyObject
        ]
        
        let resultCodeDelete = SecItemDelete(queryDelete as CFDictionary)
        
        if resultCodeDelete != 0 {
            Log.debug("Keychain: unable to delete from keychain: \(resultCodeDelete)")
            
        } else {
            Log.debug("Keychain: successfully deleted item")
            
        }
    }
    
    func queryKeychainData (itemKey: String) throws -> String? {
        let queryLoad: [String: AnyObject] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: itemKey as AnyObject,
            kSecReturnData as String: kCFBooleanTrue,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        let resultCodeLoad = withUnsafeMutablePointer(to: &result) {
            SecItemCopyMatching(queryLoad as CFDictionary, UnsafeMutablePointer($0))
        }
        
        if resultCodeLoad != 0 {
            Log.debug("Keychain: unable to load data - \(resultCodeLoad)")
            
            return nil
        }
        
        guard let resultVal = result as? NSData, let keyValue = NSString(data: resultVal as Data, encoding: String.Encoding.utf8.rawValue) as String? else {
            Log.debug("Keychain: error parsing keychain result - \(resultCodeLoad)")
            
            return nil
        }
        return keyValue
    }
}
