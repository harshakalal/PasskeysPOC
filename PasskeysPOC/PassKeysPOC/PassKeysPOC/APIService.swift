//
//  APIService.swift
//  PassKeysPOC
//
//  Created by Harsha AM on 03/02/23.
//

import Foundation

enum PasskeyAPIS {
    case register(username: String, displayName: String)
    case login(username: String)
    case finishRegistration(username: String, payload: String)
    
    var commandName: String {
        switch self {
        case .register:
            return "register"
        case .login:
            return "login"
        case .finishRegistration:
            return "finishauth"
        }
    }
    
    func request(completionHandler: @escaping ((Data?, URLResponse?, Error?) -> Void)) {
        switch self {
        case .register, .login:
            NetworkManager.sharedManager.request(command: commandName, httpBodyDict: getBodyDict(), httpFormBodyDict: nil, completionHandler: completionHandler)
        case .finishRegistration:
            NetworkManager.sharedManager.request(command: commandName, httpBodyDict: nil, httpFormBodyDict: getFormBodyDict(), completionHandler: completionHandler)
        }
        
    }
    
    private func getBodyDict() -> [String: Any] {
        var bodyDict: [String: Any] = [:]
        switch self {
        case .register(let username, let displayName):
            bodyDict[APIRequestKeys.username.rawValue] = username
            bodyDict[APIRequestKeys.display.rawValue] = displayName
        case .login(username: let username):
            bodyDict[APIRequestKeys.username.rawValue] = username
        case .finishRegistration:
            break
//            bodyDict[APIRequestKeys.username.rawValue] = username
//            bodyDict[APIRequestKeys.credential.rawValue] = payload
//            bodyDict["credname"] = "YML"
        }
        return bodyDict
    }
    
    private func getFormBodyDict() -> [[String: String]] {
        var bodyDict: [[String: String]] = [[:]]
        switch self {
        case .register:
            break
        case .login:
            break
        case .finishRegistration(username: let username,payload: let payload):
            bodyDict = [
              [
                "key": "username",
                "value": username,
                "type": "text"
              ],
              [
                "key": "credential",
                "value": payload,
                "type": "text"
              ]]
        }
        return bodyDict
    }

}

 
