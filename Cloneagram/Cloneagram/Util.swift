//
//  Util.swift
//  Cloneagram
//
//  Created by Student on 2018. 03. 01..
//  Copyright © 2018. Student. All rights reserved.
//

import UIKit

import FirebaseAuth
import FirebaseStorage

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
            return String(format: "Unknown error (code: %d).", self.rawValue)
        }
    }
}

extension StorageErrorCode {
    var errorMessage: String {
        switch self {
        case .unauthenticated:
            return "You are not logged in."
        case .unauthorized:
            return "You do not have permission to do this."
        case .retryLimitExceeded:
            return "Retry limit exceeded. Try again later."
        default:
            return String(format: "Unknown error (code: %d).", self.rawValue)
        }
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
