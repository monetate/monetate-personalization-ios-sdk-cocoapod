//
//  ContextObj.swift
//  monetate-ios-sdk
//
//  Created by Hasanul Benna(UST,IN) on 24/04/25.
//  Copyright © 2025 Monetate. All rights reserved.
//

import Foundation

// MARK: - New Context class
public class ContextObj {
    
    private var ipAddress: String?
    
    private var userAgentData: String?
    
    private var screenHeight: Int?
    private var screenWidth: Int?
    
    private var customVariables: [CustomVariablesModel]?
    
    private var latitude: String?
    private var longitude: String?
    
    private var language: Language?
    
    private var pageEvents: [String]?
    
    private var pageType: String?
    private var url: String?
    private var categories: [String]?
    private var breadcrumbs: [String]?
    private var path: String?
    
    private var productsThumbnail: [String]?
    
    private var productsData: [Product]?
    
    private var purchaseId: String?
    private var purchaseData: [PurchaseLine]?
    
    private var cartLines: [CartLine]?
    private var singleCartData: CartLine?
    
    public init() {
        
    }
    
    // MARK: - IP Address
    public func addIpAddress(_ ipAddress: String?) throws {
        self.ipAddress = ipAddress
    }
    
    public func getIpAddress() -> IPAddress? {
        return IPAddress(ipAddress: self.ipAddress ?? "")
    }
    
    // MARK: - User Agent
    public func addUserAgentData(_ data: String?) throws {
        self.userAgentData = data
    }
    
    public func getUserAgentData() -> UserAgent? {
        return UserAgent(userAgent: self.userAgentData ?? "")
    }
    
    // MARK: - Screen Size
    public func addScreenSizeData(screenHeight: Int?, screenWidth: Int?) throws {
        self.screenHeight = screenHeight
        self.screenWidth = screenWidth
    }
    
    public func getScreenSizeData () -> ScreenSize? {
        return ScreenSize(height: screenHeight ?? 0, width: screenWidth ?? 0)
    }
    
    // MARK: - Custom Variables
    public func addCustomVariablesData(_ customVariables: [CustomVariablesModel]?) throws {
        self.customVariables = customVariables
    }
    
    public func getCustomVariablesData() -> CustomVariables? {
        return CustomVariables(customVariables: self.customVariables ?? [])
    }
    
    // MARK: - Coordinates
    public func addCoordinatesData(latitude: String?, longitude: String?) throws {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    public func getCoordinatesData() -> Coordinates? {
        return Coordinates(latitude: latitude ?? "", longitude: longitude ?? "")
    }
    
    // MARK: - Language / MetaData
    public func addMetaData(language: Language?) throws {
        self.language = language
    }
    
    public func getMetaData() -> Metadata {
        return Metadata(metadata: .string(language?.language ?? ""))
    }
    
    // MARK: - Page Events
    public func addPageEventsData(_ pageEventsData: [String]?) throws {
        self.pageEvents = pageEventsData
    }
    
    public func getPageEventsData() -> PageEvents? {
        return PageEvents(pageEvents: Set(self.pageEvents ?? []))
    }
    
    // MARK: - Page View
    public func addPageDetails(pageType: String?, url: String?, categories: [String]?, breadcrumbs: [String]?, path: String?) throws {
        self.pageType = pageType
        self.url = url
        self.categories = categories
        self.breadcrumbs = breadcrumbs
        self.path = path
    }
    
    public func getPageViewData() -> PageView? {
        return PageView(pageType: pageType ?? "", path: path, url: url, categories: categories, breadcrumbs: breadcrumbs)
    }
    
    // MARK: - Product Thumbnails
    public func addProductThumbnails(_ products: [String]?) throws {
        self.productsThumbnail = products
    }
    
    public func getProductThumbnailData() -> ProductThumbnailView? {
        return ProductThumbnailView(products: Set(self.productsThumbnail ?? []))
    }
    
    // MARK: - Product Details
    public func addProductDetails(_ productsData: [Product]?) throws {
        self.productsData = productsData
    }
    
    public func getProductDetailViewData() -> ProductDetailView? {
        return ProductDetailView(products: productsData)
    }
    
    // MARK: - Purchase
    public func addAllPurchaseData(purchaseId: String?, purchaseLineData: [PurchaseLine]?) throws {
        self.purchaseId = purchaseId
        self.purchaseData = purchaseLineData
    }
    
    public func getPurchaseData() -> Purchase? {
        return Purchase(account: "", domain: "", instance: "", purchaseId: purchaseId ?? "", purchaseLines: purchaseData)
    }
    
    // MARK: - Cart
    public func addAllCartData(_ cartLines: [CartLine]?) throws {
        self.cartLines = cartLines
    }
    
    public func getAllCartData() -> [CartLine] {
        return cartLines ?? []
    }
    
    public func addSingleCartData(_ cartLine: CartLine?) throws {
        if let line = cartLine {
            cartLines?.append(line)
            singleCartData = line
        }
    }
    
    public func getAddToCartData() -> CartLine? {
        return singleCartData
    }
    
    public func removeSingleCartLine(_ cartLine: CartLine) {
        if let index = cartLines?.firstIndex(where: { $0.sku == cartLine.sku && $0.pid == cartLine.pid }) {
            cartLines?.remove(at: index)
        } else {
            Log.warning("Cart is already empty, cannot remove data")
        }
    }
    
    
    public func clearAllCartData() {
        if let cartLine = self.cartLines, !cartLine.isEmpty {
            self.cartLines?.removeAll()
        } else {
            Log.warning("Cart is already empty, cannot remove data")
        }
    }
    
}
