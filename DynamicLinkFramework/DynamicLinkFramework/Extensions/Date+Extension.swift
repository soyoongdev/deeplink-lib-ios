//
//  Date+Extension.swift
//  DynamicLinkFramework
//
//  Created by NGUYEN HAU on 25/2/25.
//

import Foundation

public extension Date {
    
    /// Chuyển đổi Date thành chuỗi theo chuẩn ISO 8601.
    func iso8601StringFromDate() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX") // POSIX to avoid issues
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        return formatter.string(from: self)
    }
    
    /// Chuyển đổi Date thành số mili-giây kể từ epoch time (Unix timestamp).
    func wireFormatFromDate() -> NSNumber? {
        var number: NSNumber? = nil
        let t = self.timeIntervalSince1970
        if t != 0.0 {
            number = NSNumber(value: Int64(t * 1000.0))
        }
        return number
    }
    
}
