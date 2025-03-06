//
//  DLDynamicLink.swift
//  Runner
//
//  Created by soyoongdev on 6/2/25.
//

import Foundation

// MARK: - Constants

// MARK: - Constants (đã để nguyên vì không ảnh hưởng)
public let kDLParameterDeepLinkIdentifier = "deepLinkIdentifier"
public let kDLParameterInviteId = "inviteId"
public let kDLParameterWeakMatchEndpoint = "weakMatchEndpoint"
public let kDLParameterMinimumAppVersion = "minimumAppVersion"
public let kDLParameterMatchType = "matchType"
public let kDLParameterMatchMessage = "matchMessage"

/// Class đại diện cho một Dynamic Link được xử lý từ Universal Link hoặc Custom Scheme URL
@objcMembers public class DLDynamicLink: NSObject {
    
    /// URL gốc của Dynamic Link
    public let originalURL: URL
    
    /// Host của URL (nếu có)
    public let host: String?
    
    /// Path của URL
    public let path: String
    
    /// Các tham số truy vấn của Dynamic Link (dùng NSDictionary để tương thích)
    public let parameters: NSDictionary

    /// Hàm khởi tạo dùng Objective-C (không dùng `init?`)
    public init(url: URL) {
        self.originalURL = url
        self.host = url.host
        self.path = url.path
        
        // Trích xuất query parameters, đổi sang NSDictionary
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
           let queryItems = components.queryItems {
            let params = NSMutableDictionary()
            for item in queryItems {
                if let value = item.value {
                    params[item.name] = value
                }
            }
            self.parameters = params
        } else {
            self.parameters = [:]
        }

        super.init() // Gọi `super.init()` sau khi gán giá trị

        // Log quá trình khởi tạo
        DLLogger.log("✅ Created DLDynamicLink - URL: \(url.absoluteString)", level: .info)
        DLLogger.log("🔗 Parameters: \(self.parameters)", level: .info)
    }

    /// Hàm khởi tạo từ các thành phần riêng biệt
    public init(url: URL, path: String, host: String?, parameters: NSDictionary) {
        self.originalURL = url
        self.path = path
        self.host = host
        self.parameters = parameters

        super.init()

        DLLogger.log("✅ Created DLDynamicLink (manual init) - URL: \(url.absoluteString)", level: .info)
        DLLogger.log("🔗 Parameters: \(parameters)", level: .info)
    }

    /// Trả về mô tả của đối tượng
    override public var description: String {
        return "DLDynamicLink(URL: \(originalURL.absoluteString), Path: \(path), Parameters: \(parameters))"
    }
}
