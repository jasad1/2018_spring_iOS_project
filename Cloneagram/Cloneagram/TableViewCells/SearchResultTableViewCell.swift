//
//  SearchResultTableViewCell.swift
//  Cloneagram
//
//  Created by Student on 2018. 05. 22..
//  Copyright © 2018. Student. All rights reserved.
//

import UIKit

class SearchResultTableViewCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var profilePictureImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.layer.cornerRadius = 6.0
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func fill(from user: User, viewController: UIViewController) {
        nameLabel.text = user.name
        // Set blank image otherwise the UIImage does not get created
        profilePictureImageView.image = #imageLiteral(resourceName: "BlankProfilePicture")
        
        FirebaseManager.shared.loadPhoto(for: user.profilePictureStorageUuid,
                                         into: profilePictureImageView) { (error) in
            if let error = error {
                viewController.createAndShowErrorAlert(for: "Failed to load photo! " + error)
            }
        }
    }
}
