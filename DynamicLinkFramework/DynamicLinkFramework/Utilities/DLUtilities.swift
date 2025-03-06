//
//  DLUtilities.swift
//  mocha
//
//  Created by NGUYEN HAU on 14/2/25.
//  Copyright © 2025 TTND. All rights reserved.
//

import Foundation

public let kDLParameterLink = "link"
public let kDLParameterCampaign = "utm_campaign"
public let kDLParameterContent = "utm_content"
public let kDLParameterMedium = "utm_medium"
public let kDLParameterSource = "utm_source"
public let kDLParameterTerm = "utm_term"

@objcMembers public class DLUtilities: NSObject {
    
    public static let shared = DLUtilities()
    
    public static var DLCustomDomains: Set<URL> = []
    
    public func urlQueryStringFromDictionary(_ dictionary: [String: String]) -> String {
        var parameters = ""
        let queryCharacterSet = CharacterSet.alphanumerics
        let parameterFormatString = "%@%@=%@"
        
        for (index, (key, value)) in dictionary.enumerated() {
            let delimiter = index == 0 ? "?" : "&"
            let encodedValue = value.addingPercentEncoding(withAllowedCharacters: queryCharacterSet) ?? ""
            let parameter = String(format: parameterFormatString, delimiter, key, encodedValue)
            parameters.append(parameter)
        }
        
        return parameters
    }
    
    public func dictionaryFromQuery(_ queryString: String?) -> [String: String] {
        guard let queryString = queryString else {
            return [:]
        }
        var queryDictionary: [String: String] = [:]
        let keyValuePairs = queryString.components(separatedBy: "&")
        for pair in keyValuePairs {
            let keyValuePair = pair.components(separatedBy: "=")
            if keyValuePair.count == 2 {
                let key = keyValuePair[0]
                let value = keyValuePair[1].removingPercentEncoding ?? ""
                queryDictionary[key] = value
            }
        }
        return queryDictionary as [String: String]
    }
    
    
    /// Hàm này dùng để kiểm tra xem một URL có thuộc một trong các custom domain hợp lệ hay không.
    /// Ngoài ra, nó còn kiểm tra xem URL có chứa đường dẫn hợp lệ hoặc tham số query “link” trỏ đến một URL khác.
    /// Ví dụ:
    /// Hợp lệ: "https://deeplink.algamestudio.com/game?id=2" || "https://sport.algamestudio.com/detail?id=2" || "https://deeplink.algamestudio.com/?link=https://example.com/page"
    /// Không hợp lệ: "https://randomsite.com/game?id=2" (Không thuộc danh sách DLCustomDomains) || "https://deeplink.algamestudio.com/invalid" (Không có đường dẫn hợp lệ hoặc query "link")
    /// - Parameter url: Deeplink (Vd: https://deeplink.algamestudio.com)
    /// - Returns: True nếu hợp lệ hoặc false nếu không hợp lệ
    public func isURLForAllowedCustomDomain(_ url: URL?) -> Bool {
        guard let url = url else {
            return false
        }
        for allowedCustomDomain in Self.DLCustomDomains {
            guard url.absoluteString.hasPrefix(allowedCustomDomain.absoluteString) else {
                continue
            }
            let urlWithoutPrefix = String(url.absoluteString.dropFirst(allowedCustomDomain.absoluteString.count))
            guard urlWithoutPrefix.hasPrefix("/") || urlWithoutPrefix.hasPrefix("?") else {
                continue
            }
            guard let components = URLComponents(string: urlWithoutPrefix) else {
                continue
            }
            if components.path.count > 1 {
                return true
            }
            if let queryItems = components.queryItems, queryItems.contains(where: {
                $0.name.caseInsensitiveCompare("link") == .orderedSame &&
                ($0.value?.hasPrefix("http://") == true || $0.value?.hasPrefix("https://") == true)
            }) {
                return true
            }
        }
        return false
    }
    
    /* We are validating following domains in proper format.
     * .algamestudio.com
     */
    public func isValidDLWithDomain(_ url: URL?) -> Bool {
        guard let url = url, let host = url.host else {
            return false
        }
        if host.contains(".algamestudio.com") {
            // Biểu thức chính quy kiểm tra domain hợp lệ
            let regex = #"^https?:\/\/[a-zA-Z0-9.-]+(\/[a-zA-Z0-9-_\/]*)?(\?[a-zA-Z0-9_=&%-]*)?$"#
            if url.absoluteString.range(of: regex, options: .regularExpression) != nil {
                return true
            }
        }
        return false
    }
    
    /*
     DL can be parsed if it :
     1. Has http(s)://goo.gl/app* or http(s)://page.link/app* format
     2. OR http(s)://$DomainPrefix.page.link or http(s)://$DomainPrefix.app.goo.gl domain with specific
     format
     3. OR the domain is a listed custom domain
     */
    public func canParseUniversalLinkURL(_ url: URL?) -> Bool {
        guard let url = url, let host = url.host else {
            return false
        }
        // Danh sách các domain hợp lệ cho Universal Links
        let allowedHosts = DLConfig.allowedHosts
        
        // Kiểm tra nếu URL thuộc một trong các host hợp lệ
        let isValidHost = allowedHosts.contains { allowedHost in
            host == allowedHost || host.hasSuffix(allowedHost)
        }
        // Kiểm tra xem path có hợp lệ không (phải có nội dung sau "/")
        let isValidPath = !url.path.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        
        if isValidHost && isValidPath {
            return true
        }
        // Kiểm tra URL theo các phương thức kiểm tra bổ sung
        let isValidCustomDomain = self.isValidDLWithDomain(url) || self.isURLForAllowedCustomDomain(url)
        if isValidCustomDomain {
            return true
        }
        return false
    }
    
    public func matchesShortLinkFormat(_ url: URL) -> Bool {
        // Short Durable Link URLs phải có path hoặc thuộc một custom domain hợp lệ.
        let hasPathOrCustomDomain = !url.path.isEmpty || self.isURLForAllowedCustomDomain(url)
        // Kiểm tra nếu URL có thể được parse như một Universal Link hợp lệ.
        let canParse = self.canParseUniversalLinkURL(url)
        // Path không được bắt đầu bằng "/link/dismiss".
        let isDismiss = url.path.lowercased().hasPrefix("/link/dismiss")
        // Kiểm tra nếu path chỉ chứa một phần tử sau domain (VD: "/xyz")
        let regexPattern = #"^\/[^\/]+$"#
        let matchesShortLinkFormat = url.path.range(of: regexPattern, options: .regularExpression) != nil
        let result = hasPathOrCustomDomain && !isDismiss && canParse && matchesShortLinkFormat
        return result
    }
    
    public func addToAllowListForCustomDomainsArray(_ customDomains: [String]) {
        // Duplicates will be weeded out when converting to a set.
        var validCustomDomains = [URL]()
        
        for customDomainEntry in customDomains {
            // We remove trailing slashes in the path if present.
            let domainEntry = customDomainEntry.hasSuffix("/") ?
            String(customDomainEntry.dropLast()) : customDomainEntry
            
            if let customDomainURL = URL(string: domainEntry), customDomainURL.scheme != nil {
                validCustomDomains.append(customDomainURL)
            }
        }
        
        // Duplicates will be weeded out when converting to a set.
        Self.DLCustomDomains = Set(validCustomDomains)
    }
    
    /// Hàm kiểm tra first open hay reopen (điều kiện reopen là khi app được mở lại sau khi đã được đóng hoàn). Lưu key là urlString và số lần mở deeplink vào UserDefaults.
    public func checkForDeepLinkAfterLaunch(_ url: URL) {
        // Lấy danh sách deeplink đã mở từ UserDefaults
        var listDeepLinks = (DLUserDefaultHelper.shared.getDictionary(forKey: kDLReadDeepLinkAfterLaunchApp) as? [String: Int]) ?? [:]
        
        // Kiểm tra xem deeplink này đã từng được mở chưa
        let previousCount = listDeepLinks[url.absoluteString] ?? 0
        let isFirstOpen = (previousCount == 0)
        
        // Kiểm tra xem app có bị đóng hoàn toàn trước khi mở lại deeplink không
        let wasTerminated = DLUserDefaultHelper.shared.getBool(forKey: kDLAppWasTerminated)
        let isReopen = wasTerminated && !isFirstOpen
        
        // Cập nhật số lần mở deeplink
        let newCount = previousCount + 1
        listDeepLinks[url.absoluteString] = newCount
        
        // Đặt trạng thái app không bị đóng hoàn toàn nữa
        DLUserDefaultHelper.shared.setBool(false, forKey: kDLAppWasTerminated)
        
        // Lưu danh sách deeplink đã mở vào UserDefaults
        DLUserDefaultHelper.shared.setDictionary(listDeepLinks as NSDictionary, forKey: kDLReadDeepLinkAfterLaunchApp)
        
        // Log thông tin
        if isFirstOpen {
            DLLogger.log("🚀 First time opening deeplink: \(url.absoluteString)", level: .info)
        } else if isReopen {
            DLLogger.log("🔄 Reopened deeplink after app was terminated: \(url.absoluteString)", level: .info)
        } else {
            DLLogger.log("📊 Deeplink opened again in same session: \(url.absoluteString) - \(newCount) times", level: .info)
        }
        
        // Gửi API cập nhật thống kê lên server
        DLDynamicLinkNetworking.shared.updateDeepLinkAnalytics(url: url, count: newCount, firstOpen: isFirstOpen, reopen: isReopen) { (data, error) in
            if let error = error {
                DLLogger.log("❌ Failed to update deeplink stats: \(error.localizedDescription)", level: .error)
                return
            }
            guard let data = data else {
                DLLogger.log("❌ Data is nil", level: .error)
                return
            }
            DLLogger.log("✅ Successfully updated deeplink stats: \(data.toJsonString())", level: .info)
        }
    }
}
