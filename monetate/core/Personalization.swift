//
//  Personalization.swift
//  monetate-ios-sdk-example
//
//  Created by Umar Sayyed on 29/09/20.
//  Copyright © 2020 Monetate. All rights reserved.
//

import Foundation

public class Personalization {
        
    //class members
    public var account: Account
    private var user: User
    public var timer: ScheduleTimer?
    
    //constructor
    
    public init (account: Account, user: User) {
        self.account = account
        self.user = user
        self.timer = ScheduleTimer(timeInterval: 0.7, callback: { [self] in
            _ = self.callMonetateAPI()
        })
    }
    
    public func generateMonetateID () -> String {
        let version = 2
        let rnd = Int(Int.random(in: 0...2147483647)) // random in between [0, 2^31 - 1)
        let ts = Int(Date().toMillis()) // current time in millis
        let token = "\(version).\(rnd).\(ts)"

        Log.debug("generateMonetateID - \(token)", shouldLogContext: false)
        return token
    }
    
    private var queue: [ContextEnum: MEvent] = [:]
    private var errorQueue: [MError] = []
    
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
            self.timer?.resume()
        }, failure: { (er) in
            Log.debug("callMonetateAPIOnContextSwitched Failure")
            
            self.timer?.resume()
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
    /**
     Used to manually send all queued reporting data immediately, instead of waiting for the next automatic send. That means make api call with existing data from queue and clear it.
     */
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
    /**
     Used to add events to the queue, which will be sent with the next flush() call or as part of an automatic timed send.
     
     context is name of event for example monetate:record:Impressions.
     
     eventData is data associated with event and it is optional parameter.
     */
    public func report (context:ContextEnum, event: MEvent?) {
        guard let event = event else {
            self.timer?.resume()
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
        Utility.processEvent(context: context, data: event, mqueue: self.queue).on(success: { (queue) in
            self.queue = queue
            Log.debug("Event Processed")
            
            self.timer?.resume()
        })
    }
    
    fileprivate func processEvents(_ context: ContextEnum, _ event: MEvent, _ requestId: String, _ includeReporting: Bool, _ arrActionTypes:[String], _ promise: Promise<APIResponse, Error>) {
        if isContextSwitched(ctx: context, event: event) {
            self.callMonetateAPIOnContextSwitchedForGetActions().on(success: { (res1) in
                Utility.processEvent(context: context, data: event, mqueue: self.queue).on(success: { (mqueue) in
                    self.queue = mqueue
                    //adding decision request event
                    self.queue[.DecisionRequest] = DecisionRequest(requestId: requestId, includeReporting: includeReporting, actionTypes: arrActionTypes)
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
            Utility.processEvent(context: context, data: event, mqueue: self.queue).on(success: { (queue) in
                self.queue = queue
                //adding decision request event
                self.queue[.DecisionRequest] = DecisionRequest(requestId: requestId, includeReporting: includeReporting, actionTypes: arrActionTypes)
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
    /**
     Used to record event and also request decision(s).
     
     requestId the request identifier tying the response back to an event
     
     context ? is name of event for example monetate:record:Impressions.
     
     eventData ? is data associated with event.
     
     context and eventData are optional fields.
     
     Returns an object containing the JSON from appropriate action(s), using the types in the action table below. Those objects are reformatted into a consistent returned json with a required actionType and action.
     
     Also sends any queue data.
     
     status is the value returned from {meta: {code: ###}}. Anything other than 200 does not include actions in the return.
     */
    public func getActions (context:ContextEnum, requestId: String, includeReporting: Bool, arrActionTypes:[String], event: MEvent?) -> Future<APIResponse, Error> {
        
        let promise = Promise <APIResponse, Error>()
        if let event = event {
            processEvents(context, event, requestId, includeReporting, arrActionTypes, promise)
        }else {
            //adding decision request event
            processDecision(requestId, includeReporting, arrActionTypes, promise)
        }
        
        return promise.future
    }
    
    /**
     Used to add events in queue.
     
     context ? is name of event for example monetate:record:Impressions.
     
     eventData ? is data associated with event.
     
     context and eventData are optional fields.
     
     */
    public func addEvent(context:ContextEnum, event: MEvent?) {
        if let event = event {
            Utility.processEvent(context: context, data: event, mqueue: self.queue).on(success: { (queue) in
                self.queue = queue
            })
        }
    }
    
    /**
     Used request decisions with multiple contexts.
     
     requestId the request identifier tying the response back to an event
     
     Returns an object containing the JSON from appropriate action(s), using the types in the action table below. Those objects are reformatted into a consistent returned json with a required actionType and action.
     
     Also sends any queue data.
     
     status is the value returned from {meta: {code: ###}}. Anything other than 200 does not include actions in the return.
     
     */
    public func getActionsData(requestId: String, includeReporting: Bool, arrActionTypes:[String]) -> Future<APIResponse, Error>  {
        let promise = Promise <APIResponse, Error>()
        processDecision(requestId, includeReporting, arrActionTypes, promise)
        return promise.future
    }
    
    fileprivate func processDecision(_ requestId: String, _ includeReporting: Bool, _ arrActionTypes:[String], _ promise: Promise<APIResponse, Error>) {
        //adding decision request event
        self.queue[.DecisionRequest] = DecisionRequest(requestId: requestId, includeReporting: includeReporting, actionTypes: arrActionTypes)
        self.callMonetateAPI(requestId: requestId).on(success: { (res) in
            Log.debug("processDecision - API success")
            promise.succeed(value: res)
        },failure: { (er) in
            Log.error("processDecision - API failure")
            promise.fail(error: er)
        })
    }
    
    func getActions (context:ContextEnum, requestId: String, includeReporting: Bool, arrActionTypes:[String], eventCB: (() -> Future<MEvent, Error>)?) -> Future<APIResponse, Error> {
        let promise = Promise <APIResponse, Error>()
        
        if let event = eventCB {
            event().on(success: { (data) in
                self.processEvents(context, data, requestId, includeReporting, arrActionTypes, promise)
            }, failure: { (er) in
                Log.debug("getActions with multi-events - failure")
                
                self.errorQueue.append(MError(description: er.localizedDescription, domain: .RuntimeError, info: nil))
                promise.fail(error: er)
            })
        } else {
            processDecision(requestId, includeReporting, arrActionTypes, promise)
        }
        return promise.future
    }
    
    var API_URL = "https://api.monetate.net/api/engine/v1/decide/"
    
    func callMonetateAPI (data: Data? = nil, requestId: String?=nil) -> Future<APIResponse,Error> {
        let promise = Promise<APIResponse,Error>()
        
        var body:[String:Any] = [
            "channel":account.getChannel(),
            "sdkVersion": account.getSDKVersion(),
            "events": Utility.createEventBody(queue: self.queue)]
        
        if let val = self.user.deviceId { body["deviceId"] = val } else if let val = self.user.monetateId { body["monetateId"] = val }
        if let val = self.user.customerId { body["customerId"] = val }
        Log.debug("success - \(body.toString!)")
        
        self.timer?.suspend()
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

// MARK: - New individual Report methodes
extension Personalization {
    /**
     * Used to report PageEvents data
     * - Parameter contextData: Context object that contains the PageEvents data
     */
    public func reportPageEvents(contextData: ContextObj) {
        let pageEventsData = contextData.getPageEventsData()
        report(context: .PageEvents, event: pageEventsData)
    }
    
    /**
     * Used to report Cart data
     * - Parameter contextData: Context object  that contains the Cart data
     */
    public func reportCartData(contextData: ContextObj) {
        let cartLines = contextData.getAllCartData()
        let cart = Cart(cartLines: cartLines)
        report(context: .Cart, event: cart)
    }
    
    /**
     * Used to report Single Cart data
     * - Parameter contextData: Context object  that contains the AddToCart data
     */
    public func reportAddToCartData(contextData: ContextObj) {
        if let cartLine = contextData.getSingleCartData() {
            let cartLines = [cartLine]
            let addToCart = AddToCart(cartLines: cartLines)
            report(context: .AddToCart, event: addToCart)
        }
    }
    
    /**
     Used to report Purchase data
     - Parameter contextData: Context object that contains the Purchase data
     */
    public func reportPurchaseData(contextData: ContextObj) {
        let purchaseData = contextData.getPurchaseData()
        report(context: .Purchase, event: purchaseData)
    }

    /**
     Used to report PageDetails data
     - Parameter contextData: Context object that contains the PageDetails data
     */
    public func reportPageDetails(contextData: ContextObj) {
        let pageView = contextData.getPageDetails()
        report(context: .PageView, event: pageView)
    }

    /**
     Used to report ProductDetails data
     - Parameter contextData: Context object that contains the ProductDetails data
     */
    public func reportProductDetails(contextData: ContextObj) {
        let productDetailView = contextData.getProductDetails()
        report(context: .ProductDetailView, event: productDetailView)
    }
    
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
