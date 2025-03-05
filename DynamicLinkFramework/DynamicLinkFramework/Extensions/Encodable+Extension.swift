//
//  Encodable+Extension.swift
//  dynamiclink-ios-framework-swift
//
//  Created by NGUYEN HAU on 24/2/25.
//

import Foundation

public extension Encodable {
    
    /// Hàm này chuyển đổi một đối tượng Swift (Encodable) thành chuỗi JSON (String) với các tùy chỉnh đặc biệt về định dạng ngày (Date) và định dạng JSON.
    func toJsonString() -> String {
        do {
            let encoder = JSONEncoder()
            
            // Định dạng ngày chuẩn ISO 8601 với UTC (Z)
            let dateFormatter = DateFormatter()
            dateFormatter.calendar = Calendar(identifier: .iso8601)
            dateFormatter.locale = Locale(identifier: "en_US_POSIX") // Tránh lỗi định dạng
            dateFormatter.timeZone = TimeZone(secondsFromGMT: 0) // UTC
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ" // Thêm Z cho UTC
            
            encoder.dateEncodingStrategy = .formatted(dateFormatter)
            
            // Định dạng JSON: sắp xếp khóa, in đẹp, không escape "/"
            if #available(iOS 13.0, *) {
                encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
            } else {
                encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            }
            
            let jsonData = try encoder.encode(self)
            
            // Trả về JSON string hoặc JSON rỗng nếu nil
            return String(data: jsonData, encoding: .utf8) ?? "{}"
            
        } catch {
            return "{}" // JSON rỗng thay vì chuỗi rỗng
        }
    }
    
}
