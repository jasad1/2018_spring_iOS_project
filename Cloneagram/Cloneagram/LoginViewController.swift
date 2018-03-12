//
//  LoginViewController.swift
//  Cloneagram
//
//  Created by Student on 2018. 03. 01..
//  Copyright © 2018. Student. All rights reserved.
//

import UIKit

import FirebaseAuth
import Firebase

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if user != nil {
                self.performSegue(withIdentifier: "LoginToMainScreen", sender: self)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginButtonClicked(_ sender: UIButton) {
        guard let email = emailTextField.text,
              let password = passwordTextField.text else {
            return
        }
        
        guard validateInputs(email: email, password: password, viewController: self) else {
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if let error = error {
                let errorMessage = AuthErrorCode(rawValue: error._code)?.errorMessage ?? String(format: "Unknown error (code: %d).", error._code)
                
                self.createAndShowErrorAlert(forMessage: errorMessage)
                return
            }

            self.performSegue(withIdentifier: "LoginToMainScreen", sender: self)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
