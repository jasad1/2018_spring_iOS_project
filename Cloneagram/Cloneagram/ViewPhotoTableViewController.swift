//
//  ViewPhotoTableViewController.swift
//  Cloneagram
//
//  Created by Student on 2018. 03. 24..
//  Copyright © 2018. Student. All rights reserved.
//

import UIKit

class ViewPhotoTableViewController: UITableViewController {

    var item: Item!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Register custom image cell
        tableView.register(UINib(nibName: "ImageTableViewCell", bundle: Bundle.main),
                           forCellReuseIdentifier: "imageCell")
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
        // image cell, likes cell, comments cells, new comment cell
        return 1 + 1 + item.image.comments.count + 1
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell = { switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "imageCell",
                                                     for: indexPath) as! ImageTableViewCell
            
            // Configure the cell...
            cell.nameLabel.text = item.user.name
            cell.profilePictureImageView.image = item.profilePicture
            cell.titleLabel.text = item.image.title
            cell.photoImageView.image = item.uiImage
            
            return cell
            
        default:
            return UITableViewCell()
        } }()

        cell.selectionStyle = .none
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
