//
//  SettingsTableViewController.swift
//  Cloneagram
//
//  Created by Student on 2018. 05. 21..
//  Copyright © 2018. Student. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    private let firebaseManager = FirebaseManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0: // Profile Settings
            switch indexPath.row {
            case 0: // Change Profile Picture
                performSegue(withIdentifier: Constants.SegueIdentifiers.SettingsToChoosePhoto,
                             sender: nil)
                
            case 1: // Change Profile Description
                let alert = UIAlertController(title: "Change Description",
                                              message: nil,
                                              preferredStyle: .alert)
                alert.addTextField(configurationHandler: { (textField) in
                    textField.text = self.firebaseManager.ownUser.description
                })
                alert.addAction(UIAlertAction(title: "Dismiss",
                                              style: .cancel,
                                              handler: nil))
                alert.addAction(UIAlertAction(title: "Submit",
                                              style: .default)
                { (alertAction) in
                    guard let newDescription = alert.textFields?.first?.text else {
                        self.createAndShowErrorAlert(for: "Failed to read new description!")
                        return
                    }

                    guard validateDescription(description: newDescription,
                                              viewController: self) else {
                        return
                    }
                    
                    self.firebaseManager.update(description: newDescription) { (error) in
                        if let error = error {
                            self.createAndShowErrorAlert(for: "Failed to change description! " + error)
                            return
                        }
                    }
                })
                present(alert, animated: true, completion: nil)
                
            case 2: // Change Password
                let alert = UIAlertController(title: "Change Password",
                                              message: nil,
                                              preferredStyle: .alert)
                alert.addTextField(configurationHandler: { (textField) in
                    textField.isSecureTextEntry = true
                })
                alert.addAction(UIAlertAction(title: "Dismiss",
                                              style: .cancel,
                                              handler: nil))
                alert.addAction(UIAlertAction(title: "Submit",
                                              style: .default)
                { (alertAction) in
                    guard let newPassword = alert.textFields?.first?.text else {
                        self.createAndShowErrorAlert(for: "Failed to read new password!")
                        return
                    }
                    
                    guard validatePassword(password: newPassword,
                                           viewController: self) else {
                        return
                    }
                    
                    self.firebaseManager.update(password: newPassword) { (error) in
                        if let error = error {
                            self.createAndShowErrorAlert(for: "Failed to change password! " + error)
                            return
                        }
                    }
                })
                present(alert, animated: true, completion: nil)
                
            default:
                break
            }
        
        case 1: // Profile Actions
            switch indexPath.row {
            case 0: // Delete Profile
                createAndShowYesNoAlert(
                    for: "Are you sure you want to delete your profile?",
                    handler: {
                        self.firebaseManager.deleteProfile{ (error) in
                            if let error = error {
                                self.createAndShowErrorAlert(for: "Failed to delete profile! " + error)
                                return
                            }
                            
                            let appDelegate = UIApplication.shared.delegate as! AppDelegate
                            appDelegate.showSignInScreen()
                        }
                    },
                    destructive: true)
                
            case 1: // Sign Out
                createAndShowYesNoAlert(
                    for: "Are you sure you want to sign out?",
                    handler: {
                        self.firebaseManager.signOut()
                        
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDelegate.showSignInScreen()
                    })
                
            default:
                break
            }
            
        default:
            break
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == Constants.SegueIdentifiers.SettingsToChoosePhoto {
            let target = segue.destination as! ChoosePhotoViewController
            target.chooseProfilePicture = true
        }
    }
}
