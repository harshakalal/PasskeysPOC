//
//  NetworkManager.swift
//  PassKeysPOC
//
//  Created by Harsha AM on 03/02/23.
//

import Foundation


class NetworkManager {
    
    static var sharedManager = NetworkManager()
    
    private func getURLRequest(command: String, httpBodyDict: [String: Any]) -> URLRequest? {
            guard let url = URL(string: "\(NetworkManagerStringConstants.baseURL.rawValue)\(command)") else {
                return nil
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = NetworkManagerMethod.Post.rawValue
            request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: APIRequestKeys.ContentType.rawValue)
            var bodyParams = ""
            httpBodyDict.enumerated().forEach { (index, dict) in
                bodyParams += "\(dict.key)=\(dict.value)"
                if index != httpBodyDict.count - 1 {
                    bodyParams += "&"
                }
            }
            let postData =  bodyParams.data(using: .utf8)
            request.httpBody = postData
            return request
        }
    func request(command: String, httpBodyDict: [String: Any], completionHandler: @escaping ((Data?, URLResponse?, Error?) -> Void)) {
        guard let urlRequest = getURLRequest(command: command, httpBodyDict: httpBodyDict) else {
            completionHandler(nil, nil, NSError(domain: "\(NetworkManagerStringConstants.genericError.rawValue)", code: 500))
            return
        }
        startDataTask(request: urlRequest, completionHandler: completionHandler)
    }
    
    private func logRequest(_ request: URLRequest) {
            #if DEBUG
            if let method = request.httpMethod {
                print("\nMethod: ", method)
            }
            
            if let url = request.url {
                print("\nURL: ", url)
            }
            
            if let headers = request.allHTTPHeaderFields {
                print("\nHeaders: ", headers)
            }
            
           // if let requestUrl = request.url, let cookies = HTTPCookieStorage.shared.cookies(for: requestUrl) {
    //            print("\nRequest Cookies: \(String(describing: cookies))")
          //  }
            
            if let body = request.httpBody {
                print("\nBody Data: ", NSString(data: body, encoding: String.Encoding.utf8.rawValue) ?? "")
            }
            #endif
            
        }


    
    private func startDataTask(request: URLRequest, completionHandler: @escaping ((Data?, URLResponse?, Error?) -> Void)) {
        print("Request: \(logRequest(request))")
        let session = URLSession(configuration: .default)
        let dataTask = session.dataTask(with: request) { data, response, error in
            print("Data: \(String(decoding: data ?? Data(), as: UTF8.self))")
            print("Response: \(response)")
            print("Error: \(error)")
            if let error = error {
                completionHandler(nil, response, error)
            } else if let data = data {
                completionHandler(data, response, nil)
            } else {
                completionHandler(nil, response, NSError(domain: "\(NetworkManagerStringConstants.genericError.rawValue)", code: 500))
            }
        }
        dataTask.resume()
    }
}
