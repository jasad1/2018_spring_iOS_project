//
//  Util.swift
//  Cloneagram
//
//  Created by Student on 2018. 03. 01..
//  Copyright © 2018. Student. All rights reserved.
//

import UIKit

import FirebaseAuth

extension UIViewController {
    func createAndShowErrorAlert(forMessage message: String) -> Void {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
}

extension AuthErrorCode {
    var errorMessage: String {
        switch self {
        case .networkError:
            return "A network error occurred."
        case .tooManyRequests:
            return "Too many requests. Try again later."
        case .invalidEmail:
            return "The e-mail address is invalid."
        case .userNotFound:
            return "The account does not exist."
        case .wrongPassword:
            return "Wrong password."
        case .emailAlreadyInUse:
            return "The email is already in use with another account."
        case .weakPassword:
            return "The password is too weak."
        default:
            return "Unknown error."
        }
    }
}

// E-mail validation is hard and this is not a proper solution, but good enough for user feedback.
// Taken from: https://stackoverflow.com/questions/25471114/how-to-validate-an-e-mail-address-in-swift
private func isValidEmail(email: String) -> Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    
    let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailTest.evaluate(with: email)
}

func validateInputs(email: String, password: String) -> Bool {
    return isValidEmail(email: email) && password.count >= 6 && password.count <= 16
}
