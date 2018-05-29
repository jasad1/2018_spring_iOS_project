//
//  PhotoTableViewCell.swift
//  Cloneagram
//
//  Created by Student on 2018. 03. 27..
//  Copyright © 2018. Student. All rights reserved.
//

import UIKit

class PhotoTableViewCell: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profilePictureImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    
    private var isOnProfile = false
    private var photo: Photo!
    private var viewController: UIViewController!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.layer.cornerRadius = 6.0
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        let userClickRecognizer = UITapGestureRecognizer(target: self,
                        action: #selector(userClicked(recognizer:)))
        containerView.addGestureRecognizer(userClickRecognizer)
        
        let photoClickRecognizer = UITapGestureRecognizer(target: self,
                        action: #selector(photoImageViewClicked(recognizer:)))
        photoImageView.isUserInteractionEnabled = true
        photoImageView.addGestureRecognizer(photoClickRecognizer)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func fill(from photo: Photo,
              viewController: UIViewController,
              isOnProfile: Bool = false)
    {
        self.isOnProfile = isOnProfile
        self.photo = photo
        self.viewController = viewController
        
        if isOnProfile {
            nameLabel.isHidden = true
            profilePictureImageView.isHidden = true
        } else {
            nameLabel.text = photo.owner.name
            loadProfilePicture()
        }
        
        titleLabel.text = photo.title
        // Set blank image otherwise the UIImage does not get created
        photoImageView.image = #imageLiteral(resourceName: "BlankPhoto")

        FirebaseManager.shared.loadPhoto(for: photo.storageUuid,
                                         into: photoImageView) { (error) in
            if let error = error {
                self.viewController.createAndShowErrorAlert(for: "Failed to load photo! " + error)
            }
        }
    }
    
    func loadProfilePicture() {
        // Set blank image otherwise the UIImage does not get created
        profilePictureImageView.image = #imageLiteral(resourceName: "BlankProfilePicture")
        
        FirebaseManager.shared.loadPhoto(for: photo.owner.profilePictureStorageUuid,
                                         into: profilePictureImageView)
            { (error) in
            if let error = error {
                self.viewController.createAndShowErrorAlert(for: "Failed to load profile picture! " + error)
            }
        }
    }
    
    @objc private func userClicked(recognizer: UITapGestureRecognizer) {
        if isOnProfile {
            return
        }
        
        let rect = CGRect(x: 0.0, y: 0.0,
                          width: containerView.bounds.size.width,
                          height: profilePictureImageView.bounds.size.height)
        let touchPoint = recognizer.location(in: containerView)
        if rect.contains(touchPoint) {
            switch viewController {
            case is FeedTableViewController:
                viewController.performSegue(
                    withIdentifier: Constants.SegueIdentifiers.FeedToViewProfile,
                    sender: photo.owner)

            case is ViewPhotoTableViewController:
                viewController.performSegue(
                    withIdentifier: Constants.SegueIdentifiers.ViewPhotoToViewProfile,
                    sender: photo.owner)
                
            default:
                fatalError("switch viewController == default. This should not happen!")
            }
        }
    }
    
    @objc private func photoImageViewClicked(
        recognizer: UITapGestureRecognizer)
    {
        if isOnProfile {
            viewController.performSegue(
                withIdentifier: Constants.SegueIdentifiers.ViewProfileToViewPhoto,
                sender: photo)
        } else { // The cell is on the feed
            viewController.performSegue(
                withIdentifier: Constants.SegueIdentifiers.FeedToViewPhoto,
                sender: photo)
        }
    }
}
