
//
//  ContextMap.swift
//  monetate-ios-sdk
//
//  Created by Umar Sayyed on 05/10/20.
//  Copyright © 2020 Monetate. All rights reserved.
//

import Foundation

public class ContextMap {
    
    //auto trackables
    var userAgent: UserAgent?
    var ipAddress: IPAddress?
    var coordinates: Coordinates?
    var screenSize: ScreenSize?
    
    
    //getters
    public func getCoordinates () -> Coordinates? {return coordinates}
    //setters
    public func setCoordinates (coords: Coordinates) { coordinates = coords}
    
    //non trackables
    var cart:  (() -> Future<Cart, Error>)?
    var purchase:  (() -> Future<Purchase, Error>)?
    var productDetailView: (() -> Future<ProductDetailView, Error>)?
    var productThumbnailView: (() -> Future<ProductThumbnailView, Error>)?
    var pageView:  (() -> Future<PageView, Error>)?
    var pageEvents:  (() -> Future<PageEvents, Error>)?
    var metadata:  (() -> Future<Metadata, Error>)?
    var customVariables:  (() -> Future<CustomVariables, Error>)?
    
    public init (
        userAgent: UserAgent? = nil,
        ipAddress: IPAddress? = nil,
        coordinates: Coordinates? = nil,
        screenSize: ScreenSize? = nil,
        
        cart: (() -> Future<Cart, Error>)? = nil,
        purchase: (() -> Future<Purchase, Error>)? = nil,
        productDetailView: (() -> Future<ProductDetailView, Error>)? = nil,
        productThumbnailView: (() -> Future<ProductThumbnailView, Error>)? = nil,
        pageView: (() -> Future<PageView, Error>)? = nil,
        pageEvents: (() -> Future<PageEvents, Error>)? = nil,
        metadata: (() -> Future<Metadata, Error>)? = nil,
        customVariables: (() -> Future<CustomVariables, Error>)? = nil
        
    ) {
        
        //auto trackables
        self.userAgent = userAgent
        self.ipAddress = ipAddress
        self.coordinates = coordinates
        self.screenSize = screenSize
        
        //non auto trackables
        self.cart = cart
        self.productDetailView = productDetailView
        self.productThumbnailView = productThumbnailView
        self.pageView = pageView
        self.metadata = metadata
        self.customVariables = customVariables
        self.purchase = purchase
        self.pageEvents = pageEvents
    }
    
    func toString () -> Future<String, Error> {
        let promise = Promise<String, Error>()
        var str = ""
        
        let zip1  = Future.zip(
            cart!(),
            pageView!()
        )
        
        let zip2  = Future.zip(
            productDetailView!(),
            productThumbnailView!(),
            metadata!(),
            customVariables!(),
            purchase!()
        )
        
        
        Future.zip(
            zip1,
            zip2
        ).on(success: { (arg) in
            let ((cart, pageView), (productDetailView, productThumbnailView, metadata, customVariables, purchase)) = arg
            
            let cart_str = try! JSONEncoder().encode(cart)
            let productDetailView_str = try! JSONEncoder().encode(productDetailView)
            let productThumbnailView_str = try! JSONEncoder().encode(productThumbnailView)
            let purchase_str = try! JSONEncoder().encode(purchase)
            let pageView_str = try! JSONEncoder().encode(pageView)
            let metadata_str = try! JSONEncoder().encode(metadata)
            let customVariables_str = try! JSONEncoder().encode(customVariables)
            
            var array = [cart_str, productDetailView_str,
                         productThumbnailView_str,
                         purchase_str, pageView_str,
                         metadata_str,
                         customVariables_str
            ]
            
            if let val = self.userAgent {
                let str = try! JSONEncoder().encode(val)
                array.append(str)
            }
            if let val = self.coordinates {
                let str = try! JSONEncoder().encode(val)
                array.append(str)
            }
            if let val = self.screenSize {
                let str = try! JSONEncoder().encode(val)
                array.append(str)
            }
            if let val = self.ipAddress {
                let str = try! JSONEncoder().encode(val)
                array.append(str)
            }
            
            for item in array {
                str += item.toString
            }
            promise.succeed(value: str)
        }, failure: { er in
            Log.error("Error - \(er.localizedDescription)")
            promise.fail(error: er)
        }) {
            Log.debug("Completed")
        }
        
        return promise.future
    }
    
}


