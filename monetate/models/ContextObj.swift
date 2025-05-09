//
//  ContextObj.swift
//  monetate-ios-sdk
//
//  Created by Hasanul Benna(UST,IN) on 24/04/25.
//  Copyright © 2025 Monetate. All rights reserved.
//

import Foundation

enum ValidationError: LocalizedError {
    case missingIpAddress
    case missingUserAgent
    case missingScreenSize
    case missingCustomVariable(index: Int)
    case missingCoordinates
    case missingMetaData
    case missingPageEvent(index: Int)

   
    var errorDescription: String? {
        switch self {
            
        case .missingIpAddress:
            return "Execution Interrupted as data is missing, Please make sure if IpAddress data is added and then try again"
            
        case .missingUserAgent:
            return "Execution Interrupted as data is missing, Please make sure if required UserAgent's data is added and then try again"
            
        case .missingScreenSize:
            return "Execution Interrupted as data is missing, Please make sure if required ScreenSize's data is added and then try again"
            
        case .missingCustomVariable(let index):
            if index == -1 {
                return "Execution Interrupted as data is missing, Please make sure if required CustomVariable's data is added and then try again"
            }
            return "Execution Interrupted as data is missing, Please make sure if CustomVariable at index \(index) is valid then try again"
            
        case .missingCoordinates:
            return "Execution Interrupted as data is missing, Please make sure if required Coordinates's data is added and then try again"
            
        case .missingMetaData:
            return "Execution Interrupted as data is missing, Please make sure if required MetaData's data is added and then try again"
            
        case .missingPageEvent(let index):
            if index == -1 {
                return "Execution Interrupted as data is missing, Please make sure if required PageEvents data is added and then try again"
            }
            return "Execution Interrupted as data is missing, Please make sure if Page event at index \(index) is valid then try again."
        }
    }

}

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
    public func addIpAddress(_ ipAddress: String?) {
        do {
            try validateIpData(ipData: ipAddress)
            self.ipAddress = ipAddress
        } catch {
            Log.error(error.localizedDescription)
        }
    }
    
    public func getIpAddress() -> IPAddress {
        return IPAddress(ipAddress: self.ipAddress ?? "")
    }
    
    // MARK: - User Agent
    public func addUserAgentData(_ data: String?) {
        do {
            try validateUserAgentData(userAgent: data)
            self.userAgentData = data
        } catch {
            Log.error(error.localizedDescription)
        }
    }
    
    public func getUserAgentData() -> UserAgent {
        return UserAgent(userAgent: self.userAgentData ?? "")
    }
    
    // MARK: - Screen Size
    public func addScreenSizeData(screenHeight: Int?, screenWidth: Int?) {
        do {
            try validateScreenSizeData(heightData: screenHeight, widthData: screenWidth)
            self.screenHeight = screenHeight
            self.screenWidth = screenWidth
        } catch {
            Log.error(error.localizedDescription)
        }
    }
    
    public func getScreenSizeData () -> ScreenSize {
        return ScreenSize(height: screenHeight ?? 0, width: screenWidth ?? 0)
    }
    
    // MARK: - Custom Variables
    public func addCustomVariablesData(_ customVariables: [CustomVariablesModel]?) {
        do {
            try validateCustomVariables(customVariables)
            self.customVariables = customVariables
        } catch {
            Log.error(error.localizedDescription)
        }
    }
    
    public func getCustomVariablesData() -> CustomVariables {
        return CustomVariables(customVariables: self.customVariables ?? [])
    }
    
    // MARK: - Coordinates
    public func addCoordinatesData(latitude: String?, longitude: String?) {
        do {
            try validateCoordinatesData(latitudeData: latitude, longitudeData: longitude)
            self.latitude = latitude
            self.longitude = longitude
        } catch {
            Log.error(error.localizedDescription)
        }
    }
    
    public func getCoordinatesData() -> Coordinates {
        return Coordinates(latitude: latitude ?? "", longitude: longitude ?? "")
    }
    
    // MARK: - Language / MetaData
    public func addMetaData(language: Language?) {
        do {
            try validateMetaData(language)
            self.language = language
        } catch {
            Log.error(error.localizedDescription)
        }
    }
    
    public func getMetaData() -> Metadata {
        return Metadata(metadata: .string(language?.language ?? ""))
    }
    
    // MARK: - Page Events
    public func addPageEventsData(_ pageEventsData: [String]?) {
        do {
            try validatePageEventsData(pageEventsData)
            self.pageEvents = pageEventsData
        } catch {
            Log.error(error.localizedDescription)
        }
    }
    
    public func getPageEventsData() -> PageEvents {
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

//MARK: - Validations
extension ContextObj {
    // Validate IP address
    func validateIpData(ipData: String?) throws {
        guard let ip = ipData?.trimmingCharacters(in: .whitespacesAndNewlines), !ip.isEmpty else {
            throw ValidationError.missingIpAddress
        }
    }

    // Validate User Agent
    func validateUserAgentData(userAgent: String?) throws {
        guard let agent = userAgent?.trimmingCharacters(in: .whitespacesAndNewlines), !agent.isEmpty else {
            throw ValidationError.missingUserAgent
        }
    }

    // Validate Custom Variable
    func validateCustomVariables(_ customVariables: [CustomVariablesModel]?) throws {
        guard let customVariables = customVariables, !customVariables.isEmpty else {
            throw ValidationError.missingCustomVariable(index: -1)
        }

        for (index, variable) in customVariables.enumerated() {
            if variable.variable.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                variable.value.isEmpty {
                throw ValidationError.missingCustomVariable(index: index)
            }
        }
    }

    // Validate Screen Size
    func validateScreenSizeData(heightData: Int?, widthData: Int?) throws {
        if heightData == nil || widthData == nil {
            throw ValidationError.missingScreenSize
        }
    }

    // Validate Coordinates
    func validateCoordinatesData(latitudeData: String?, longitudeData: String?) throws {
        guard let latitude = latitudeData?.trimmingCharacters(in: .whitespacesAndNewlines), !latitude.isEmpty,
              let longitude = longitudeData?.trimmingCharacters(in: .whitespacesAndNewlines), !longitude.isEmpty
        else {
            throw ValidationError.missingCoordinates
        }
    }

    // Validate Meta data
    func validateMetaData(_ language: Language?) throws {
        guard let lang = language?.language.trimmingCharacters(in: .whitespacesAndNewlines), !lang.isEmpty else {
            throw ValidationError.missingMetaData
        }
    }

    // Validate Page Events
    func validatePageEventsData(_ pageEvents: [String]?) throws {
        guard let events = pageEvents, !events.isEmpty else {
            throw ValidationError.missingPageEvent(index: -1)
        }

        for (index, event) in events.enumerated() {
            if event.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                throw ValidationError.missingPageEvent(index: index)
            }
        }
    }
}

