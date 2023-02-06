//
//  Model.swift
//  PassKeysPOC
//
//  Created by Harsha AM on 03/02/23.
//


struct CredentialCreation : Codable {
    var publicKey: CredentialCreationPublicKey
}

struct CredentialCreationPublicKey : Codable {
    var challenge: String
    var user: CredentialCreationUser
    var attestation: String?
//    var authenticatorSelection: CredentialCreationAuthenticatorSelection?
}

struct CredentialCreationUser : Codable {
    var id: String
    var name: String
    var displayName: String
}

