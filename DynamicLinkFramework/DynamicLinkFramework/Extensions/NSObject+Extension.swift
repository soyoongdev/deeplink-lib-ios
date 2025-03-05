//
//  NSObject+Extension.swift
//  Runner
//
//  Created by soyoongdev on 6/2/25.
//

import Foundation

public extension NSObject {
    
    /// Đảm bảo chỉ một luồng (thread) có thể thực thi block tại một thời điểm trên cùng một instance (self). Giúp tránh điều kiện race condition (nhiều luồng truy cập cùng lúc gây lỗi).
    func synchronized<T>(_ block: () -> T) -> T {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        return block()
    }
    
    /// Đảm bảo block chỉ được thực thi duy nhất một lần trong vòng đời của chương trình. Thay thế dispatch_once cũ trong Objective-C (đã bị deprecated từ iOS 10).
    func dispatchOnce(block: () -> Void) {
        struct Static {
            static var hasRun = false
        }
        if !Static.hasRun {
            Static.hasRun = true
            block()
        }
    }
}
