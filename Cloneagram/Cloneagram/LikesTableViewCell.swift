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
    
    var modelImage: Image!
    
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
        modelImage = image
        refresh()
    }
    
    func refresh() {
        switch modelImage.likes.count {
        case 0:
            numberOfLikesLabel.text = "Not liked yet."
            
        case 1:
            numberOfLikesLabel.text = "Liked by 1 person."
            
        default:
            numberOfLikesLabel.text = "Liked by \(modelImage.likes.count) people."
        }
        
        if modelImage.likedByMe {
            numberOfLikesLabel.textColor = UIColor.blue
            likeButton.setTitle("Unlike", for: .normal)
        } else {
            numberOfLikesLabel.textColor = UIColor.black
            likeButton.setTitle("Like", for: .normal)
        }
    }
    
    @IBAction func likeButtonClicked(_ sender: UIButton) {
        FirebaseManager.shared.likeUnlike(modelImage)
        refresh()
    }
}
