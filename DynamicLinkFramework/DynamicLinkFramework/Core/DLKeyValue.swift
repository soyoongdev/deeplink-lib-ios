//
//  DLKeyValue.swift
//  Runner
//
//  Created by soyoongdev on 4/2/25.
//

import Foundation

// MARK: - DLKeyValue

@objc public class DLKeyValue: NSObject {
    @objc public var key: String?
    @objc public var value: String?
    
    @objc public static func key(_ key: String, value: String) -> DLKeyValue {
        let kv = DLKeyValue()
        kv.key = key
        kv.value = value
        return kv
    }
    
    override public var description: String {
        return "<\(key ?? ""), \(value ?? "")>"
    }
    
    override public func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? DLKeyValue else {
            return false
        }
        return self.key == object.key && self.value == object.value
    }
}
