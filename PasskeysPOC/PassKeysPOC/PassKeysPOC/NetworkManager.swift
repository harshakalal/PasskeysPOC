//
//  NetworkManager.swift
//  PassKeysPOC
//
//  Created by Harsha AM on 03/02/23.
//

import Foundation


class NetworkManager {
    
    static var sharedManager = NetworkManager()
    let boundary = "Boundary-\(UUID().uuidString)"

    
    private func getURLRequest(command: String, httpBodyDict: [String: Any]?, httpFormBodyDict: [[String: String]]?) -> URLRequest? {
        guard let url = URL(string: "\(NetworkManagerStringConstants.baseURL.rawValue)\(command)") else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = NetworkManagerMethod.Post.rawValue
        if command == "finishauth" {
            request.addValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: APIRequestKeys.ContentType.rawValue)
            request.addValue("\(SessionManager.sharedInstance.sessionID ?? "")", forHTTPHeaderField: "Cookie")
        } else {
            request.addValue(APIRequestKeys.ContentTypeFormat.rawValue, forHTTPHeaderField: APIRequestKeys.ContentType.rawValue)
//            request.addValue("JSESSIONID=E45CAAB8588DE2BA6B4F64D33060E61D", forHTTPHeaderField: "Cookie")
        }
        var bodyParams = ""
        if command != "finishauth" {
            guard let httpBodyDict = httpBodyDict else { fatalError() }
            httpBodyDict.enumerated().forEach { (index, dict) in
                bodyParams += "\(dict.key)=\(dict.value)"
                if index != httpBodyDict.count - 1 {
                    bodyParams += "&"
                }
            }
        } else {
            guard let httpFormBodyDict = httpFormBodyDict else { fatalError() }
            bodyParams = convertToFormData(parameters: httpFormBodyDict)
        }
        guard let postData =  bodyParams.data(using: .utf8) else { fatalError() }
        request.httpBody = postData
        print(String(decoding: postData, as: UTF8.self))
        return request
    }
    func request(command: String, httpBodyDict: [String: Any]?, httpFormBodyDict: [[String: String]]?, completionHandler: @escaping ((Data?, URLResponse?, Error?) -> Void)) {
        guard let urlRequest = getURLRequest(command: command, httpBodyDict: httpBodyDict, httpFormBodyDict: httpFormBodyDict) else {
            completionHandler(nil, nil, NSError(domain: "\(NetworkManagerStringConstants.genericError.rawValue)", code: 500))
            return
        }
        startDataTask(command: command,request: urlRequest, completionHandler: completionHandler)
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
                guard let cookies = headers["Cookie"] else { return }
//                SessionManager.sharedInstance.sessionID = cookies
                print("Cookie: \(cookies)")
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


    
    private func startDataTask(command: String,request: URLRequest, completionHandler: @escaping ((Data?, URLResponse?, Error?) -> Void)) {
        print("Request: \(logRequest(request))")
        let session = URLSession(configuration: .default)

        let dataTask = session.dataTask(with: request) { data, response, error in
            print("Data: \(String(decoding: data ?? Data(), as: UTF8.self))")
            print("Response: \(response)")
            print("Error: \(error)")
            if command == "register" {
                if let httpResponse = response as? HTTPURLResponse {
                    if let headers = httpResponse.allHeaderFields as? [String: String], let cookies = headers["Set-Cookie"] {
                        SessionManager.sharedInstance.sessionID = cookies
                    }
                }
            }
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
    
    private func convertToFormData(parameters: [[String : String]]) -> String {
        var body = ""
        var error: Error? = nil
        for param in parameters {
          if param["disabled"] == nil {
            let paramName = param["key"]!
            body += "--\(boundary)\r\n"
            body += "Content-Disposition:form-data; name=\"\(paramName)\""
            if param["contentType"] != nil {
              body += "\r\nContent-Type: \(param["contentType"] as! String)"
            }
            let paramType = param["type"] as! String
            if paramType == "text" {
              let paramValue = param["value"] as! String
              body += "\r\n\r\n\(paramValue)\r\n"
            } else {
              let paramSrc = param["src"] as! String
                do {
                    let fileData = try NSData(contentsOfFile:paramSrc, options:[]) as Data
                    let fileContent = String(data: fileData, encoding: .utf8)!
                      body += "; filename=\"\(paramSrc)\"\r\n"
                        + "Content-Type: \"content-type header\"\r\n\r\n\(fileContent)\r\n"

                } catch {
                    print(error)
                }
            }
          }
        }
        body += "--\(boundary)--\r\n";
        return body
    }
}


