//
//  RegisterViewController.swift
//  Cloneagram
//
//  Created by Student on 2018. 03. 01..
//  Copyright © 2018. Student. All rights reserved.
//

import UIKit

import FirebaseAuth
import FirebaseDatabase

class RegisterViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    private var databaseRef: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        databaseRef = Database.database().reference()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButtonClicked(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func registerButtonClicked(_ sender: UIButton) {
        guard let name = nameTextField.text,
              let email = emailTextField.text,
              let password = passwordTextField.text else {
                return
        }
        
        guard validateInputs(email: email, password: password, viewController: self) else {
            return
        }
        
        if name.count > 64 {
            createAndShowErrorAlert(forMessage: "The given name is too long!")
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if let error = error {
                let errorMessage = AuthErrorCode(rawValue: error._code)?.errorMessage ?? String(format: "Unknown error (code: %d).", error._code)
                
                self.createAndShowErrorAlert(forMessage: errorMessage)
                return
            }
            
            let request = user!.createProfileChangeRequest()
            request.displayName = name
            request.commitChanges { (error) in
                if let error = error {
                    let errorMessage = AuthErrorCode(rawValue: error._code)?.errorMessage ?? String(format: "Unknown error (code: %d).", error._code)
                    
                    self.createAndShowErrorAlert(forMessage: errorMessage)
                    return
                }

                self.databaseRef.child("users/\(user!.uid)/displayName").setValue(name) { (error, ref) in
                    if error != nil {
                        self.createAndShowErrorAlert(forMessage: "Could not save user data.")
                        return
                    }
                    
                    self.databaseRef.child("users/\(user!.uid)/followedUsers")
                        .childByAutoId().setValue(user!.uid) { (error, ref) in
                            if error != nil {
                                self.createAndShowErrorAlert(forMessage: "Could not save user data.")
                                return
                            }
                            
                            let appDelegate = UIApplication.shared.delegate as! AppDelegate
                            appDelegate.showMainScreen()
                    }
                }
            }
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
