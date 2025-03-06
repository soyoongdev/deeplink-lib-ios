//
//  TPDynamicLinks.swift
//  Runner
//
//  Created by soyoongdev on 4/2/25.
//

import Foundation
import UIKit

@objcMembers public class DLDynamicLinks: NSObject {
    
    public static let shared = DLDynamicLinks()
    
    private var urlScheme: String = ""
    
    // MARK: - Custom domains
    
    override public init() {
        super.init()
        self.checkForCustomDomainEntriesInInfoPlist()
    }
    
    public func configureDynamicLinks() {
        if let urlSchemesFromInfoPlist = Bundle.main.infoDictionary?["CFBundleURLTypes"] as? [[String: Any]] {
            for schemeDetails in urlSchemesFromInfoPlist {
                if let arrayOfSchemes = schemeDetails["CFBundleURLSchemes"] as? [String] {
                    DLConfig.appSchemes = arrayOfSchemes
                }
            }
        }
        self.urlScheme = Bundle.main.bundleIdentifier ?? ""
    }
    
    public func createShortURL(from parameters: [String: Any], completion: @escaping (Data?, Error?) -> Void) {
        // Sử dụng hàm generateShortURLFakeResponse nếu chưa có api
        DLDynamicLinkNetworking.shared.createShortURLFakeResponse(from: parameters, completion: completion)
        // Sử dụng hàm generateShortURLFakeResponse nếu chưa có api
        //    DLDynamicLinkNetworking.shared.createShortURL(from: parameters, completion: completion)
    }
    
    // MARK: - Xử lý Custom URL Scheme
    public func dynamicLinkFromCustomSchemeURL(_ url: URL?) -> DLDynamicLink? {
        guard let url = url else {
            DLLogger.log("❌ URL is nil.", level: .error)
            return nil
        }
        self.checkForDeepLinkAfterLaunch(url)
        // Lấy query từ URL
        let query = url.query ?? ""
        let queryDictionary = DLUtilities.shared.dictionaryFromQuery(query) as NSDictionary
        if query.isEmpty {
            DLLogger.log("⚠️ No query parameters found in URL.", level: .warning)
        } else {
            DLLogger.log("🔗 Extracted Query Parameters: \(queryDictionary)", level: .info)
        }
        // Tạo DLDynamicLink với dữ liệu đã trích xuất
        let dynamicLink = DLDynamicLink(url: url, path: url.path, host: url.host, parameters: queryDictionary)
        DLLogger.log("✅ Successfully Created Dynamic Link: \(dynamicLink.description)", level: .info)
        return dynamicLink
        
    }
    
    // MARK: - Xử lý Universal Link
    public func handleUniversalLink(_ url: URL?, completion: @escaping DLDynamicLinkUniversalLinkHandler) -> Bool {
        guard let url = url else {
            DLLogger.log("❌ URL is nil.", level: .error)
            return false
        }
        self.checkForDeepLinkAfterLaunch(url)
        if self.matchesShortLinkFormat(url) {
            self.resolveShortLink(url) { resolvedURL, error in
                guard let resolvedURL = resolvedURL else {
                    completion(nil, error)
                    return
                }
                let dynamicLink = self.dynamicLinkFromCustomSchemeURL(resolvedURL)
                DispatchQueue.main.async {
                    completion(dynamicLink, error)
                }
            }
            return true
        } else {
            let query = url.query ?? ""
            let dictionaryFromQuery = DLUtilities.shared.dictionaryFromQuery(query)
            let canHandleUniversalLink = self.canParseUniversalLinkURL(url) && !query.isEmpty && dictionaryFromQuery[kDLParameterLink] != nil
            return canHandleUniversalLink
        }
    }
    
    private func matchesShortLinkFormat(_ url: URL) -> Bool {
        return DLUtilities.shared.matchesShortLinkFormat(url)
    }
    
    private func resolveShortLink(_ url: URL, completion: @escaping DLDynamicLinkResolverHandler) {
        DLDynamicLinkNetworking.shared.resolveShortLink(url: url, completion: completion)
    }
    
    private func canParseUniversalLinkURL(_ url: URL) -> Bool {
        return DLUtilities.shared.canParseUniversalLinkURL(url)
    }
    
    private func canParseCustomSchemeURL(_ url: URL) -> Bool {
        guard let scheme = url.scheme else { return false }
        let bundleIdentifier = Bundle.main.bundleIdentifier
        DLLogger.log("Scheme: \(scheme.lowercased()) - Identifier: \(bundleIdentifier ?? "")", level: .info)
        return scheme.lowercased() == bundleIdentifier?.lowercased() || scheme.lowercased() == self.urlScheme.lowercased()
    }
    
    // Get custom domains entry in PLIST file.
    private func checkForCustomDomainEntriesInInfoPlist() {
        // Check to see if DLDynamicLinksCustomDomains array is present.
        if let infoDictionary = Bundle.main.infoDictionary {
            if let customDomains = infoDictionary[kInfoPlistCustomDomainsKey] as? [String] {
                DLLogger.log("Bundle.main.infoDictionary: \(customDomains)", level: .info)
                DLUtilities.shared.addToAllowListForCustomDomainsArray(customDomains)
            }
        }
    }
    
    private func checkForDeepLinkAfterLaunch(_ url: URL) {
        DLUtilities.shared.checkForDeepLinkAfterLaunch(url)
    }
}
