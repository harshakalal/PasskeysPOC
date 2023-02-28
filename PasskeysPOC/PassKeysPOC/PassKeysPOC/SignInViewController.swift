//
//  SignInViewController.swift
//  PassKeysPOC
//
//  Created by Harsha AM on 31/01/23.
//

import UIKit

class SignInViewController: UIViewController {
    @IBOutlet weak var userNameField: UITextField!
    
    private var observer: NSObjectProtocol?
    let accountManager = AccountManager()
    let signInViewModel = SignInViewModel()
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupTextField()
//        userNameField.textContentType = .username
        observer = NotificationCenter.default.addObserver(forName: .UserSignedIn, object: nil, queue: nil) {_ in
            self.didFinishSignIn()
        }
        guard let window = self.view.window else { fatalError("The view was not in the app's view hierarchy!") }
        (UIApplication.shared.delegate as? AppDelegate)?.accountManager.signInWith(anchor: window)
    }
    
    func setupTextField() {
        userNameField.layer.cornerRadius = userNameField.frame.size.height / 2
        userNameField.layer.masksToBounds = true
        userNameField.layer.borderWidth = 2
        userNameField.layer.borderColor = UIColor.gray.cgColor
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if let observer = observer {
            NotificationCenter.default.removeObserver(observer)
        }
        
        super.viewDidDisappear(animated)
    }

    @IBAction func createAccount(_ sender: Any) {
        guard let userName = userNameField.text else {
            return
        }
        signInViewModel.usernameString = userName
        signInViewModel.displayName = "axvhvxk"
        guard let window = self.view.window else { fatalError("The view was not in the app's view hierarchy!") }
        (UIApplication.shared.delegate as? AppDelegate)?.accountManager.signUpWith(userName: userName, anchor: window)
        
    }

    @IBAction func signIn(_ sender: UIButton) {
        guard let window = self.view.window else { fatalError("The view was not in the app's view hierarchy!") }
//        didFinishSignIn()
        (UIApplication.shared.delegate as? AppDelegate)?.accountManager.signInWith(anchor: window)
    }

    func didFinishSignIn() {
        DispatchQueue.main.async {
            self.view.window?.rootViewController = UIStoryboard(name: "Main", bundle: nil)
                .instantiateViewController(withIdentifier: "UserHomeViewController")
        }
    }

    @IBAction func tappedBackground(_ sender: Any) {
        self.view.endEditing(true)
    }
}
