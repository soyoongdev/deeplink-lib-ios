//
//  DLConfig.swift
//  SampleDynamicLink
//
//  Created by NGUYEN HAU on 17/2/25.
//

import Foundation

@objc public class DLConfig: NSObject {  
  /// Danh sách host được phép xử lý
  public static var allowedHosts: [String] = []
  
  /// Scheme mặc định cho ứng dụng
  /// Src: Lấy Scheme array từ CFBundleURLSchemes trong file Info.plist
  public static var appSchemes: [String] = []
  
}
