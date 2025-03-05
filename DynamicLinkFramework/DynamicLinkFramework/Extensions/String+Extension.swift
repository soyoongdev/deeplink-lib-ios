//
//  String+Extension.swift
//  DynamicLinkFramework
//
//  Created by NGUYEN HAU on 25/2/25.
//

import Foundation
import CommonCrypto

public extension String {
    
    /// Nhận một chuỗi Base64 và giải mã nó thành Data.
    func base64DecodeString() -> Data? {
        let cleanedBase64 = self.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let data = Data(base64Encoded: cleanedBase64) else {
            return nil
        }
        return data
    }
    
    /// Giải mã một chuỗi Base64 thành một chuỗi String có thể đọc được bằng UTF-8.
    func base64DecodeStringToString() -> String? {
        let cleanedBase64 = self.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let data = Data(base64Encoded: cleanedBase64) else {
            return nil
        }
        guard let decodedString = String(data: data, encoding: .utf8) else {
            return nil
        }
        return decodedString
    }
    
    /// Mã hóa một chuỗi String sang định dạng Base64 bằng encoding UTF-8.
    func base64EncodeStringToString() -> String? {
        guard let data = self.data(using: .utf8) else {
            return nil
        }
        return data.base64EncodedString()
    }
    
    /// Hàm này sanitize (làm sạch) một chuỗi String bằng cách thay thế các ký tự đặc biệt thành chuỗi an toàn, thường được sử dụng khi xử lý JSON hoặc SQL.
    func sanitizedString() -> String {
        let replacements: [String: String] = [
            "\\": "\\\\",
            "\u{0008}": "\\b",
            "\u{000C}": "\\f",
            "\n": "\\n",
            "\r": "\\r",
            "\t": "\\t",
            "\"": "\\\"",
            "`": "'"
        ]
        return replacements.reduce(self) { (result, pair) in
            result.replacingOccurrences(of: pair.key, with: pair.value)
        }
    }
    
    /// Hàm này mã hóa chuỗi thành URL bằng cách percent-encoding các ký tự đặc biệt, giúp chuỗi có thể được sử dụng an toàn trong một URL.
    func urlEncodedString() -> String? {
        let allowedCharacterSet = CharacterSet.urlQueryAllowed
            .subtracting(CharacterSet(charactersIn: "!*'();:@&=+$,/?%#[] "))
        return self.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet)
    }
    
    /// Hàm này giải mã (decode) một chuỗi đã được percent-encoded, tức là chuyển các ký tự %XX thành ký tự gốc.
    func stringByPercentDecodingString() -> String? {
        return self.removingPercentEncoding
    }
    
    /// Hàm này mã hóa (encode) một chuỗi để sử dụng trong URL query, tức là chuyển các ký tự đặc biệt thành dạng percent-encoded.
    func stringByPercentEncodingStringForQuery() -> String? {
        return self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    }
    
    /// Chuyển đổi một chuỗi JSON thành dictionary ([String: Any])
    func decodeJsonStringToDictionary() -> [String: Any] {
        guard let tempData = self.data(using: .utf8) else { return [:] }
        
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: tempData, options: .mutableContainers)
            if let dictionary = jsonObject as? [String: Any] {
                return dictionary
            }
        } catch {
            return [:]
        }
        
        // Nếu JSON có thể đã được mã hóa Base64, thử giải mã trước.
        if let base64Decoded = Data(base64Encoded: self),
           let decodedString = String(data: base64Decoded, encoding: .utf8),
           let decodedData = decodedString.data(using: .utf8),
           let dictionary = decodedData.parseJSON() {
            return dictionary
        }
        
        return [:]
    }
    
    /// Chuyển đổi một chuỗi query string thành dictionary
    func decodeQueryStringToDictionary() -> [String: String] {
        guard !self.isEmpty else { return [:] } // Kiểm tra chuỗi rỗng trước khi xử lý
        
        var params: [String: String] = [:]
        
        let pairs = self.split(separator: "&")
        for pair in pairs {
            let kv = pair.split(separator: "=", maxSplits: 1).map { String($0) }
            let key = kv[0]
            let value = kv.count > 1 ? kv[1].removingPercentEncoding ?? "" : ""
            params[key] = value
        }
        
        return params
    }
    
    /// Chuyển đổi chuỗi hex thành `Data`
    func dataFromHexString() -> Data? {
        // Lọc chỉ giữ lại các ký tự hợp lệ trong hệ thập lục phân (0-9, A-F, a-f)
        let cleanedHex = self.filter { $0.isHexDigit }
        
        // Độ dài phải là số chẵn (mỗi byte là 2 ký tự hex)
        guard cleanedHex.count % 2 == 0 else { return nil }
        
        var data = Data()
        var currentIndex = cleanedHex.startIndex
        
        // Duyệt qua từng cặp ký tự hex (mỗi byte có 2 ký tự)
        while currentIndex < cleanedHex.endIndex {
            let nextIndex = cleanedHex.index(currentIndex, offsetBy: 2)
            guard let byte = UInt8(cleanedHex[currentIndex..<nextIndex], radix: 16) else {
                return nil // Nếu có ký tự không hợp lệ, trả về nil
            }
            data.append(byte)
            currentIndex = nextIndex
        }
        
        return data
    }
    
    func wireFormatFromString() -> String {
        return self
    }
}

public extension String? {
    
    // MARK: - SHA 256 methods
    
    /// Mã hóa chuỗi bằng SHA-256 và trả về dạng hex
    func sha256Encode() -> String {
        guard let input = self?.data(using: .utf8) else { return "" }
        
        var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        input.withUnsafeBytes { bufferPointer in
            _ = CC_SHA256(bufferPointer.baseAddress, CC_LONG(input.count), &digest)
        }
        
        return digest.map { String(format: "%02x", $0) }.joined()
    }
    
}
