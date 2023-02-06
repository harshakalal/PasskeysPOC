//
//  SignInViewModel.swift
//  PassKeysPOC
//
//  Created by Harsha AM on 03/02/23.
//

import Foundation

class SignInViewModel {
    var usernameString: String?
    var displayName: String?
    
    func callRegisterUserAPI(username: String?, display: String?,completionHandler: @escaping (CredentialCreation?, Error?) -> Void) {
        guard let username = username , let displayName = display else {
            return
        }
        PasskeyAPIS.register(username: username, displayName: displayName).request { data, response, error in
            guard let data = data else {
                return
            }
            let decoder = JSONDecoder()
            do {
                let decodedData = try decoder.decode(CredentialCreation.self, from: data)
                print(decodedData.publicKey.challenge)
                completionHandler(decodedData, nil)
            } catch {
                completionHandler(nil, error)
            }            
        }
    }
}
