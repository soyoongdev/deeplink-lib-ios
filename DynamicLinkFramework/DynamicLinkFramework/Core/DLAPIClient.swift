//
//  DLServerAPI.swift
//  Runner
//
//  Created by soyoongdev on 7/2/25.
//

import Foundation

@objc public class DLAPIClient: NSObject {
  
  @objc public static let shared = DLAPIClient()
  
  private override init() {} // Singleton
  
  private let session: URLSession = {
    let config = URLSessionConfiguration.default
    config.timeoutIntervalForRequest = 30 // Timeout 30s
    return URLSession(configuration: config)
  }()
  
  @objc public func request(
    endpoint: String,
    method: String = "GET",
    parameters: [String: Any]? = nil,
    headers: [String: String]? = nil,
    completion: @escaping DLDynamicLinkResultHandler
  ) {
      let urlRequest = apiURL + endpoint
      guard var urlComponents = URLComponents(string: urlRequest) else {
      completion(nil, NSError(domain: "DLAPIClient", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]))
      return
    }
    
    // Thêm query parameters nếu là GET request
    if method == "GET", let parameters = parameters {
      urlComponents.queryItems = parameters.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
    }
    
    guard let url = urlComponents.url else {
      completion(nil, NSError(domain: "DLAPIClient", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid URL Components"]))
      return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = method
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    
    // Thêm headers
    headers?.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }
    
    // Thêm body nếu không phải GET request
    if method != "GET", let parameters = parameters {
      do {
        request.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
      } catch {
        completion(nil, NSError(domain: "DLAPIClient", code: 500, userInfo: [NSLocalizedDescriptionKey: "Failed to encode parameters"]))
        return
      }
    }
    
    let task = self.session.dataTask(with: request) { data, response, error in
      if let error = error {
        completion(nil, error as NSError)
        return
      }
      
      guard let httpResponse = response as? HTTPURLResponse else {
        completion(nil, NSError(domain: "DLAPIClient", code: 500, userInfo: [NSLocalizedDescriptionKey: "Invalid server response"]))
        return
      }
      
      if (200...299).contains(httpResponse.statusCode), let data = data {
        completion(data, nil)
      } else {
        let errorMessage = "Server returned status code: \(httpResponse.statusCode)"
        completion(nil, NSError(domain: "DLAPIClient", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage]))
      }
    }
    
    task.resume()
  }
  
  // MARK: - Helper Methods (Giống Axios)
  
  @objc public func get(endpoint: String, parameters: [String: Any]? = nil, headers: [String: String]? = nil, completion: @escaping DLDynamicLinkResultHandler) {
    request(endpoint: endpoint, method: "GET", parameters: parameters, headers: headers, completion: completion)
  }
  
  @objc public func post(endpoint: String, parameters: [String: Any], headers: [String: String]? = nil, completion: @escaping DLDynamicLinkResultHandler) {
    request(endpoint: endpoint, method: "POST", parameters: parameters, headers: headers, completion: completion)
  }
  
  @objc public func put(endpoint: String, parameters: [String: Any], headers: [String: String]? = nil, completion: @escaping DLDynamicLinkResultHandler) {
    request(endpoint: endpoint, method: "PUT", parameters: parameters, headers: headers, completion: completion)
  }
  
  @objc public func delete(endpoint: String, parameters: [String: Any]? = nil, headers: [String: String]? = nil, completion: @escaping DLDynamicLinkResultHandler) {
    request(endpoint: endpoint, method: "DELETE", parameters: parameters, headers: headers, completion: completion)
  }
}
