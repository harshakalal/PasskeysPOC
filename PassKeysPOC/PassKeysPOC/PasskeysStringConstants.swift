//
//  PasskeysStringConstants.swift
//  PassKeysPOC
//
//  Created by Harsha AM on 03/02/23.
//

import Foundation

enum NetworkManagerStringConstants: String {
    case baseURL = "http://localhost:8081/"
    case genericError = "We are unable to process request"
}

enum APIRequestKeys: String {
    case username = "username"
    case display = "display"
    case ContentType = "Content-Type"
}

enum NetworkManagerMethod: String {
    case Get        = "GET"
    case Put        = "PUT"
    case Post       = "POST"
    case Delete     = "DELETE"
}


