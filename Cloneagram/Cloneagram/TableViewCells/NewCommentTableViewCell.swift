//
//  NewCommentTableViewCell.swift
//  Cloneagram
//
//  Created by Student on 2018. 05. 20..
//  Copyright © 2018. Student. All rights reserved.
//

import UIKit

class NewCommentTableViewCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var newCommentTextField: UITextField!
    
    private var photo: Photo!
    private var tableViewController: UITableViewController!
    
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
    
    func fill(from photo: Photo,
              tableViewController: UITableViewController)
    {
        self.photo = photo
        self.tableViewController = tableViewController
    }
    
    @IBAction func postButtonClicked(_ sender: UIButton) {
        guard let text = newCommentTextField.text, !text.isEmpty else {
            return
        }
        
        if text.count > Constants.COMMENT_LENGTH_MAX {
            tableViewController.createAndShowErrorAlert(for: "Comment is longer than \(Constants.COMMENT_LENGTH_MAX) characters!")
            return
        }
        
        FirebaseManager.shared.addComment(photo: photo, text: text) { (error) in
            if let error = error {
                self.tableViewController.createAndShowErrorAlert(for: "Failed to post comment! " + error)
                return
            }
            
            self.photo.comments.sort { $0.timestamp > $1.timestamp }
            self.tableViewController.tableView.reloadData()
        }
    }
}
