//
//  HomeViewController.swift
//  PassKeysPOC
//
//  Created by Harsha AM on 31/01/23.
//

import UIKit

class HomeViewController: UIViewController {
    @IBAction func signOut(_ sender: Any) {
        self.view.window?.rootViewController = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "SignInViewController")
    }
}
