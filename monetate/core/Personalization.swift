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
    
    private let eventQueueManager = EventQueueManager()
    private var errorQueue: [MError] = []
    
    private var searchPrerequisite: SearchPreRequisite?
    
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
    
    /**
     generate a requestId of type String, which is further been used for making decision based call

     - Returns: A new unique request ID as a String.
     */
    private func generateRequestId() -> String {
        return UUID().uuidString
    }
    
    func isContextSwitched (ctx:ContextEnum, event: MEvent) -> Bool {
        if ((ctx == .UserAgent || ctx == .IpAddress || ctx == .Coordinates ||
             ctx == .ScreenSize || ctx == .Referrer ||
             ctx == .PageView || ctx == .Metadata ||
             ctx == .CustomVariables || ctx == .Language)),
           let val1 = eventQueueManager.getEvent(for: ctx) as? Context,
           let val2 = event as? Context, val1.isContextSwitched(ctx: val2) {
            return true
        }
        return false
    }
    
    private func callMonetateAPIOnContextSwitched (context: ContextEnum, event:MEvent) {
        Log.debug("\n>> context switched\n")
        
        self.callMonetateAPI().on(success: {[weak self] (res) in
            
            Log.debug("callMonetateAPIOnContextSwitched Success - \(self?.eventQueueManager.getQueueSnapshot().keys.count ?? 0)")
            self?.eventQueueManager.setEvent(event, for: context)
            self?.timer?.resume()
        }, failure: { (er) in
            Log.debug("callMonetateAPIOnContextSwitched Failure")
            
            self.timer?.resume()
        })
    }
    
    private func callMonetateAPIOnContextSwitchedForGetActions () -> Future<APIResponse, Error> {
        let promise = Promise <APIResponse, Error>()
        
        Log.debug("\n>> context switched\n")
        self.callMonetateAPI().on(success: {[weak self] (res) in
            Log.debug("callMonetateAPIOnContextSwitchedForGetActions Success \(self?.eventQueueManager.getQueueSnapshot().keys.count ?? 0)")
            
            promise.succeed(value: res)
        }, failure: {[weak self] (er) in
            Log.debug("callMonetateAPIOnContextSwitchedForGetActions Failure \(self?.eventQueueManager.getQueueSnapshot().keys.count ?? 0)")
            
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
        Utility.processEvent(context: context, data: event, mqueue: self.eventQueueManager.getQueueSnapshot()).on(success: {[weak self] (queue) in
            self?.eventQueueManager.setEvent(event, for: context)
            Log.debug("Event Processed")
            
            self?.timer?.resume()
        })
    }
    
    fileprivate func processEvents(_ context: ContextEnum, _ event: MEvent, _ requestId: String, _ includeReporting: Bool, _ arrActionTypes:[String], _ promise: Promise<APIResponse, Error>) {
        if isContextSwitched(ctx: context, event: event) {
            self.callMonetateAPIOnContextSwitchedForGetActions().on(success: { (res1) in
                Utility.processEvent(context: context, data: event, mqueue: self.eventQueueManager.getQueueSnapshot()).on(success: {[weak self] (mqueue) in
                    // Update the entire queue snapshot
                        self?.eventQueueManager.updateQueue(mqueue)
                    //adding decision request event
                    let decisionRequest = DecisionRequest(requestId: requestId, includeReporting: includeReporting, actionTypes: arrActionTypes)
                    self?.eventQueueManager.setEvent(decisionRequest, for: .DecisionRequest)
                    self?.callMonetateAPI(requestId: requestId).on(success: { (res) in
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
            Utility.processEvent(context: context, data: event, mqueue: self.eventQueueManager.getQueueSnapshot()).on(success: {[weak self] (queue) in
                // Update the entire queue snapshot
                    self?.eventQueueManager.updateQueue(queue)
                //adding decision request event
                let decisionRequest = DecisionRequest(requestId: requestId, includeReporting: includeReporting, actionTypes: arrActionTypes)
                self?.eventQueueManager.setEvent(decisionRequest, for: .DecisionRequest)
                self?.callMonetateAPI(requestId: requestId).on(success: { (res) in
                    
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
            Utility.processEvent(context: context, data: event, mqueue: self.eventQueueManager.getQueueSnapshot()).on(success: {[weak self] (queue) in
                // Update the entire queue snapshot
                    self?.eventQueueManager.updateQueue(queue)
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
        let decisionRequest = DecisionRequest(requestId: requestId, includeReporting: includeReporting, actionTypes: arrActionTypes)
        self.eventQueueManager.setEvent(decisionRequest, for: .DecisionRequest)
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
            "events": Utility.createEventBody(queue: eventQueueManager.getQueueSnapshot())]
        
        if let val = self.user.deviceId { body["deviceId"] = val } else if let val = self.user.monetateId { body["monetateId"] = val }
        if let val = self.user.customerId { body["customerId"] = val }
        let jsonString = body.toString ?? "JSON String conversion failed. Fallback: \(String(describing: body))"
        Log.debug("Monetate Engine API body created - \(jsonString)")
        
        self.timer?.suspend()
        Service.getDecision(url: self.API_URL + account.getShortName(), body: body, headers: nil, success: {[weak self] (data, status, res) in
            self?.eventQueueManager.updateQueue([:])
            Log.debug("callMonetateAPI - Success - \(data.toString)")
            
            promise.succeed(value: APIResponse(success: true, res: res, status: status, data: data, requestId:requestId))
        }) { (er, d, status, res) in
            Log.debug("callMonetateAPI - Error")
            
            if let err = er {
                promise.fail(error: err)
                self.errorQueue.append(MError(description: err.localizedDescription, domain: .ServerError, info: nil))
            } else {
                let er = NSError.init(domain: "API Error", code: status ?? -1, userInfo: nil)
                if let val = d {
                    let merror = MError(description: er.localizedDescription, domain: .APIError, info: val.toJSON() ?? [:])
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
    
    /**
     Used to report ProductThumbnailData
     - Parameter contextData: Context object that contains the ProductThumbnailData
     */
    public func reportProductThumbnailData(contextData: ContextObj) {
        let productThumbnailView = contextData.getProductThumbnailsData()
        report(context: .ProductThumbnailView, event: productThumbnailView)
    }

    /**
     Used to report Impressions data
     - Parameter ids: An array of id Strings to be processed
     */
    public func reportImpressionsData(ids: [String]) {
        let impressions = Impressions(impressionIds: ids)
        report(context: .Impressions, event: impressions)
    }

    /**
     Used to report RecImpressions data
     - Parameter tokens: An array of token Strings to be processed
     */
    public func reportRecImpressionsData(tokens: [String]) {
        let recImpressions = RecImpressions(recImpressions: tokens)
        report(context: .RecImpressions, event: recImpressions)
    }

    /**
     Used to report RecClicks data
     - Parameter tokens: An array of token Strings to be processed
     */
    public func reportRecClicksData(tokens: [String]) {
        let recClicks = RecClicks(recClicks: tokens)
        report(context: .RecClicks, event: recClicks)
    }
    
}

// MARK: - Search Feature Module
extension Personalization {
    
    /**
     Performs a search query and fetches results asynchronously.
     
     - Parameter searchTerm: The search query string. Must be non-empty string.
     - Parameter limit: Maximum number of results to return. Defaults to 10.
     
     - Returns: A `Future` containing an `APIResponse` with search results or an error.
     */
    public func fetchSearchResults(
        searchTerm: String,
        limit: Int = 10) -> Future<APIResponse, Error> {
            let promise = Promise<APIResponse, Error>()
            let prerequisiteFuture: Future<SearchPreRequisite, Error>
            
            // Validate input: trimmed non-empty, limit greater than zero
            guard !searchTerm.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                let error = SearchError.invalidInput
                Log.error(error.localizedDescription)
                promise.fail(error: error)
                return promise.future
            }
            if let obtPreRequisite = self.searchPrerequisite {
                // Wrap the cached prerequisite in an already succeeded future
                prerequisiteFuture = Future(value: obtPreRequisite)
            } else {
                prerequisiteFuture = fetchSearchPrerequisiteData()
            }
            
            //Obtain prerequisite parameters
            prerequisiteFuture
                .on(
                    success: { [weak self] preRequisite in
                        
                        guard let self = self.guardSelf(promise: promise) else { return }
                        
                        self.searchPrerequisite = preRequisite
                        self.fetchSearchData(searchTerm: searchTerm, limit: limit)
                            .on(
                                success: { apiResponse in
                                    promise.succeed(value: apiResponse)
                                },
                                failure: { err in
                                    Log.error(err.localizedDescription)
                                    promise.fail(error: err)
                                })
                    },
                    failure: { err in
                        Log.error(err.localizedDescription)
                        promise.fail(error: err)
                    })
            
            return promise.future
        }
    
    /**
     Fetches prerequisites required from getActionsData before executing a search operation and keep for reuse.
     - Returns: The search-related prerequisite data needed by the calling process or error.
     */
    private func fetchSearchPrerequisiteData() -> Future<SearchPreRequisite, Error> {
        let requestId = generateRequestId()
        let promise = Promise<SearchPreRequisite, Error>()
        
        let future = self.getActionsData(
            requestId: requestId,
            includeReporting: false,
            arrActionTypes: [ContextEnum.search.rawValue]
        )
        
        future
            .on(
                success: { [weak self] responseData in
                    guard let self = self.guardSelf(promise: promise) else { return }
                    
                    do {
                        let searchPrerequisite = try self.extractSearchPreRequestInfo(from: responseData)
                        promise.succeed(value: searchPrerequisite)
                    } catch {
                        let err = (error as? SearchError) ?? error
                        promise.fail(error: err)
                    }
                },
                failure: { error in
                    promise.fail(error: error)
                }
            )
        return promise.future
    }

    /**
     Extracts and validates search prerequisites from the given API response.
     
     This method parses the raw `APIResponse`, converts it to a strongly-typed `ExperienceDataResponse`,
     and extracts the required `SearchPreRequestInfo` needed to perform a search operation.
     
     - Parameter responseData: The raw response data returned from the `getActionsData` API call.
     
     - Returns: A `SearchPreRequestInfo` object containing validated and extracted value  `searchToken`, or nil if missing and `channel` data.
     
     - Throws:
     - `SearchError.fetchFailed` if the response cannot be parsed into valid JSON.
     
     - Warning:
     - `SearchError.noActionsFound` if no action data is found in the response.
     - `SearchError.noSearchActionFound` if no search action is present among the actions.
     - `SearchError.missingActionProperties` if required properties `searchToken` property is missing.
     */
    
    private func extractSearchPreRequestInfo(from responseData: APIResponse) throws -> SearchPreRequisite {
        let jsonData: Data
        
        // Attempt to convert data to JSON
        if let data = responseData.data as? Data {
            jsonData = data
        } else if let dict = responseData.data as? [String: Any] {
            jsonData = try JSONSerialization.data(withJSONObject: dict, options: [])
        } else {
            throw SearchError.fetchFailed
        }
        
        // Decode to structured object
        let decoder = JSONDecoder()
        let root = try decoder.decode(ExperienceDataResponse.self, from: jsonData)
        
        // Extract channel data
        let channel = account.getChannel()
        
        var searchToken: String? = nil
        
        // Try to get actions and searchToken, log warnings on missing data
        if
            let responses = root.data?.experienceResponses,
            let firstResponse = responses.first,
            let actions = firstResponse.experienceActions,
            !actions.isEmpty
        {
            if let searchAction = actions.first(where: { $0.actionType == ContextEnum.search.rawValue }) {
                if let token = searchAction.searchToken {
                    searchToken = token
                } else {
                    Log.warning(SearchError.missingActionProperties.localizedDescription)
                }
            } else {
                Log.warning(SearchError.noSearchActionFound(domain: account.getDomain()).localizedDescription)
            }
        } else {
            Log.warning(SearchError.noActionsFound.localizedDescription)
        }
        
        return SearchPreRequisite(searchToken: searchToken, channelData: channel)
    }

    
    /**
     Fetches search data asynchronously using the provided search term and result limit.
     
     This function builds a `SearchRequest` body and returns a `Future` that will
     eventually hold the API response or an error if request creation fails.
     
     - Parameters:
       - searchTerm: The string term to search for.
       - limit: The maximum number of results to return.
     
     - Returns: A `Future` containing an `APIResponse` or an `Error`.
     */
    private func fetchSearchData(
        searchTerm: String,
        limit: Int
    ) -> Future<APIResponse, Error> {
        let promise = Promise<APIResponse, Error>()
        
        do {
            let reqId = generateRequestId()
            let body = createSearchBody(searchTerm: searchTerm, limit: limit, searchToken: self.searchPrerequisite?.searchToken, reqId: reqId)
            let bodyDict = try body.toDictionary()
            Log.debug("Search request body - \(bodyDict.toString ?? "nil"))")
            
            self.monetateSearchApiCall(
                endpoint: .search,
                body: bodyDict,
                channelData: searchPrerequisite?.channelData ?? "",
                requestId: reqId).on (
                    success: { response in
                        promise.succeed(value: response)
                    },
                    failure: { err in
                        promise.fail(error: err)
                    }
                )
        } catch {
            promise.fail(error: error)
        }
        return promise.future
    }

    /**
     Creates a `SearchRequest` object configured with the given search term, result limit, and search token.

     This method constructs the necessary query components including the query term, record settings,
     and a unique record query, and wraps them into a `SearchRequest` which can be used to perform a search.

     - Parameters:
       - searchTerm: The string term to be searched.
       - limit: The maximum number of results to return.
       - searchToken: A token to identify or track the search session.

     - Returns: A fully formed `SearchRequest` ready for use in a search operation.
     */
    private func createSearchBody(searchTerm: String, limit: Int, searchToken: String?, reqId: String) -> SearchRequest {
        let queryTerm = SearchRequest.QueryTerm(term: searchTerm)
        let settings = SearchRequest.RecordSettings(query: queryTerm, limit: limit)
        let recordQuery = SearchRequest.RecordQuery(id: reqId, typeOfRequest: .search, settings: settings)
        return SearchRequest(recordQueries: [recordQuery], suggestions: [], searchToken: searchToken)
    }
    
    /**
     Makes an asynchronous API call to the Monetate search endpoint.

     This function constructs and sends a search request using the provided endpoint,
     request body, channel information, and request identifier. It returns a `Future`
     that will eventually contain either a successful `APIResponse` or an `Error`.

     - Parameters:
       - endpoint: The API endpoint configuration to use for the request.
       - body: A dictionary representing the JSON payload to send in the request body.
       - channelData: A string representing channel-specific data (e.g., platform or source).
       - requestId: A unique identifier for tracking the API request.

     - Returns: A `Future` containing an `APIResponse` on success or an `Error` on failure.
     */
    private func monetateSearchApiCall(
        endpoint: APIConfig.Endpoint,
        body: [String: Any],
        channelData: String,
        requestId: String
    ) -> Future<APIResponse, Error> {
        let promise = Promise<APIResponse, Error>()
        let url = getSearchURL(channel: channelData, endpoint: endpoint)
        Service.getDecision(
            url: url,
            body: body,
            headers: nil,
            success: { data, statusCode, response in
                let apiResponse = APIResponse(success: true, res: response, status: statusCode, data: data, requestId:requestId)
                Log.debug("Search API success response - \(String(describing: apiResponse.data))")
                promise.succeed(value: apiResponse)
            },
            failure: { (er, d, status, res) in
                Log.debug("Search API - Error")
                
                if let err = er {
                    let mError = MError(description: err.localizedDescription, domain: .ServerError, info: nil)
                    self.errorQueue.append(mError)
                    Log.error("Search API Error Message - \(err.localizedDescription)")
                    promise.fail(error: err)
                } else {
                    let er = NSError.init(domain: "API Error", code: status ?? -1, userInfo: nil)
                    if let val = d {
                        let mError = MError(description: er.localizedDescription, domain: .APIError, info: val.toJSON() ?? [:])
                        self.errorQueue.append(mError)
                        Log.error("Search API Error Message- \(val.toString)")
                        promise.fail(error: mError)
                    } else {
                        let mError = MError(description: er.localizedDescription, domain: .APIError, info: nil)
                        self.errorQueue.append(mError)
                        Log.error("Search API Error Message - \(er.localizedDescription)")
                        promise.fail(error: mError)
                    }
                }
            }
        )
        return promise.future
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

extension Encodable {
    func toDictionary() throws -> [String: Any] {
        let data = try JSONEncoder().encode(self)
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
        guard let dictionary = jsonObject as? [String: Any] else {
            throw NSError(domain: "ENCODING", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to cast JSON to dictionary"])
        }
        return dictionary
    }
}

 private extension Optional where Wrapped: AnyObject {
    func guardSelf<T>(promise: Promise<T, Error>, failure: Error = SearchError.configurationFailed) -> Wrapped? {
        guard let selfRef = self else {
            Log.error(failure.localizedDescription)
            promise.fail(error: failure)
            return nil
        }
        return selfRef
    }
}
