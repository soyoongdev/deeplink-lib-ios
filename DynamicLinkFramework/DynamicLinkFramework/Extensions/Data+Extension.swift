//
//  Data+Extension.swift
//  DynamicLinkFramework
//
//  Created by NGUYEN HAU on 25/2/25.
//

import Foundation

public extension Data {
    
    /// Chuyển đổi Data thành một chuỗi Base64.
    func base64EncodeData() -> String {
        return self.base64EncodedString()
    }
    
    /// Giải mã Data thành String UTF-8.
    func decodeJsonDataToDictionary() -> [String: Any] {
        guard let jsonString = String(data: self, encoding: .utf8) else { return [:] }
        return jsonString.decodeJsonStringToDictionary()
    }
    
    /// Chuyển đổi Data thành một chuỗi hexadecimal (cơ số 16).
    func hexString() -> String {
        guard !self.isEmpty else { return "" }
        return self.map { String(format: "%02X", $0) }.joined()
    }
    
    /// Giải mã Data thành một đối tượng JSON (Dictionary<String, Any>).
    func parseJSON() -> [String: Any]? {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: self, options: .mutableContainers)
            return jsonObject as? [String: Any]
        } catch {
            return nil
        }
    }
    
}
