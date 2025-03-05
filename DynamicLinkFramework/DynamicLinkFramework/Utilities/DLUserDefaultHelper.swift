//
//  DLUserDefaultHelper.swift
//  Runner
//
//  Created by soyoongdev on 5/2/25.
//
import Foundation

/// A type that reads from and writes to an underlying storage container.
@objc public class DLUserDefaultHelper: NSObject {
    
    @objc public static let shared = DLUserDefaultHelper()
    
    private let defaults = UserDefaults.standard
    
    /// Lưu String vào UserDefaults
    @objc public func setString(_ value: String, forKey key: String) {
        defaults.set(value, forKey: key)
        defaults.synchronize()
    }
    
    /// Lấy String từ UserDefaults
    @objc public func getString(forKey key: String) -> String? {
        return defaults.string(forKey: key)
    }
    
    /// Lưu Integer vào UserDefaults
    @objc public func setInt(_ value: Int, forKey key: String) {
        defaults.set(value, forKey: key)
        defaults.synchronize()
    }
    
    /// Lấy Integer từ UserDefaults
    @objc public func getInt(forKey key: String) -> Int {
        return defaults.integer(forKey: key)
    }
    
    /// Lưu Bool vào UserDefaults
    @objc public func setBool(_ value: Bool, forKey key: String) {
        defaults.set(value, forKey: key)
        defaults.synchronize()
    }
    
    /// Lấy Bool từ UserDefaults
    @objc public func getBool(forKey key: String) -> Bool {
        return defaults.bool(forKey: key)
    }
    
    /// Lưu Dictionary vào UserDefaults
    @objc public func setDictionary(_ value: NSDictionary, forKey key: String) {
        defaults.set(value, forKey: key)
        defaults.synchronize()
    }
    
    /// Lấy Dictionary từ UserDefaults
    @objc public func getDictionary(forKey key: String) -> NSDictionary? {
        return defaults.dictionary(forKey: key) as NSDictionary?
    }
    
    /// Xóa giá trị khỏi UserDefaults
    @objc public func remove(forKey key: String) {
        defaults.removeObject(forKey: key)
    }
    
    /// Kiểm tra xem một key có tồn tại hay không
    @objc public func containsKey(_ key: String) -> Bool {
        return defaults.object(forKey: key) != nil
    }
    
    /// Xóa tất cả dữ liệu trong UserDefaults
    @objc public func removeAllKeys() {
        let domain = Bundle.main.bundleIdentifier!
        defaults.removePersistentDomain(forName: domain)
        defaults.synchronize()
        DLLogger.log("✅ Đã xoá toàn bộ dữ liệu trong UserDefaults")
    }
}
