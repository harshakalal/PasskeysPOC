//
//  AccountManager.swift
//  PassKeysPOC
//
//  Created by Harsha AM on 21/01/23.
//

import Foundation
import AuthenticationServices
import Alamofire

extension NSNotification.Name {
    static let UserSignedIn = Notification.Name("UserSignedInNotification")
}

class AccountManager: NSObject, ASAuthorizationControllerPresentationContextProviding, ASAuthorizationControllerDelegate {
    
    let domain = "creditone-webauth.ymedia.in" // TODO: insert your domain name here
    var presentationAnchor: ASPresentationAnchor?
    let networkManager = NetworkManager()
    var username: String?
    var ID: Data?
    
    func signUpWith(userName: String, anchor: ASPresentationAnchor) {
        let display = "display"
        self.presentationAnchor = anchor
        let publicKeyCredentialProvider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: domain)
        username = userName
        // Fetch the challenge from our webapp. The challenge is unique for every request.
        SignInViewModel().callRegisterUserAPI(username: userName, display: display, completionHandler: { [self] creationRequest, error in
            guard let creationRequest = creationRequest else {
                return
            }
            let challenge = creationRequest.publicKey.challenge.decodeBase64Url()!
            let userID = creationRequest.publicKey.user.id.decodeBase64Url()!
            let registrationRequest = publicKeyCredentialProvider.createCredentialRegistrationRequest(challenge: challenge, name: userName, userID: userID)
            //             Check if the webapp requires attestation (see https://docs.hanko.io/guides/attestation)
            if let attestation = creationRequest.publicKey.attestation {
                registrationRequest.attestationPreference = ASAuthorizationPublicKeyCredentialAttestationKind.init(rawValue: attestation)
            }
         
            let authController = ASAuthorizationController(authorizationRequests: [ registrationRequest ] )
            authController.delegate = self
            authController.presentationContextProvider = self
            authController.performRequests()
        })
    }
    
    func signInWith(anchor: ASPresentationAnchor) {
        self.presentationAnchor = anchor
        let publicKeyCredentialProvider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: domain)
        
        //         Fetch the challenge from our webapp the server. It is unique for every request.
        SignInViewModel().callLoginUserAPI(username: "champ", completionHandler: { assertionRequestOptions, error in
            guard let assertionRequestOptions = assertionRequestOptions else {
                return
            }
            let challenge = assertionRequestOptions.publicKey.challenge.decodeBase64Url()!
            let assertionRequest = publicKeyCredentialProvider.createCredentialAssertionRequest(challenge: challenge)
            
            // Check if the webapp requires user verification (see https://docs.hanko.io/guides/userverification)
            if let userVerification = assertionRequestOptions.publicKey.userVerification {
                assertionRequest.userVerificationPreference = ASAuthorizationPublicKeyCredentialUserVerificationPreference.init(rawValue: userVerification)
            }
            
            // you can pass in any mix of supported sign in request types here - we only use Passkeys
            let authController = ASAuthorizationController(authorizationRequests: [ assertionRequest ] )
            authController.delegate = self
            authController.presentationContextProvider = self
            authController.performRequests()
        })
        
    }
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
               
        switch authorization.provider {
            
        case let appleIDCredential as ASAuthorizationPlatformPublicKeyCredentialProvider:
            let userIdentifier = appleIDCredential.relyingPartyIdentifier
            print(userIdentifier)
        default:
            break
        }
        switch authorization.credential {

        case let credentialRegistration as ASAuthorizationPlatformPublicKeyCredentialRegistration:
            Task {
                print(ASAuthorization.Scope.fullName)

                await finishRegistration(credentials: credentialRegistration, username: username ?? "")
            }
        case let assertionResponse as ASAuthorizationPlatformPublicKeyCredentialAssertion:
            Task {
                await finishLogin(credentials: assertionResponse)
            }
        default:
            print("Unknown authorization type received in callback")
        }
    }
    
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let presentationAnchor = presentationAnchor else {
            fatalError()
        }
        return presentationAnchor
    }
    
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("Error AuthManager: \(error)")
    }
    
    func finishRegistration(credentials: ASAuthorizationPlatformPublicKeyCredentialRegistration, username: String) {
        guard let attestationObject = credentials.rawAttestationObject else { return }
        let clientDataJSON = credentials.rawClientDataJSON
        let credentialID = credentials.credentialID
        let payloadData = Credential(type: "public-key", id: credentialID.toBase64Url(), response: Response(attestationObject: attestationObject.toBase64Url(), clientDataJSON: clientDataJSON.toBase64Url(), transports: ["cable"]), clientExtensionResults: ClientExtensionResults(credProps: CredProps(rk: false)))
        print("AttestationObject: \(attestationObject.toBase64Url())")
        print("ClientDataJSON: \(clientDataJSON.toBase64Url())")
        print("CredentialID: \(credentialID.toBase64Url())")
        do {
            let encodedData = try JSONEncoder().encode(payloadData)
            guard let payload = String(data: encodedData, encoding: .utf8) else { return }
            let result = SignInViewModel().finishRegistration(username: username, payload: payload)
        } catch {
            print(error)
        }

//        if result != nil {
//            NotificationCenter.default
//                .post(name: NSNotification.Name("UserSignedInNotification"),
//                      object: nil)
//        }
    }
    
    func finishLogin(credentials: ASAuthorizationPlatformPublicKeyCredentialAssertion) {
        print(credentials.userID.toBase64Url())
    }
}


extension String {
    func decodeBase64Url() -> Data? {
        var base64 = self
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        if base64.count % 4 != 0 {
            base64.append(String(repeating: "=", count: 4 - base64.count % 4))
        }
        return Data(base64Encoded: base64)
    }
}

extension Data {
    func toBase64Url() -> String {
        return self.base64EncodedString().replacingOccurrences(of: "+", with: "-").replacingOccurrences(of: "/", with: "_").replacingOccurrences(of: "=", with: "")
    }
}
