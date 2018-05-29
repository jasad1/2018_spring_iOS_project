//
//  ViewPhotoTableViewController.swift
//  Cloneagram
//
//  Created by Student on 2018. 03. 24..
//  Copyright © 2018. Student. All rights reserved.
//

import UIKit

class ViewPhotoTableViewController: UITableViewController {

    var photo: Photo!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Register custom photo cell from xib
        tableView.register(UINib(nibName: Constants.NibNames.PhotoTableViewCell, bundle: Bundle.main),
                           forCellReuseIdentifier: Constants.ReuseIdentifiers.photoCell)
        
        // Set up right button title for view photo screen
        if photo.owner.isOwn {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(
                title: "Delete Photo", style: .plain, target: self,
                action: #selector(rightBarButtonClicked(sender:)))
        }
        
        FirebaseManager.shared.loadComments(for: photo) { (error) in
            if let error = error {
                self.createAndShowErrorAlert(for: "Failed to load comments for photo! " + error)
                return
            }
            
            self.photo.comments.sort { $0.timestamp > $1.timestamp }
            self.tableView.reloadData()
        }
    }
    
    @objc private func rightBarButtonClicked(sender: UIBarButtonItem) {
        createAndShowYesNoAlert(
            for: "Are you sure you want to delete the photo?",
            handler: {
                FirebaseManager.shared.deletePhoto(self.photo) { (error) in
                    if let error = error {
                        self.createAndShowErrorAlert(for: "Failed to delete photo! " + error)
                        return
                    }
                    
                    self.dismiss(animated: true, completion: nil)
                }
            },
            destructive: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // photo cell, likes cell, comments cells, new comment cell
        return 1 + 1 + photo.comments.count + 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell = { switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.ReuseIdentifiers.photoCell,
                                                     for: indexPath) as! PhotoTableViewCell
            cell.fill(from: photo, viewController: self)
            return cell
            
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.ReuseIdentifiers.likesCell,
                                                     for: indexPath) as! LikesTableViewCell
            cell.fill(from: photo, viewController: self)
            return cell
            
        case 2 ..< 2 + photo.comments.count:
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.ReuseIdentifiers.commentCell,
                                                     for: indexPath) as! CommentTableViewCell
            cell.fill(from: photo.comments[indexPath.row - 2], viewController: self)
            return cell
            
        case 2 + photo.comments.count:
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.ReuseIdentifiers.newCommentCell,
                                                     for: indexPath) as! NewCommentTableViewCell
            cell.fill(from: photo, tableViewController: self)
            return cell
            
        default:
            return UITableViewCell()
        } }()

        cell.selectionStyle = .none
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 300
            
        case 1:
            return 44
            
        case 2 ..< 2 + photo.comments.count:
            return 120
            
        case 2 + photo.comments.count:
            return 52
            
        default:
            return 44
        }
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return 2 <= indexPath.row && indexPath.row < 2 + photo.comments.count
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            FirebaseManager.shared.deleteComment(comment: photo.comments[indexPath.row - 2]) { (error) in
                if let error = error {
                    self.createAndShowErrorAlert(for: "Failed to delete comment! " + error)
                    return
                }
                
                self.tableView.reloadData()
            }
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == Constants.SegueIdentifiers.ViewPhotoToViewProfile {
            let target = segue.destination as! ViewProfileViewController
            target.user = sender as! User
        }
    }
}
