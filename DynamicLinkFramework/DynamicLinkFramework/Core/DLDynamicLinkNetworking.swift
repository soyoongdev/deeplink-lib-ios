//
//  DLDynamicLinkNetworking.swift
//  SampleDynamicLink
//
//  Created by NGUYEN HAU on 17/2/25.
//

import Foundation

public let kResolvedLinkDeepLinkURLKey = "deepLink"
public let kResolvedLinkMinAppVersionKey = "iosMinAppVersion"
public let kAnalyticsDataSourceKey = "utmSource"
public let kAnalyticsDataMediumKey = "utmMedium"
public let kAnalyticsDataCampaignKey = "utmCampaign"
public let kAnalyticsDataTermKey = "utmTerm"
public let kAnalyticsDataContentKey = "utmContent"
public let kHeaderIosBundleIdentifier = "X-Ios-Bundle-Identifier"
public let kGenericErrorDomain = "deeplink.algamestudio.com"

@objc public enum DLShortURLType: Int {
    case unlimitedUse = 0
    case oneTimeUse = 1
};

@objc public class DLDynamicLinkNetworking: NSObject {
    
    public static let shared = DLDynamicLinkNetworking()
    
    @objc public func extractErrorForShortLink(url: URL, data: Data?, response: URLResponse?, error: Error?) -> Error? {
        if let error = error {
            return error
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            return NSError(domain: "GenericErrorDomain", code: 0, userInfo: ["message": "Response should be of type HTTPURLResponse."])
        }
        
        let statusCode = httpResponse.statusCode
        
        if (200...299).contains(statusCode) {
            return nil // Không có lỗi nếu HTTP status code hợp lệ
        }
        
        if let data = data {
            do {
                if let result = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let errorInfo = result["error"] as? [String: Any] {
                    return NSError(domain: "GenericErrorDomain", code: statusCode, userInfo: errorInfo)
                }
            } catch {
                // Nếu không thể parse JSON, trả về lỗi mặc định
            }
        }
        
        return NSError(domain: "GenericErrorDomain", code: 0, userInfo: [
            "message": "Failed to resolve link: \(url.absoluteString)"
        ])
    }
    
    // MARK: - Public Interface
    
    /// Hàm xử lý shortlink (phân giải shortlink)
    @objc public func resolveShortLink(url: URL?, completion: @escaping DLDynamicLinkResolverHandler) {
        guard let url = url else {
            DLLogger.log("❌ Không thể nhận lấy URL", level: .error)
            completion(nil, nil)
            return
        }
        
        completion(url, nil)
        
        //    let requestBody: [String: Any] = [
        //      "requestedLink": url.absoluteString,
        //      "bundle_id": Bundle.main.bundleIdentifier ?? "",
        //    ]
        //
        //    let resolveLinkCallback: (Data?, URLResponse?, Error?) -> Void = { data, response, error in
        //      var resolvedURL: URL? = nil
        //      let extractedError = self.extractErrorForShortLink(
        //        url: url, data: data, response: response, error: error
        //      )
        //
        //      if extractedError == nil, let data = data,
        //         let result = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
        //
        //        var invitationIDString: String? = nil
        //        if let invitationIDObject = result["invitationId"] {
        //          if let invitationIDDict = invitationIDObject as? [String: Any] {
        //            invitationIDString = invitationIDDict["id"] as? String
        //          } else if let invitationIDStr = invitationIDObject as? String {
        //            invitationIDString = invitationIDStr
        //          }
        //        }
        //
        //        let deepLinkString = result[kResolvedLinkDeepLinkURLKey] as? String
        //        let minAppVersion = result[kResolvedLinkMinAppVersionKey] as? String
        //        let utmSource = result[kAnalyticsDataSourceKey] as? String
        //        let utmMedium = result[kAnalyticsDataMediumKey] as? String
        //        let utmCampaign = result[kAnalyticsDataCampaignKey] as? String
        //        let utmContent = result[kAnalyticsDataContentKey] as? String
        //        let utmTerm = result[kAnalyticsDataTermKey] as? String
        //
        //        resolvedURL = DLUtilities.shared.deepLinkURLWithInviteID(
        //          inviteID: invitationIDString,
        //          deepLinkString: deepLinkString,
        //          utmSource: utmSource,
        //          utmMedium: utmMedium,
        //          utmCampaign: utmCampaign,
        //          utmContent: utmContent,
        //          utmTerm: utmTerm,
        //          isWeakLink: false,
        //          weakMatchEndpoint: nil,
        //          minAppVersion: minAppVersion,
        //          urlScheme: self.urlScheme,
        //          matchMessage: nil
        //        )
        //      }
        //      completion(resolvedURL, extractedError)
        //    }
        //
        //    let requestURLString = "kiOSReopenRestBaseUrl/reopenAttribution"
        //
        //    self.executeOnePlatformRequest(requestBody: requestBody, forURL: requestURLString, completionHandler: resolveLinkCallback)
    }
    
    @objc public func createShortURLFakeResponse(from parameters: [String: Any], completion: @escaping DLDynamicLinkResultHandler) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            let fakeResponse = """
                {
                  "success": true,
                  "short_url": "https://deeplink.algamestudio.com/abcxyz123"
                }
                """.data(using: .utf8)
            completion(fakeResponse, nil)
        }
    }
    
    @objc public func createShortURL(from parameters: [String: Any], completion: @escaping DLDynamicLinkResultHandler) {
        DLAPIClient.shared.post(endpoint: "/generation/shortlink", parameters: parameters, completion: completion)
    }
    
    /// Hàm cập nhật thống kê số lần mở link (first open or reopen deeplink statistics)
    @objc public func updateDeepLinkAnalytics(url: URL, count: Int, firstOpen: Bool, reopen: Bool, completion: @escaping DLDynamicLinkResultHandler) {
        // Dữ liệu cần gửi lên server
        let requestBody: [String: Any] = [
            "deeplink": url.absoluteString,
            "count": count,
            "firstOpen": firstOpen,
            "reopen": reopen,
            "timestamp": Date().timeIntervalSince1970
        ]
        
        DLLogger.log("❤️ `\(requestBody)`", level: .info)
        
        completion(requestBody.encodeDictionaryToJsonData(), nil)
        
        // Update api lên server (uncommand khi có api)
        //    DLAPIClient.shared.post(endpoint: "/analytics", parameters: requestBody, completion: completion)
    }
}
