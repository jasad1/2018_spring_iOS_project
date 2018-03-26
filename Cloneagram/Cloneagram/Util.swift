//
//  Util.swift
//  Cloneagram
//
//  Created by Student on 2018. 03. 01..
//  Copyright © 2018. Student. All rights reserved.
//

import UIKit

extension UIViewController {
    func createAndShowErrorAlert(forMessage message: String) -> Void {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
}

// E-mail validation is hard and this is not a proper solution, but good enough for user feedback.
// Taken from: https://stackoverflow.com/questions/25471114/how-to-validate-an-e-mail-address-in-swift
fileprivate func isValidEmail(_ email: String) -> Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    
    let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailTest.evaluate(with: email)
}

func validateInputs(email: String, password: String, viewController: UIViewController) -> Bool {
    guard isValidEmail(email) else {
        viewController.createAndShowErrorAlert(forMessage: "Invalid e-mail address!")
        return false
    }
    
    guard password.count >= 6 && password.count <= 16 else {
        viewController.createAndShowErrorAlert(forMessage: "Password length must be between 6 and 16!")
        return false
    }
    
    return true
}
