//
//  APIService.swift
//  PassKeysPOC
//
//  Created by Harsha AM on 03/02/23.
//

import Foundation

enum PasskeyAPIS {
    case register(username: String, displayName: String)
    
    var commandName: String {
        switch self {
        case .register:
            return "register"
        }
    }
    
    
    func request(completionHandler: @escaping ((Data?, URLResponse?, Error?) -> Void)) {
//        NetworkManager.sharedManager.request(command: commandName, httpBodyDict: getBodyDict(), completionHandler: completionHandler)
        NetworkManager.sharedManager.request(command: commandName, httpBodyDict: getBodyDict(), completionHandler: completionHandler)
    }
    private func getBodyDict() -> [String: Any] {
        var bodyDict: [String: Any] = [:]
        switch self {
        case .register(let username, let displayName):
            bodyDict[APIRequestKeys.username.rawValue] = username
            bodyDict[APIRequestKeys.display.rawValue] = displayName
        }
        return bodyDict
    }
    
}


