//
//  Any+Extension.swift
//  DynamicLinkFramework
//
//  Created by NGUYEN HAU on 25/2/25.
//

import Foundation

public extension Any? {
    
    func dateFromWireFormat() -> Date? {
        guard let timeInterval = (self as? NSNumber)?.doubleValue else { return nil }
        return Date(timeIntervalSince1970: timeInterval / 1000.0)
    }
    
    /// Hàm chuyển đổi một đối tượng bất kỳ (Any) thành chuỗi (String)
    /// - Parameter object: Any
    /// - Returns: String?
    func stringFromWireFormat() -> String? {
        if let stringObject = self as? String {
            return stringObject
        } else if let number = self as? NSNumber {
            return number.stringValue
        } else if let describable = self as? CustomStringConvertible {
            return describable.description
        }
        return nil
    }
    
}
