//
//  UserID.swift
//  monetate-ios-sdk
//
//  Created by Umar Sayyed on 05/10/20.
//  Copyright © 2020 Monetate. All rights reserved.
//

import Foundation

public class User :Codable {
    public var kiboId: String?
    public var deviceId: String?
    public var customerId: String?
    /**
     Value should be passed in every call

     If deviceId   has a value it should be the default id sent in all API calls

     If kiboId is auto the SDK should generate a new id and replace auto with the returned ID. kiboId can also be a value set by the client. If deviceId is not defined then kiboId should be used as the default id.

     We populate the value from auto into these key/value pairs so that the client can read them and save them if desired.

     Either kiboId or deviceId is required in API calls. Both ids should not be passed together.

     If customerId is defined it should also be passed in all calls along with one of the other ids. no auto option for customerId. This should not be changed after init except for when setCustomerId() is called
     */
    public init(kiboId:String?=nil, deviceId: String? = nil, customerId: String? = nil) {
        self.kiboId = kiboId
        if let val = kiboId{
            self.kiboId = val
            if (val == "auto") {self.kiboId = generateKiboID()}
        }
        self.deviceId = deviceId
        if let val = deviceId {
            self.deviceId = val
            if (val == "auto") {self.deviceId = getDeviceId(key: Personalization.shared.account.getChannel())}
        }
        self.customerId = customerId
        
        try! checkKiboIDAndDeviceID()
    }
    
    func checkKiboIDAndDeviceID () throws {
        if (kiboId == nil && deviceId == nil) {throw CustomError.UserID(description: "kiboId or deviceId, anyone is required")}
    }
    
    public func setCustomerId (customerId: String) {
        self.customerId = customerId
    }
}

enum CustomError : Error {
    case UserID(description: String)
}

fileprivate func generateKiboID () -> String {
    let version = 1
    let rnd = Int(Int.random(in: 0...2147483647)) // random in between [0, 2^31 - 1)
    let ts = Int(Date().toMillis()) // current time in millis
    let token = "\(version).\(rnd).\(ts)"
    
    Log.debug("generateKiboID - \(token)", shouldLogContext: false)
    return token
}

extension Date {
    func toMillis() -> Int64! {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
    init(millis: Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(millis / 1000))
        self.addTimeInterval(TimeInterval(Double(millis % 1000) / 1000 ))
    }
}
