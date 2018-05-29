//
//  LikesTableViewCell.swift
//  Cloneagram
//
//  Created by Student on 2018. 04. 14..
//  Copyright © 2018. Student. All rights reserved.
//

import UIKit

class LikesTableViewCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var numberOfLikesLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    
    private var photo: Photo!
    private var viewController: UIViewController!
    
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

    func fill(from photo: Photo, viewController: UIViewController) {
        self.photo = photo
        self.viewController = viewController
        refresh()
    }
    
    private func refresh() {
        switch photo.likedByUserUids.count {
        case 0:
            numberOfLikesLabel.text = "Not liked yet."
            
        case 1:
            numberOfLikesLabel.text = "Liked by 1 person."
            
        default:
            numberOfLikesLabel.text = "Liked by \(photo.likedByUserUids.count) people."
        }
        
        if photo.isLikedByOwnUser {
            numberOfLikesLabel.textColor = UIColor.blue
            likeButton.setTitle("Unlike", for: .normal)
        } else {
            numberOfLikesLabel.textColor = UIColor.black
            likeButton.setTitle("Like", for: .normal)
        }
    }
    
    @IBAction func likeButtonClicked(_ sender: UIButton) {
        FirebaseManager.shared.likeUnlike(photo: photo) { (error) in
            if let error = error {
                self.viewController.createAndShowErrorAlert(for: "Failed to execute action! " + error)
                return
            }
            
            self.refresh()
        }
    }
}
