//
//  Personalization.swift
//  monetate-ios-sdk-example
//
//  Created by Umar Sayyed on 29/09/20.
//  Copyright © 2020 Monetate. All rights reserved.
//

import Foundation

public class Personalization {
    
    static private var _shared: Personalization!
    //static members
    public static var shared:Personalization {
        if Personalization._shared == nil {
            fatalError("Error - you must call setup before accessing Personalization.shared")
        }
        return Personalization._shared
    }
    
    //setup method
    public static func setup(account: Account, user: User, contextMap: ContextMap) {
        Personalization._shared = Personalization(account: account, user: user, contextMap: contextMap)
    }
    
    //class members
    public var account: Account
    private var user: User
    private var contextMap: ContextMap
    
    
    //getters
    public func getContextMap() -> ContextMap {return contextMap}
    
    //constructor
    
    private init (account: Account, user: User, contextMap: ContextMap) {
        self.account = account
        self.user = user
        self.contextMap = contextMap
    }
    
    private var queue: [ContextEnum: MEvent] = [:]
    private var errorQueue: [MError] = []
    
    public var timer = ScheduleTimer(timeInterval: 20, callback: {
        _ = Personalization.shared.callMonetateAPI()
    })
    
    func isContextSwitched (ctx:ContextEnum, event: MEvent) -> Bool {
        if ((ctx == .UserAgent || ctx == .IpAddress || ctx == .Coordinates ||
                ctx == .ScreenSize || ctx == .Referrer ||
                ctx == .PageView || ctx == .Metadata ||
                ctx == .CustomVariables || ctx == .Language)),
           let val1 = self.queue[ctx] as? Context,
           let val2 = event as? Context, val1.isContextSwitched(ctx: val2) {
            
            return true
        }
        
        return false
    }
    
    private func callMonetateAPIOnContextSwitched (context: ContextEnum, event:MEvent) {
        Log.debug("\n>> context switched\n")
        
        self.callMonetateAPI().on(success: { (res) in
            
            Log.debug("callMonetateAPIOnContextSwitched Success - \(self.queue.keys.count)")
            self.queue[context] = event
            self.timer.resume()
        }, failure: { (er) in
            Log.debug("callMonetateAPIOnContextSwitched Failure")
            
            self.timer.resume()
        })
    }
    
    private func callMonetateAPIOnContextSwitchedForGetActions () -> Future<APIResponse, Error> {
        let promise = Promise <APIResponse, Error>()
        
        Log.debug("\n>> context switched\n")
        self.callMonetateAPI().on(success: { (res) in
            Log.debug("callMonetateAPIOnContextSwitchedForGetActions Success \(self.queue.keys.count)")
            
            promise.succeed(value: res)
        }, failure: { (er) in
            Log.debug("callMonetateAPIOnContextSwitchedForGetActions Success \(self.queue.keys.count)")
            
            promise.fail(error: er)
        })
        return promise.future
    }
    
    public func flush () {
        _=callMonetateAPI()
    }
    
    public func setCustomerId (customerId: String) {
        self.user.setCustomerId(customerId: customerId)
    }
    
    func report (context:ContextEnum, eventCB:  (() -> Future<MEvent, Error>)?) {
        if let event = eventCB {
            event().on(success: { (data) in
                if self.isContextSwitched(ctx: context, event: data) {
                    self.callMonetateAPIOnContextSwitched(context: context, event: data)
                } else {
                    self.processEventsOnEventReporting(context, data)
                }
            }, failure: { (er) in
                self.errorQueue.append(MError(description: er.localizedDescription, domain: .RuntimeError, info: nil))
                Log.error("Error - \(er.localizedDescription)")
                
            })
        }
        
    }
    
    public func report (context:ContextEnum, event: MEvent?) {
        guard let event = event else {
            self.timer.resume()
            return
        }
        if isContextSwitched(ctx: context, event: event) {
            self.callMonetateAPIOnContextSwitched(context: context, event: event)
        } else {
            self.processEventsOnEventReporting(context, event)
        }
    }
    
    private func processEventsOnEventReporting (_ context: ContextEnum, _ event: MEvent) {
        
        Log.debug("\n>>context switched - not\n")
        Utility.processEvent(context: context, data: event, mqueue: self.queue, contextMap: self.contextMap).on(success: { (queue) in
            self.queue = queue
            Log.debug("Event Processed")
            
            self.timer.resume()
        })
    }
    
    fileprivate func processEvents(_ context: ContextEnum, _ event: MEvent, _ requestId: String, _ promise: Promise<APIResponse, Error>) {
        if isContextSwitched(ctx: context, event: event) {
            self.callMonetateAPIOnContextSwitchedForGetActions().on(success: { (res1) in
                Utility.processEvent(context: context, data: event, mqueue: self.queue, contextMap: self.contextMap).on(success: { (mqueue) in
                    self.queue = mqueue
                    //adding decision request event
                    self.queue[.DecisionRequest] = DecisionRequest(requestId: requestId)
                    self.callMonetateAPI(requestId: requestId).on(success: { (res) in
                        Log.debug("processEvents context switch - API success")
                        
                        promise.succeed(value: res)
                    }, failure: { (er) in
                        Log.debug("processEvents context switch - API failure")
                        
                        promise.fail(error: er)
                    })
                })
            }, failure: { (er) in
                promise.fail(error: er)
            })
        } else {
            Utility.processEvent(context: context, data: event, mqueue: self.queue, contextMap: self.contextMap).on(success: { (queue) in
                self.queue = queue
                //adding decision request event
                self.queue[.DecisionRequest] = DecisionRequest(requestId: requestId)
                self.callMonetateAPI(requestId: requestId).on(success: { (res) in
                    
                    Log.debug("processEvents without context switch  - API success")
                    promise.succeed(value: res)
                }, failure: { (er) in
                    
                    Log.error("processEvents without context switch  - API failure")
                    promise.fail(error: er)
                })
            })
        }
    }
    
    public func getActions (context:ContextEnum, requestId: String, event: MEvent?) -> Future<APIResponse, Error> {
        
        let promise = Promise <APIResponse, Error>()
        if let event = event {
            processEvents(context, event, requestId, promise)
        }else {
            //adding decision request event
            processDecision(requestId, promise)
        }
        
        return promise.future
    }
    
    fileprivate func processDecision(_ requestId: String, _ promise: Promise<APIResponse, Error>) {
        //adding decision request event
        self.queue[.DecisionRequest] = DecisionRequest(requestId: requestId)
        self.callMonetateAPI(requestId: requestId).on(success: { (res) in
            
            Log.debug("processDecision - API success")
            promise.succeed(value: res)
        },failure: { (er) in
            Log.error("processDecision - API failure")
            
            promise.fail(error: er)
        })
    }
    
    func getActions (context:ContextEnum, requestId: String, eventCB: (() -> Future<MEvent, Error>)?) -> Future<APIResponse, Error> {
        let promise = Promise <APIResponse, Error>()
        
        if let event = eventCB {
            event().on(success: { (data) in
                self.processEvents(context, data, requestId, promise)
            }, failure: { (er) in
                Log.debug("getActions with context map - failure")
                
                self.errorQueue.append(MError(description: er.localizedDescription, domain: .RuntimeError, info: nil))
                promise.fail(error: er)
            })
        } else {
            processDecision(requestId, promise)
        }
        return promise.future
    }
    
    public func toString () -> Future<String, Error> {
        let promise = Promise<String, Error>()
        
        let acount = try! JSONEncoder().encode(Personalization.shared.account)
        let user = try! JSONEncoder().encode(Personalization.shared.user)
        self.contextMap.toString().on(success: { (contextMap) in
            promise.succeed(value: acount.toString+user.toString+contextMap)
        }, failure: { (er) in
            promise.fail(error: er)
        }, completion: {})
        
        return promise.future
    }
    
    var API_URL = "https://api.monetate.net/api/engine/v1/decide/"
    
    public func callMonetateAPI (data: Data? = nil, requestId: String?=nil) -> Future<APIResponse,Error> {
        let promise = Promise<APIResponse,Error>()
        
        var body:[String:Any] = [
            "channel":account.getChannel(),
            "events": Utility.createEventBody(queue: self.queue)]
        if let val = self.user.kiboId { body["monetateId"] = val }
        if let val = self.user.deviceId { body["deviceId"] = val }
        if let val = self.user.customerId { body["customerId"] = val }
        Log.debug("success - \(body.toString!)")
        
        self.timer.suspend()
        Service.getDecision(url: self.API_URL + account.getShortName(), body: body, headers: nil, success: { (data, status, res) in
            self.queue = [:]
            Log.debug("callMonetateAPI - Success - \(data.toString)")
            
            promise.succeed(value: APIResponse(success: true, res: res, status: status, data: data, requestId:requestId))
        }) { (er, d, status, res) in
            Log.debug("callMonetateAPI - Error")
            
            if let err = er {
                promise.fail(error: err)
                self.errorQueue.append(MError(description: err.localizedDescription, domain: .ServerError, info: nil))
            } else {
                let er = NSError.init(domain: "API Error", code: status!, userInfo: nil)
                if let val = d {
                    let merror = MError(description: er.localizedDescription, domain: .APIError, info: val.toJSON()!)
                    Log.error("callMonetateAPI Error Message- \(val.toString)")
                    
                    self.errorQueue.append(merror)
                    promise.fail(error: merror)
                } else {
                    self.errorQueue.append(MError(description: er.localizedDescription, domain: .APIError, info: nil))
                    promise.fail(error: er)
                }
            }
        }
        
        return promise.future
    }
    
}


