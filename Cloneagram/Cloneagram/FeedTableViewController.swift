//
//  FeedTableViewController.swift
//  Cloneagram
//
//  Created by Student on 2018. 03. 09..
//  Copyright © 2018. Student. All rights reserved.
//

import UIKit

class FeedTableViewController: UITableViewController, FeedItemDelegate {

    private var firebaseManager = FirebaseManager.shared
    private var items: [Item] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set bounce color, does not work though
        /*let view = UIView(frame: CGRect(x: 0, y: -480, width: 320, height: 480))
        view.backgroundColor = tableView.backgroundColor
        tableView.addSubview(view)*/
        
        // Register custom image cell
        tableView.register(UINib(nibName: "ImageTableViewCell", bundle: Bundle.main),
                           forCellReuseIdentifier: "imageCell")
        
        // Initialize Firebase
        firebaseManager.loadOwnUser { (user) in
            if user == nil {
                self.createAndShowErrorAlert(forMessage: "Could not load own user. Try again later!")
                return
            }
            self.firebaseManager.delegate = self
            self.firebaseManager.startObservingDatabase()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        print("deinit called")
        
        // Not needed, because observeSingleEvent is used everywhere
        //databaseRef.removeAllObservers()
    }
    
    // MARK: - Feed item delegate
    
    func feedItem(item: Item) {
        items.append(item)
        tableView.reloadData()
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "FeedToViewPhoto",
                     sender: items[indexPath.row])
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let item = items[indexPath.row]
        return item.user.isOwn
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            firebaseManager.removeImage(items[indexPath.row].image)
            items.remove(at: indexPath.row)
            tableView.reloadData()
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "imageCell",
                                                 for: indexPath) as! ImageTableViewCell
        cell.selectionStyle = .none
        
        // Configure the cell...
        let item = items[indexPath.row]
        cell.nameLabel.text = item.user.name
        cell.profilePictureImageView.image = item.profilePicture
        cell.titleLabel.text = item.image.title
        cell.photoImageView.image = item.uiImage
        
        return cell
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        let target = segue.destination as! ViewPhotoTableViewController
        target.item = sender as! Item
    }
}
