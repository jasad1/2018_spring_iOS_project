//
//  ViewProfileViewController.swift
//  Cloneagram
//
//  Created by Student on 2018. 05. 21..
//  Copyright © 2018. Student. All rights reserved.
//

import UIKit

class ViewProfileViewController: UIViewController {

    @IBOutlet weak var profilePictureImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var user: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        nameLabel.text = user.name
        descriptionLabel.text = user.description
        
        // Set blank image otherwise the UIImage does not get created
        profilePictureImageView.image = #imageLiteral(resourceName: "BlankProfilePicture")
        
        FirebaseManager.shared.loadPhoto(for: user.profilePictureStorageUuid,
                                         into: profilePictureImageView) { (error) in
            if let error = error {
                self.createAndShowErrorAlert(for: "Failed to load photo! " + error)
            }
        }
        
        setRightBarButton()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // TODO: does not work
    private func setRightBarButton() {
        let isFollowed = FirebaseManager.shared.ownUser
            .followedUserUids.contains(user.uid)
        let title = isFollowed ? "Unfollow" : "Follow"
        
        if !user.isOwn {
            navigationController?.navigationItem
                .rightBarButtonItem = UIBarButtonItem(
                title: title, style: .plain, target: nil,
                action: #selector(rightBarButtonClicked(sender:)))
        }
    }
    
    @objc private func rightBarButtonClicked(sender: UIBarButtonItem) {
        FirebaseManager.shared.followUnfollow(userToFollow: user) { (error) in
            if let error = error {
                self.createAndShowErrorAlert(for: "Failed to execute action! " + error)
                return
            }
            
            self.setRightBarButton()
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == Constants.SegueIdentifiers.ViewProfileEmbed {
            let target = segue.destination as! ViewProfileTableViewController
            target.user = user
        }
    }
}
