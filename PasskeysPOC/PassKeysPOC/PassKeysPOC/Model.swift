//
//  Model.swift
//  PassKeysPOC
//
//  Created by Harsha AM on 03/02/23.
//

import Foundation

class SessionManager {
    static let sharedInstance = SessionManager()
    var sessionID: String?
    
    private init() { }
//    init(sessionID: String) {
//        self.sessionID = sessionID
//    }
}

struct CredentialCreation : Codable {
    var publicKey: CredentialCreationPublicKey
}

struct CredentialCreationPublicKey : Codable {
    var challenge: String
    var user: CredentialCreationUser
    var rp: Rp
    var attestation: String?
//    var authenticatorSelection: CredentialCreationAuthenticatorSelection?
}

struct Rp: Codable {
    var id: String
}

struct CredentialCreationUser : Codable {
    var id: String
    var name: String
    var displayName: String
}

struct CredentialAssertion : Codable {
    var publicKey: CredentialAssertionPublicKey
}

struct CredentialAssertionPublicKey : Codable {
    var challenge: String
    var userVerification: String?
}



// JSON ENCODING DATA (PAYLOAD)

struct Credential: Codable {
    var type: String
    var id: String
    var response: Response
    var clientExtensionResults: ClientExtensionResults
}

// MARK: - ClientExtensionResults
struct ClientExtensionResults: Codable {
    var credProps: CredProps
}

// MARK: - CredProps
struct CredProps: Codable {
    var rk: Bool
}

// MARK: - Response
struct Response: Codable {
    var attestationObject: String
    var clientDataJSON: String
    var transports: [String]
}


