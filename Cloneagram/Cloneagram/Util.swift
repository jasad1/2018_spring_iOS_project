//
//  Util.swift
//  Cloneagram
//
//  Created by Student on 2018. 03. 01..
//  Copyright © 2018. Student. All rights reserved.
//

import UIKit

// MARK: - Error alert

extension UIViewController {
    func createAndShowErrorAlert(for message: String) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func createAndShowYesNoAlert(for message: String,
                                 handler: @escaping () -> Void,
                                 destructive: Bool = false)
    {
        let yesStyle: UIAlertActionStyle = destructive ? .destructive : .default
        
        let alert = UIAlertController(title: message,
                                      message: nil,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes",
                                      style: yesStyle) { (alertAction) in
            handler()
        })
        alert.addAction(UIAlertAction(title: "No",
                                      style: .cancel,
                                      handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

// MARK: - Input validation

// E-mail validation is hard and this is not a proper solution, but good enough for user feedback.
// Taken from: https://stackoverflow.com/questions/25471114/how-to-validate-an-e-mail-address-in-swift
fileprivate func isValidEmail(_ email: String) -> Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
    
    let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
    return emailTest.evaluate(with: email)
}

func validateEmail(email: String, viewController: UIViewController) -> Bool {
    guard !email.isEmpty, isValidEmail(email) else {
        viewController.createAndShowErrorAlert(for: "Invalid e-mail address!")
        return false
    }
    return true
}

func validatePassword(password: String, viewController: UIViewController) -> Bool {
    guard !password.isEmpty,
           password.count >= Constants.PASSWORD_LENGTH_MIN,
           password.count <= Constants.PASSWORD_LENGTH_MAX else
    {
        viewController.createAndShowErrorAlert(for: "Password length must be between \(Constants.PASSWORD_LENGTH_MIN) and \(Constants.PASSWORD_LENGTH_MAX)!")
        return false
    }
    return true
}

func validateName(name: String, viewController: UIViewController) -> Bool {
    guard !name.isEmpty, name.count <= Constants.NAME_LENGTH_MAX else {
        viewController.createAndShowErrorAlert(for: "The given name is longer than \(Constants.NAME_LENGTH_MAX) characters!")
        return false
    }
    return true
}

func validateDescription(description: String, viewController: UIViewController) -> Bool {
    guard description.count <= Constants.DESCRIPTION_LENGTH_MAX else {
        viewController.createAndShowErrorAlert(for: "New description is longer than \(Constants.DESCRIPTION_LENGTH_MAX) characters!")
        return false
    }
    return true
}

// MARK: - Object removal from Array

extension Array where Element: Equatable {
    // Remove first collection element that is equal to the given `object`:
    mutating func remove(object: Element) {
        if let index = index(of: object) {
            remove(at: index)
        }
    }
}
