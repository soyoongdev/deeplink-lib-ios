//
//  DLDynamicLink.swift
//  Runner
//
//  Created by soyoongdev on 6/2/25.
//

import Foundation

// MARK: - Constants

public let kDLParameterDeepLinkIdentifier = "deepLinkIdentifier"
public let kDLParameterInviteId = "inviteId"
public let kDLParameterWeakMatchEndpoint = "weakMatchEndpoint"
public let kDLParameterMinimumAppVersion = "minimumAppVersion"
public let kDLParameterMatchType = "matchType"
public let kDLParameterMatchMessage = "matchMessage"


/// Class đại diện cho một Dynamic Link được xử lý từ Universal Link hoặc Custom Scheme URL
@objc public class DLDynamicLink: NSObject {
  
  /// URL gốc của Dynamic Link
  public let originalURL: URL
  
  /// Host của URL (nếu có)
  public let host: String?
  
  /// Path của URL
  public let path: String
  
  /// Các tham số truy vấn của Dynamic Link
  public let parameters: [String: String]
  
  /// Khởi tạo đối tượng DLDynamicLink từ một URL và các thông tin liên quan
  init?(url: URL) {
    self.originalURL = url
    self.host = url.host
    self.path = url.path
    
    // Trích xuất query parameters
    if let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
       let queryItems = components.queryItems {
      self.parameters = Dictionary(uniqueKeysWithValues: queryItems.compactMap { item in
        guard let value = item.value else { return nil }
        return (item.name, value)
      })
    } else {
      self.parameters = [:]
    }
    
    // Log quá trình khởi tạo
    DLLogger.log("✅ Created DLDynamicLink - URL: \(url.absoluteString)", level: .info)
    DLLogger.log("🔗 Parameters: \(self.parameters)", level: .info)
  }
  
  /// Khởi tạo từ các thành phần URL (có thể sử dụng khi xử lý universal link)
  init(url: URL, path: String, host: String?, parameters: [String: String]) {
    self.originalURL = url
    self.path = path
    self.host = host
    self.parameters = parameters
    
    DLLogger.log("✅ Created DLDynamicLink (manual init) - URL: \(url.absoluteString)", level: .info)
    DLLogger.log("🔗 Parameters: \(parameters)", level: .info)
  }
  
  /// Trả về mô tả của đối tượng
  public override var description: String {
    return "DLDynamicLink(URL: \(originalURL.absoluteString), Path: \(path), Parameters: \(parameters))"
  }
}
