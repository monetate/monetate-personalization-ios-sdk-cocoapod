//
//  Utility.swift
//  monetate-ios-sdk
//
//  Created by Umar Sayyed on 12/11/20.
//  Copyright © 2020 Monetate. All rights reserved.
//

import Foundation


class Utility {
    
    public static func processEvent (context:ContextEnum, data: MEvent, mqueue: [ContextEnum: MEvent], contextMap: ContextMap) -> Future<[ContextEnum: MEvent], Error> {
        var queue = mqueue
        let promise = Promise<[ContextEnum: MEvent], Error>()
        switch context {
        case .Referrer:
            queue[.Referrer] = data
            promise.succeed(value: queue)
            break
        case .UserAgent:
            queue[.UserAgent] = data
            promise.succeed(value: queue)
            break
        case .IpAddress:
            queue[.IpAddress] = data
            promise.succeed(value: queue)
            break
        case .Coordinates:
            queue[.Coordinates] = data
            promise.succeed(value: queue)
            break
        case .ScreenSize:
            queue[.ScreenSize] = data
            promise.succeed(value: queue)
            break
        case .PageView:
            queue[.PageView] = data
            promise.succeed(value: queue)
            break
        case .PageEvents:
            if let event = queue[.PageEvents] as? PageEvents, let data = data as? PageEvents {
                event.pageEvents = event.pageEvents.union(data.pageEvents)
            } else {
                queue[.PageEvents] = data
            }
            if let cart = contextMap.pageEvents {
                cart().on { (data) in
                    if let event = queue[.PageEvents] as? PageEvents {
                        event.pageEvents = event.pageEvents.union(data.pageEvents)
                    }
                    promise.succeed(value: queue)
                }
            } else {
                promise.succeed(value: queue)
            }
            
            break
        case .ProductDetailView:
            if let event = queue[.ProductDetailView] as? ProductDetailView, let prod1 = event.products ,let data = data as? ProductDetailView, let prod2 = data.products  {
                event.products = ProductDetailView.merge(first: prod1, second: prod2)
            } else {
                queue[.ProductDetailView] = data
            }
            if let cart = contextMap.productDetailView {
                cart().on { (data) in
                    if let event = queue[.ProductDetailView] as? ProductDetailView, let lines1 = event.products, let lines2 = data.products {
                        event.products = ProductDetailView.merge(first: lines1, second: lines2)
                    }
                    promise.succeed(value: queue)
                }
            } else {
                promise.succeed(value: queue)
            }
            break
        case .ProductThumbnailView:
            if let event = queue[.ProductThumbnailView] as? ProductThumbnailView, let data = data as? ProductThumbnailView {
                event.products = event.products.union(data.products)
            } else {
                queue[.ProductThumbnailView] = data
            }
            if let cart = contextMap.productThumbnailView {
                cart().on { (data) in
                    if let event = queue[.ProductThumbnailView] as? ProductThumbnailView {
                        event.products = event.products.union(data.products)
                    }
                    promise.succeed(value: queue)
                }
            }else {
                promise.succeed(value: queue)
            }
            break
        case .Cart:
            if let key = queue[.Cart] as? Cart, let lines1 = key.cartLines, let data = data as? Cart, let lines2 = data.cartLines {
                key.cartLines = Cart.merge(first: lines1, second: lines2)
            } else {
                queue[.Cart] = data
            }
            if let cart = contextMap.cart {
                cart().on { (data) in
                    if let event = queue[.Cart] as? Cart, let lines1 = event.cartLines, let lines2 = data.cartLines {
                        event.cartLines = Cart.merge(first: lines1, second: lines2)
                    }
                    promise.succeed(value: queue)
                }
            } else {
                promise.succeed(value: queue)
            }
            break
        case .Purchase:
            if let event = queue[.Purchase] as? Purchase, let lines1 = event.purchaseLines, let data = data as? Purchase, let lines2 = data.purchaseLines  {
                event.purchaseLines = Purchase.merge(first: lines1, second: lines2)
            } else {
                queue[.Purchase] = data
            }
            if let cart = contextMap.purchase {
                cart().on { (data) in
                    if let event = queue[.Purchase] as? Purchase, let lines1 = event.purchaseLines, let lines2 = data.purchaseLines {
                        event.purchaseLines = Purchase.merge(first: lines1, second: lines2)
                    }
                    promise.succeed(value: queue)
                }
            } else {
                promise.succeed(value: queue)
            }
            break
            
        case .Metadata:
            if let event = queue[.Metadata] as? Metadata, let data = data as? Metadata {
                event.metadata = Metadata.merge(first: event.metadata, second: data.metadata)
            } else {
                queue[.Metadata] = data
            }
            promise.succeed(value: queue)
            break
        case .CustomVariables:
            if let event = queue[.CustomVariables] as? CustomVariables, let data = data as? CustomVariables {
                event.customVariables = CustomVariables.merge(first: event.customVariables, second: data.customVariables)
            } else {
                queue[.CustomVariables] = data
            }
            promise.succeed(value: queue)
            break
            
        default:
          
            Log.debug("No match found")
        }
        return promise.future
    }
    
    public static func createEventBody (queue: [ContextEnum: MEvent]) -> [[String:Any]?]  {
        var json:[[String:Any]?] = []
           for (key,val) in queue {
            if key == .Referrer, let val = val as? Referrer {
                let data = try! JSONEncoder().encode(val)
                json.append(data.toJSON())
            }
            if key == .UserAgent, let val = val as? UserAgent {
                let data = try! JSONEncoder().encode(val)
                json.append(data.toJSON())
            }
            if key == .Coordinates, let val = val as? Coordinates {
                let data = try! JSONEncoder().encode(val)
                json.append(data.toJSON())
            }
            if key == .ScreenSize, let val = val as? ScreenSize {
                let data = try! JSONEncoder().encode(val)
                json.append(data.toJSON())
            }
            if key == .IpAddress, let val = val as? IPAddress {
                let data = try! JSONEncoder().encode(val)
                json.append(data.toJSON())
            }
            if key == .Cart, let val = val as? Cart {
                let data = try! JSONEncoder().encode(val)
                json.append(data.toJSON())
            }
            if key == .ProductDetailView, let val = val as? ProductDetailView {
                let data = try! JSONEncoder().encode(val)
                json.append(data.toJSON())
            }
            if key == .ProductThumbnailView, let val = val as? ProductThumbnailView {
                let data = try! JSONEncoder().encode(val)
                json.append(data.toJSON())
            }
            if key == .Purchase, let val = val as? Purchase {
                let data = try! JSONEncoder().encode(val)
                json.append(data.toJSON())
            }
            if key == .DecisionRequest, let val = val as? DecisionRequest {
                let data = try! JSONEncoder().encode(val)
                json.append(data.toJSON())
            }
        }
        return json
    }
}
