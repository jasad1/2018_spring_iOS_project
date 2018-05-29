//
//  LoginViewController.swift
//  Cloneagram
//
//  Created by Student on 2018. 03. 01..
//  Copyright © 2018. Student. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Set up back button title for create user screen
        self.navigationItem.backBarButtonItem = UIBarButtonItem(
            title: "Back", style: .plain, target: nil, action: nil)
    }
    
    /*override func viewWillDisappear(_ animated: Bool) {
        // Fix iOS 11.2 bug of UIBarButtonItem staying highlighted after navigation.
        // The fix does not work though.
        navigationController?.navigationBar.tintAdjustmentMode = .normal
        navigationController?.navigationBar.tintAdjustmentMode = .automatic
    }*/
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signInButtonClicked(_ sender: UIButton) {
        guard let email = emailTextField.text,
              let password = passwordTextField.text else {
            return
        }
        
        guard validateEmail(email: email, viewController: self),
              validatePassword(password: password, viewController: self) else {
                return
        }
        
        FirebaseManager.shared.signIn(email: email, password: password) { (error) in
            if let error = error {
                self.createAndShowErrorAlert(for: "Failed to sign in! " + error)
                return
            }
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.showMainScreen()
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
