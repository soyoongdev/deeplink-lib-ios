//
//  DLLogger.swift
//  Runner
//
//  Created by soyoongdev on 4/2/25.
//
import Foundation
import os.log

/// Các cấp độ log
@objc public enum LogLevel: Int {
    case debug = 0
    case info
    case warning
    case error

    public var description: String {
        switch self {
        case .debug: return "🐞 DEBUG"
        case .info: return "ℹ️ INFO"
        case .warning: return "⚠️ WARNING"
        case .error: return "❌ ERROR"
        }
    }
}

/// Cấu hình Logger
@objc public class DLLoggerConfig: NSObject {
    @objc public static var isLoggingEnabled: Bool = true  // Bật/Tắt log console
    @objc public static var shouldLogToFile: Bool = true   // Bật/Tắt log file
    @objc public static var shouldUseOSLog: Bool = true    // Bật/Tắt OSLog
    @objc public static var shouldUseNSLog: Bool = true    // Ghi log vào NSLog
}

/// DLLogger - Hỗ trợ log theo nhiều cấp độ, lưu log vào file nếu cần
@objc public class DLLogger: NSObject {
    
    /// Ghi log với đầy đủ thông tin
    @objc public static func log(_ message: String, level: LogLevel = .info, function: String = #function, file: String = #file, line: Int = #line) {
        let fileName = (file as NSString).lastPathComponent
        let logMessage = "[\(level.description)] \(fileName) -> \(function) [Line \(line)]: \(message)"
        
        // Ghi log vào console
        if DLLoggerConfig.isLoggingEnabled {
            print(logMessage)
        }
        
        // Ghi log vào NSLog
        if DLLoggerConfig.shouldUseNSLog {
            NSLog("%@", logMessage)
        }
        
        // Ghi log vào OSLog (chỉ iOS 10+)
        if DLLoggerConfig.shouldUseOSLog {
            logToOSLog(message, level: level)
        }
        
        // Ghi log vào file
        if DLLoggerConfig.shouldLogToFile {
            logToFile(logMessage)
        }
    }
    
    /// Ghi log vào OSLog (Unified Logging System của Apple)
    @available(iOS 10.0, *)
    private static func logToOSLog(_ message: String, level: LogLevel) {
        let osLogType: OSLogType
        switch level {
        case .debug: osLogType = .debug
        case .info: osLogType = .info
        case .warning: osLogType = .default
        case .error: osLogType = .error
        }
        
        let osLogger = OSLog(subsystem: Bundle.main.bundleIdentifier ?? "com.default.app", category: "DLLogger")
        os_log("%@", log: osLogger, type: osLogType, message)
    }
    
    /// Ghi log vào file trong thư mục Documents
    private static func logToFile(_ logMessage: String) {
        let fileManager = FileManager.default
        let logFilePath = getLogFilePath()
        
        if !fileManager.fileExists(atPath: logFilePath) {
            fileManager.createFile(atPath: logFilePath, contents: nil, attributes: nil)
        }
        
        guard let fileHandle = try? FileHandle(forWritingTo: URL(fileURLWithPath: logFilePath)) else { return }
        defer { fileHandle.closeFile() }
        
        fileHandle.seekToEndOfFile()
        if let data = ("\n" + logMessage).data(using: .utf8) {
            fileHandle.write(data)
        }
    }
    
    /// Lấy đường dẫn file log trong thư mục Documents
    private static func getLogFilePath() -> String {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentDirectory.appendingPathComponent("app_log.txt").path
    }
    
    /// Xóa file log
    @objc public static func clearLogFile() {
        let fileManager = FileManager.default
        let logFilePath = getLogFilePath()
        
        do {
            if fileManager.fileExists(atPath: logFilePath) {
                try fileManager.removeItem(atPath: logFilePath)
                print("✅ Log file cleared")
            }
        } catch {
            print("❌ Error clearing log file: \(error.localizedDescription)")
        }
    }
}
