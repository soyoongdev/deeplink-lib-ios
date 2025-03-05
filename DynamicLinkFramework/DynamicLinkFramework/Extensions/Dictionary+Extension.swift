//
//  Dictionary+Extension.swift
//  DynamicLinkFramework
//
//  Created by NGUYEN HAU on 25/2/25.
//

import Foundation

public extension [String: Any] {
    
    /// Chuyển đổi Dictionary thành Data? dưới dạng JSON.
    func encodeDictionaryToJsonData() -> Data? {
        guard let jsonString = self.encodeDictionaryToJsonString() else { return nil }
        return jsonString.data(using: .utf8)
    }
    
    /// Chuyển Dictionary thành chuỗi JSON thủ công thay vì dùng JSONSerialization.
    func encodeDictionaryToJsonString() -> String? {
        var encodedDictionary: [String] = []
        
        for (key, obj) in self {
            var value: String?
            var isString = true
            
            if let stringObj = obj as? String {
                value = stringObj.sanitizedString()
            } else if let urlObj = obj as? URL {
                value = urlObj.absoluteString
            } else if let dateObj = obj as? Date {
                value = dateObj.iso8601StringFromDate()
            } else if let arrayObj = obj as? [Any] {
                value = arrayObj.encodeArrayToJsonString()
                isString = false
            } else if let dictObj = obj as? [String: Any] {
                value = dictObj.encodeDictionaryToJsonString()
                isString = false
            } else if let numberObj = obj as? NSNumber {
                isString = false
                if numberObj === kCFBooleanFalse {
                    value = "false"
                } else if numberObj === kCFBooleanTrue {
                    value = "true"
                } else {
                    value = numberObj.stringValue
                }
            } else if obj is NSNull {
                value = "null"
                isString = false
            } else {
                continue
            }
            
            let sanitizedKey = key.sanitizedString()
            
            if let value = value {
                let formattedValue = isString ? "\"\(value)\"" : value
                encodedDictionary.append("\"\(sanitizedKey)\":\(formattedValue)")
            }
        }
                        
        return "{\(encodedDictionary.joined(separator: ","))}"
    }
    
    /// Chuyển Dictionary thành query string (?key=value&key2=value2).
    func encodeDictionaryToQueryString() -> String {
        var queryString = "?"
        
        for (key, value) in self {
            guard !key.isEmpty else { continue }
            let encodedKey = key.urlEncodedString()
            
            var encodedValue: String?
            
            if let stringValue = value as? String {
                encodedValue = stringValue.urlEncodedString()
            } else if let urlValue = value as? URL {
                encodedValue = urlValue.absoluteString.urlEncodedString()
            } else if let dateValue = value as? Date {
                encodedValue = dateValue.iso8601StringFromDate()
            } else if let numberValue = value as? NSNumber {
                encodedValue = numberValue.stringValue
            } else {
                continue
            }
            
            if let _encodedKey = encodedKey, let _encodedValue = encodedValue {
                queryString.append("\(_encodedKey)=\(_encodedValue)&")
            }
        }
        
        // Remove the last "&" or return "?" if no parameters were added
        return queryString.count > 1 ? String(queryString.dropLast()) : queryString
    }
    
    /// Dùng JSONSerialization để in đẹp JSON (sắp xếp keys, format đẹp).
    func prettyPrintJSON() -> String? {
        guard JSONSerialization.isValidJSONObject(self) else {
            return nil
        }
        
        do {
            let data = try JSONSerialization.data(withJSONObject: self, options: [.sortedKeys, .prettyPrinted])
            return String(data: data, encoding: .utf8)
        } catch {
            return nil
        }
    }
}

public extension [String: Any]? {
    
    /// Chuyển Dictionary thành chuỗi JSON thủ công thay vì dùng JSONSerialization.
    func encodeDictionaryToJsonString() -> String? {
        var encodedDictionary: [String] = []
        
        guard let dictionary = self else { return nil }
        for (key, obj) in dictionary {
            var value: String?
            var isString = true
            
            if let stringObj = obj as? String {
                value = stringObj.sanitizedString()
            } else if let urlObj = obj as? URL {
                value = urlObj.absoluteString
            } else if let dateObj = obj as? Date {
                value = dateObj.iso8601StringFromDate()
            } else if let arrayObj = obj as? [Any] {
                value = arrayObj.encodeArrayToJsonString()
                isString = false
            } else if let dictObj = obj as? [String: Any] {
                value = dictObj.encodeDictionaryToJsonString()
                isString = false
            } else if let numberObj = obj as? NSNumber {
                isString = false
                if numberObj === kCFBooleanFalse {
                    value = "false"
                } else if numberObj === kCFBooleanTrue {
                    value = "true"
                } else {
                    value = numberObj.stringValue
                }
            } else if obj is NSNull {
                value = "null"
                isString = false
            } else {
                continue
            }
            
            let sanitizedKey = key.sanitizedString()
            
            if let value = value {
                let formattedValue = isString ? "\"\(value)\"" : value
                encodedDictionary.append("\"\(sanitizedKey)\":\(formattedValue)")
            }
        }
                        
        return "{\(encodedDictionary.joined(separator: ","))}"
    }
    
}

public extension [Any] {
    
    /// Hàm encodeArrayToJsonString() chuyển đổi một mảng (Array) thành một chuỗi JSON một cách thủ công mà không dùng JSONSerialization.
    func encodeArrayToJsonString() -> String {
        guard !self.isEmpty else {
            return "[]"
        }
        
        var encodedArray: [String] = []
        
        for obj in self {
            var value: String?
            var isString = true
            
            if let stringObj = obj as? String {
                value = stringObj.sanitizedString()
            } else if let urlObj = obj as? URL {
                value = urlObj.absoluteString
            } else if let dateObj = obj as? Date {
                value = dateObj.iso8601StringFromDate()
            } else if let arrayObj = obj as? [Any] {
                value = arrayObj.encodeArrayToJsonString()
                isString = false
            } else if let dictObj = obj as? [String: Any] {
                value = dictObj.encodeDictionaryToJsonString()
                isString = false
            } else if let numberObj = obj as? NSNumber {
                value = numberObj.stringValue
                isString = false
            } else if obj is NSNull {
                value = "null"
                isString = false
            } else {
                continue
            }
            
            if let value = value {
                if isString {
                    encodedArray.append("\"\(value)\"")
                } else {
                    encodedArray.append(value)
                }
            }
        }
        
        return "[\(encodedArray.joined(separator: ","))]"
    }
    
}
