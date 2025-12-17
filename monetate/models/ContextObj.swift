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
    case missingPageView
    case missingProductThumbnail(index: Int)
    case missingProductDetails(index: Int)
    case missingPurchaseData(index: Int)
    case missingCartData(index: Int)
    case missingSingleCartData
    case missingImpressionData
    case missingRecImpressiondata
    case missingRecClickData
   
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
            
        case .missingPageView:
            return "Execution Interuppted as data is missing, Please make sure if required PageDetails are is added and then try again"
            
        case .missingProductThumbnail(let index):
            if index == -1 {
                return "Execution Interuppted as data is missing, Please make sure if required ProductThumbnail's data is added and then try again"
            }
            return "Execution Interuppted as data is missing, Please make sure if ProductThumbnail at index \(index)  is valid then try again"
            
        case .missingProductDetails(let index):
            if (index == -1) {
                return "Execution Interuppted as data is missing, Please make sure if required ProductDetails data are added and then try again"
            }
            return "Execution Interuppted as data is missing, Please make sure if ProductDetail at index \(index) is valid then try again"
            
        case .missingPurchaseData(let index):
            if (index == -1) {
                return "Execution Interuppted as data is missing, Please make sure if required Purchase's data is added and then try again"
            }
            return "Execution Interuppted as data is missing, Please make sure if Purchase's data at index \(index) is valid then try again"
            
        case .missingCartData(index: let index):
            if (index == -1) {
                return "Execution Interuppted as data is missing, Please make sure if required Cart's data is added and then try again"
            }
            return "Execution Interuppted as data is missing, Please make sure if Cart's data at index \(index) is valid then try again"
            
        case .missingSingleCartData:
            return "Execution Interuppted as data is missing, Please make sure if required CartLine's data is added and then try again"
            
        case .missingImpressionData:
            return "Execution Interuppted as data is missing, Please make sure if required Impression's data is added and then try again"
            
        case .missingRecImpressiondata:
            return "Execution Interuppted as data is missing, Please make sure if required RecImpression's data is added and then try again"
            
        case .missingRecClickData:
            return "Execution Interuppted as data is missing, Please make sure if required RecClick's data is added and then try again"
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
    
    public func getIpAddress() -> IPAddress? {
        return IPAddress(ipAddress: self.ipAddress)
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
    
    public func getUserAgentData() -> UserAgent? {
        return UserAgent(userAgent: self.userAgentData)
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
    
    public func getScreenSizeData () -> ScreenSize? {
        return ScreenSize(height: screenHeight, width: screenWidth)
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
    
    public func getCustomVariablesData() -> CustomVariables? {
        return CustomVariables(customVariables: self.customVariables)
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
    
    public func getCoordinatesData() -> Coordinates? {
        return Coordinates(latitude: latitude, longitude: longitude)
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
    
    public func getMetaData() -> Metadata? {
        guard let languageString = language?.language else {
            return nil
        }
        return Metadata(language: languageString)
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
    
    public func getPageEventsData() -> PageEvents? {
        guard let pageEventsArray = self.pageEvents else {
            return nil
        }
        return PageEvents(pageEvents: Set(pageEventsArray))
    }
    
    // MARK: - Page View
    public func addPageDetails(pageType: String?, url: String?, categories: [String]?, breadcrumbs: [String]?, path: String?) {
        do {
            try validatePageViewData(pageType: pageType, url: url, categories: categories, breadcrumbs: breadcrumbs, path: path)
            self.pageType = pageType
            self.url = url
            self.categories = categories
            self.breadcrumbs = breadcrumbs
            self.path = path
        } catch {
            Log.error(error.localizedDescription)
        }
    }
    
    public func getPageDetails() -> PageView? {
        return PageView(pageType: pageType, path: path, url: url, categories: categories, breadcrumbs: breadcrumbs)
    }
    
    // MARK: - Product Thumbnails
    public func addProductThumbnailsData(_ products: [String]?) {
        do {
            try validateProductThumbnailData(productsData: products)
            self.productsThumbnail = products
        } catch {
            Log.error(error.localizedDescription)
        }
    }
    
    public func getProductThumbnailsData() -> ProductThumbnailView? {
        guard let productThumbnailArray = self.productsThumbnail else {
            return nil
        }
        return ProductThumbnailView(products: Set(productThumbnailArray))
    }
    
    // MARK: - Product Details
    public func addProductDetails(_ productsData: [Product]?) {
        do {
            try validateProductDetails(productsData)
            self.productsData = productsData
        } catch {
            Log.error(error.localizedDescription)
        }
    }
    
    public func getProductDetails() -> ProductDetailView? {
        return ProductDetailView(products: productsData)
    }
    
    // MARK: - Purchase
    public func addPurchaseData(purchaseId: String?, purchaseLineData: [PurchaseLine]?) {
        do {
            try validatePurchaseData(purchaseId: purchaseId, purchaseLines: purchaseLineData)
            self.purchaseId = purchaseId
            self.purchaseData = purchaseLineData
        } catch {
            Log.error(error.localizedDescription)
        }
    }
    
    public func getPurchaseData() -> Purchase? {
        return Purchase(account: "", domain: "", instance: "", purchaseId: purchaseId, purchaseLines: purchaseData)
    }
    
    // MARK: - Cart
    public func addAllCartData(_ cartLines: [CartLine]?) {
        do {
            try validateCartData(cartLines)
            if self.cartLines == nil {
                self.cartLines = cartLines
            } else if let newLines = cartLines {
                self.cartLines?.append(contentsOf: newLines)
            }
        } catch {
            Log.error(error.localizedDescription)
        }
    }
    
    public func getAllCartData() -> [CartLine]? {
        return cartLines
    }
    
    // MARK: - Single Cart
    public func addSingleCartData(_ cartLine: CartLine?) {
        do {
            try validateSingleCartData(cartLine)
            if let line = cartLine {
                if cartLines == nil {
                    cartLines = []
                }
                cartLines?.append(line)
                singleCartData = line
            }
        } catch {
            Log.error(error.localizedDescription)
        }
    }
    
    public func getSingleCartData() -> CartLine? {
        return singleCartData
    }
    
    public func removeSingleCartData(_ cartLine: CartLine) {
        guard let cartLines = cartLines, !cartLines.isEmpty else {
            Log.warning("Cart is empty, cannot remove item.")
            return
        }
        
        if let index = cartLines.firstIndex(where: { $0 == cartLine }) {
            self.cartLines?.remove(at: index)
        } else {
            Log.warning("Item not found in cart, cannot remove.")
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
    
    // Validate PageView
    func validatePageViewData(pageType: String?, url: String?, categories: [String]?, breadcrumbs: [String]?, path: String?) throws {
        guard let pageType = pageType, !pageType.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw ValidationError.missingPageView
        }
    }
    
    // Validate Productthumbnail data
    func validateProductThumbnailData(productsData: [String]?) throws {
        guard let products = productsData, !products.isEmpty else {
            throw ValidationError.missingProductThumbnail(index: -1)
        }

        for (index, product) in products.enumerated() {
            if product.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                throw ValidationError.missingProductThumbnail(index: index)
            }
        }
    }
    
    // Validate Product details
    func validateProductDetails(_ productsData: [Product]?) throws {
        guard let products = productsData, !products.isEmpty else {
            throw ValidationError.missingProductDetails(index: -1)
        }

        for (index, product) in products.enumerated() {
            if product.productId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                throw ValidationError.missingProductDetails(index: index)
            }
        }
    }
    
    //validate Purchase data
    func validatePurchaseData(purchaseId: String?, purchaseLines: [PurchaseLine]?) throws {
        guard let purchaseId = purchaseId, !purchaseId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, let purchaseLines = purchaseLines, !purchaseLines.isEmpty else {
            throw ValidationError.missingPurchaseData(index: -1)
        }
        for (index, purchaseLine) in purchaseLines.enumerated() {
            if purchaseLine.sku.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                purchaseLine.pid.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                purchaseLine.quantity <= 0 ||
                purchaseLine.currency.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                purchaseLine.value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty  {
                throw ValidationError.missingPurchaseData(index: index)
            }
        }
    }
    
    //validate Cart data
    func validateCartData(_ cartLinesData: [CartLine]?) throws {
        guard let cartLines = cartLinesData, !cartLines.isEmpty else {
            throw ValidationError.missingCartData(index: -1)
        }

        for (index, cartLine) in cartLines.enumerated() {
            if cartLine.sku.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                cartLine.pid.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                cartLine.quantity <= 0 ||
                cartLine.currency.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
                cartLine.value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                throw ValidationError.missingCartData(index: index)
            }
        }
    }
    
    //validate Single cart data
    func validateSingleCartData(_ cartLine: CartLine?) throws {
        guard
            let cartLine = cartLine,
            !cartLine.sku.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
            !cartLine.pid.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
            cartLine.quantity > 0,
            !cartLine.currency.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
            !cartLine.value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else {
            throw ValidationError.missingSingleCartData
        }
    }
}

/// getAction error handler
enum GetActionError: LocalizedError {
    case noActionFound
    case invalidResponse
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Execution Alert: Invalid response format from server."
        case .noActionFound:
            return "Execution Alert: No active actions found."
        }
    }
}


