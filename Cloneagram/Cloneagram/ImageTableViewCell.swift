//
//  ImageTableViewCell.swift
//  Cloneagram
//
//  Created by Student on 2018. 03. 27..
//  Copyright © 2018. Student. All rights reserved.
//

import UIKit

import SDWebImage

class ImageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profilePictureImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    
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
    
    func load(fromImage image: Image) {
        nameLabel.text = image.owner.name
        titleLabel.text = image.title

        // Set blank images otherwise the UIImages do not get created
        profilePictureImageView.image = #imageLiteral(resourceName: "BlankProfilePicture")
        photoImageView.image = #imageLiteral(resourceName: "BlankPhoto")

        if let pPSUuid = image.owner.profilePictureStorageUuid {
            FirebaseManager.shared.loadImage(forUuid: pPSUuid,
                                             into: profilePictureImageView)
        }
        FirebaseManager.shared.loadImage(forUuid: image.storageUuid,
                                         into: photoImageView)
    }

}
