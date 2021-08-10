
kibo-personalization-sdk: iOS

Overview
This SDK enables easy communication with Engine API and can be used by any application which is built using iOS
Using this SDK we can report events and get actions from Engine API.


Installation
 pod 'monetate-ios-sdk'
 pod 'monetate-ios-sdk', :git => 'https://github.com/monetate/kibo-ios-sdk-cocoapod.git', :branch => 'main'


Getting started with development :-

Import SDK  
import  "monetate-ios-sdk"

Initialize 
   Personalization.setup(
      account: Account(instance: "p", domain: "localhost.org", name: "a-701b337c", shortname: "localhost"),
      user: User(kiboId: "auto"),
      contextMap: setupContextMap()
   )

contextMap :-
 includes a list of events for which event data can be passed at the time of initialization. If we want to pass AUTO for an event it should be mentioned at the time of initialization only in contextMap.

func setupContextMap () -> ContextMap {
   return ContextMap(
      userAgent: UserAgent(auto: true),
      ipAddress: IPAddress(ipAddress: "192.168.0.1"),
      coordinates: Coordinates.init(auto: true),
      screenSize: ScreenSize(auto: true),
      
cart: {() in
         let promise = Promise<Cart, Error>()
         promise.succeed(value: Cart(cartLines: [CartLine(sku: "SKU-111", pid: "PID-111", quantity: 2, currency: "USD", value: "460"), CartLine(sku: "SKU-222", pid: "PID-222", quantity: 4, currency: "USD", value: "560")]))
         return promise.future
   },
      purchase: {
         let promise = Promise<Purchase, Error>()
         let p = Purchase(account: "account-232", domain: "tem.dom.main", instance: "temp", purchaseId: "pur-23232", purchaseLines: [
            PurchaseLine(sku: "SKU-123", pid: "Prod-1232", quantity: 2, currency: "USD", value: "2.99")
         ])
         promise.succeed(value: p)
         return promise.future
   },
      productDetailView: { () in
         let promise = Promise<ProductDetailView, Error>()
         let result = ProductDetailView.init(products: [
            Product.init(productId: "PROD-9898", sku: "SKU-9898"),
            Product.init(productId: "PROD-8989", sku: "SKU-8989")
         ])
         promise.succeed(value: result)
         return promise.future
   },
      productThumbnailView: {
         let promise = Promise<ProductThumbnailView, Error>()
         let result =     ProductThumbnailView.init(products: [""])
         promise.succeed(value: result)
         return promise.future
   },
      pageView: { () in
         let promise = Promise<PageView, Error>()
         let r = PageView(pageType: "profile", path: "/profile", url: "http:/home", categories: nil, breadcrumbs: nil)
         promise.succeed(value: r)
         return promise.future
   },
      metadata: { () in
         let promise = Promise<Metadata, Error>()
         let r = Metadata(metadata: JSONValue(dictionaryLiteral: ("Key1", "Val1"), ("Key2", "Val2")))
         promise.succeed(value: r)
         return promise.future
   },
      customVariables: { () in
         let promise = Promise<CustomVariables, Error>()
         let r = CustomVariables(customVariables: [
            CustomVariablesModel(variable: "TempVariable", value: JSONValue.init(dictionaryLiteral: ("String", "JSONValue"))),
            CustomVariablesModel(variable: "KEY", value: JSONValue.init(dictionaryLiteral: ("String", "JSONValue")))
         ])
         promise.succeed(value: r)
         return promise.future
   })
   
}

Report method:-
Personalization.shared.report(context: .UserAgent, event: UserAgent(key))

This method reports data to Engine API. It take two arguments, first is eventType and second is eventData which is optional. If eventData is not defined, the SDK looks for data in the Context Map which is defined at the time of initialization.


Get Action method

Personalization.shared.getActions(context: .UserAgent, requestId: requestId, event: UserAgent(key)).on(success: { (res) in
                self.handleAction(res: res)
            })
This method is used to request decisions and report events as well. It returns object containing the JSON from appropriate actions. eventType and eventData are optional parameters. If we only need actions we can skip optional parameters. requestId is the request identifier tying the response back to an event.

Flush method
 Personalization.shared.flush();
For the sake of improving performance, events are queued and all sent at the same time (within a single request) after a 700ms interval is reached. The Flush method forces all enqueued events to be sent to the server immediately and clears the queue.
