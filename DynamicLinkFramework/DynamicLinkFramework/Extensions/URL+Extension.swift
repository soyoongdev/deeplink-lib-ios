//
//  URL+Extension.swift
//  DynamicLinkFramework
//
//  Created by NGUYEN HAU on 25/2/25.
//

import Foundation

public extension URL? {
    
    func queryItems() -> [DLKeyValue] {
        var keyValues = [DLKeyValue]()
        guard let url = self else {
            return keyValues
        }
        
        let queryItems = url.query?.components(separatedBy: "&") ?? []
        for itemPair in queryItems {
            let keyValue = DLKeyValue()
            
            if let range = itemPair.range(of: "=") {
                keyValue.key = String(itemPair[..<range.lowerBound])
                let valueRange = range.upperBound..<itemPair.endIndex
                if valueRange.lowerBound < itemPair.endIndex {
                    keyValue.value = String(itemPair[valueRange])
                }
            } else {
                if !itemPair.isEmpty {
                    keyValue.key = itemPair
                }
            }
            
            guard let key = keyValue.key, let value = keyValue.value else { return keyValues }
            
            keyValue.key = key.stringByPercentDecodingString()
            keyValue.key = key.trimmingCharacters(in: .whitespacesAndNewlines)
            
            keyValue.value = value.stringByPercentDecodingString()
            keyValue.value = value.trimmingCharacters(in: .whitespacesAndNewlines)
            
            
            if !key.isEmpty || !value.isEmpty {
                if keyValue.key == nil {
                    keyValue.key = ""
                }
                
                if keyValue.value == nil {
                    keyValue.value = ""
                }
                keyValues.append(keyValue)
            }
        }
        
        return keyValues
    }
    
}
