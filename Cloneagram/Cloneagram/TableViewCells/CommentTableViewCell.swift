//
//  CommentTableViewCell.swift
//  Cloneagram
//
//  Created by Student on 2018. 04. 14..
//  Copyright © 2018. Student. All rights reserved.
//

import UIKit

class CommentTableViewCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profilePictureImageView: UIImageView!
    @IBOutlet weak var commentLabel: UILabel!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        containerView.layer.cornerRadius = 6.0
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func fill(from comment: Comment, viewController: UIViewController) {
        nameLabel.text = comment.owner.name
        commentLabel.text = comment.text
        
        // Set blank image otherwise the UIImage does not get created
        profilePictureImageView.image = #imageLiteral(resourceName: "BlankProfilePicture")
        
        FirebaseManager.shared.loadPhoto(for: comment.owner.profilePictureStorageUuid,
                                         into: profilePictureImageView) { (error) in
            if let error = error {
                viewController.createAndShowErrorAlert(for: "Failed to load photo! " + error)
            }
        }
    }
}
