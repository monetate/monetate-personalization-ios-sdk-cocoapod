//
//  Utility.swift
//  monetate-ios-sdk
//
//  Created by Umar Sayyed on 12/11/20.
//  Copyright © 2020 Monetate. All rights reserved.
//

import Foundation


class Utility {
    
    static func processEvent (context:ContextEnum, data: MEvent, mqueue: [ContextEnum: MEvent]) -> Future<[ContextEnum: MEvent], Error> {
        var queue = mqueue
        let promise = Promise<[ContextEnum: MEvent], Error>()
        switch context {
        case .RecClicks:
            queue[.RecClicks] = data
            promise.succeed(value: queue)
            break
        case .RecImpressions:
            queue[.RecImpressions] = data
            promise.succeed(value: queue)
            break
        case .Impressions:
            queue[.Impressions] = data
            promise.succeed(value: queue)
            break
        case .PageEvents:
            queue[.PageEvents] = data
            promise.succeed(value: queue)
            break
        case .ProductDetailView:
            if let event = queue[.ProductDetailView] as? ProductDetailView, let prod1 = event.products ,let data = data as? ProductDetailView, let prod2 = data.products  {
                event.products = ProductDetailView.merge(first: prod1, second: prod2)
            } else {
                queue[.ProductDetailView] = data
            }
            promise.succeed(value: queue)
            break
        case .ProductThumbnailView:
            if let event = queue[.ProductThumbnailView] as? ProductThumbnailView, let data = data as? ProductThumbnailView {
                event.products = event.products.union(data.products)
            } else {
                queue[.ProductThumbnailView] = data
            }
            promise.succeed(value: queue)
            break
        case .Cart:
            if let key = queue[.Cart] as? Cart, let lines1 = key.cartLines, let data = data as? Cart, let lines2 = data.cartLines {
                key.cartLines = Cart.merge(first: lines1, second: lines2)
            } else {
                queue[.Cart] = data
            }
            promise.succeed(value: queue)
            break
        case .AddToCart:
            if let key = queue[.AddToCart] as? AddToCart, let lines1 = key.cartLines, let data = data as? AddToCart, let lines2 = data.cartLines {
                key.cartLines = AddToCart.merge(first: lines1, second: lines2)
            } else {
                queue[.AddToCart] = data
            }
            promise.succeed(value: queue)
            break
        case .Purchase:
            if let event = queue[.Purchase] as? Purchase, let lines1 = event.purchaseLines, let data = data as? Purchase, let lines2 = data.purchaseLines  {
                event.purchaseLines = Purchase.merge(first: lines1, second: lines2)
            } else {
                queue[.Purchase] = data
            }
            promise.succeed(value: queue)
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
            queue[context] = data
            promise.succeed(value: queue)
        }
        return promise.future
    }
    
    static func createEventBody (queue: [ContextEnum: MEvent]) -> [[String:Any]?]  {
        var json:[[String:Any]?] = []
        for (key,val) in queue {
            if key == .CustomVariables, let val = val as? CustomVariables {
                let data = try! JSONEncoder().encode(val)
                json.append(data.toJSON())
            }
            if key == .PageView, let val = val as? PageView {
                let data = try! JSONEncoder().encode(val)
                json.append(data.toJSON())
            }
            if key == .Language, let val = val as? Language {
                let data = try! JSONEncoder().encode(val)
                json.append(data.toJSON())
            }
            if key == .RecClicks, let val = val as? RecClicks {
                let data = try! JSONEncoder().encode(val)
                json.append(data.toJSON())
            }
            if key == .RecImpressions, let val = val as? RecImpressions {
                let data = try! JSONEncoder().encode(val)
                json.append(data.toJSON())
            }
            if key == .Impressions, let val = val as? Impressions {
                let data = try! JSONEncoder().encode(val)
                json.append(data.toJSON())
            }
            if key == .PageEvents, let val = val as? PageEvents {
                let data = try! JSONEncoder().encode(val)
                json.append(data.toJSON())
            }
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
            if key == .AddToCart, let val = val as? AddToCart {
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
