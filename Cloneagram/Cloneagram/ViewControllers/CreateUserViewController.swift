//
//  RegisterViewController.swift
//  Cloneagram
//
//  Created by Student on 2018. 03. 01..
//  Copyright © 2018. Student. All rights reserved.
//

import UIKit

class CreateUserViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButtonClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func createUserButtonClicked(_ sender: UIButton) {
        guard let name = nameTextField.text,
              let email = emailTextField.text,
              let password = passwordTextField.text else {
                return
        }
        
        guard validateName(name: name, viewController: self),
              validateEmail(email: email, viewController: self),
              validatePassword(password: password, viewController: self) else {
            return
        }
        
        FirebaseManager.shared.createUser(name: name, email: email, password: password) { (error) in
            if let error = error {
                self.createAndShowErrorAlert(for: "Failed to create user! " + error)
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
