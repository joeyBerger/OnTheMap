//
//  LoginViewController.swift
//  PinSample
//
//  Created by Joey Berger on 4/9/20.
//  Copyright © 2020 Udacity. All rights reserved.
//

import Foundation
import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var usernametextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    let textFieldDelegate = TextFieldDelegate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usernametextField.delegate = textFieldDelegate
        passwordTextField.delegate = textFieldDelegate
        self.view.backgroundColor = UIColor.systemBlue
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        errorLabel.alpha = 0
        controlInputObjects(true)
        determineLoginEnabled()
    }
    
    @IBAction func handleUsernameInput(_ sender: Any) {
        determineLoginEnabled()
    }
    
    @IBAction func handleLoginButton(_ sender: Any) {
        controlInputObjects(false)
        UdacityClient.postSession(username: usernametextField.text!, password: passwordTextField.text!) { infoStr, error in
            if error != nil {
                //update UI
                self.handleErrorText(inputStr:"Error while logging in")
                self.controlInputObjects(true)
                return
            }
            if (infoStr == "fail") {
                self.handleErrorText(inputStr:"Wrong username or password")
                self.controlInputObjects(true)
                return
            }
            UdacityClient.getUserData()
            self.handleLoginSuccess()
        }
    }
    
    func handleLoginSuccess() {
        if let tabViewController = storyboard?.instantiateViewController(withIdentifier: "UITabbarController") as? UITabBarController {
            tabViewController.modalPresentationStyle = .fullScreen
            present(tabViewController, animated: false, completion: nil)
        }
    }
    
    func handleErrorText(inputStr: String) {
        errorLabel.text = inputStr
        errorLabel.alpha = 1
    }
    
    func determineLoginEnabled() {
        loginButton.isEnabled = usernametextField.text! != "" && passwordTextField.text! != ""
    }
    
    func setTextFieldsEnabled(_ enabled: Bool) {
        usernametextField.isUserInteractionEnabled = enabled
        passwordTextField.isUserInteractionEnabled = enabled
    }
    
    func setActivityIndicatorEnabled(_ enabled: Bool) {
        activityIndicator.isHidden = !enabled
        if enabled {
            activityIndicator.startAnimating()
            return
        }
        activityIndicator.stopAnimating()
    }
    
    func controlInputObjects(_ enabled: Bool) {
        setTextFieldsEnabled(enabled)
        loginButton.isEnabled = enabled
        setActivityIndicatorEnabled(!enabled)
    }
}

class TextFieldDelegate: NSObject, UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
           textField.resignFirstResponder()
           return true
       }
}
