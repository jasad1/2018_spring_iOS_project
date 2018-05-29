//
//  FeedTableViewController.swift
//  Cloneagram
//
//  Created by Student on 2018. 03. 09..
//  Copyright © 2018. Student. All rights reserved.
//

import UIKit

class FeedTableViewController: UITableViewController, FeedDelegate, PhotoDeletedDelegate {

    private var firebaseManager = FirebaseManager.shared
    private var photos: [Photo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set bounce color, does not work though
        /*let view = UIView(frame: CGRect(x: 0, y: -480, width: 320, height: 480))
        view.backgroundColor = tableView.backgroundColor
        tableView.addSubview(view)*/
        
        // Set up back button title
        /*self.navigationItem.backBarButtonItem = UIBarButtonItem(
            title: "Back", style: .plain, target: nil, action: nil)*/
        
        // Register custom photo cell from xib
        tableView.register(UINib(nibName: Constants.NibNames.PhotoTableViewCell, bundle: Bundle.main),
                           forCellReuseIdentifier: Constants.ReuseIdentifiers.photoCell)
        
        // Initialize Firebase
        firebaseManager.loadOwnUser { (user) in
            if user == nil {
                self.createAndShowErrorAlert(for: "Could not load own user. Try again later!")
                return
            }
            self.firebaseManager.delegate = self
            self.firebaseManager.loadPhotosOfFollowedUsers()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Photo delegate
    
    func photo(photo: Photo) {
        photo.photoDeletedDelegates.append(self)
        
        photos.append(photo)
        photos.sort { $0.timestamp > $1.timestamp }
        
        tableView.reloadData()
    }
    
    func reset() {
        photos.removeAll()
        tableView.reloadData()
    }
    
    func reloadProfilePictures() {
        tableView.visibleCells.forEach { (cell) in
            (cell as! PhotoTableViewCell).loadProfilePicture()
        }
    }
    
    // MARK: - Photo deleted delegate
    
    func photoDeleted(photo: Photo) {
        photos.remove(object: photo)
        tableView.reloadData()
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let photo = photos[indexPath.row]
        return photo.owner.isOwn
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            firebaseManager.deletePhoto(photos[indexPath.row]) { (error) in
                if let error = error {
                    self.createAndShowErrorAlert(for: "Failed to delete photo! " + error)
                    return
                }
                
                self.photos.remove(at: indexPath.row)
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.ReuseIdentifiers.photoCell,
                                                 for: indexPath) as! PhotoTableViewCell
        cell.selectionStyle = .none
        
        let photo = photos[indexPath.row]
        cell.fill(from: photo, viewController: self)
        
        return cell
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == Constants.SegueIdentifiers.FeedToViewPhoto {
            let target = segue.destination as! ViewPhotoTableViewController
            target.photo = sender as! Photo
        } else if segue.identifier == Constants.SegueIdentifiers.FeedToViewProfile {
            let target = segue.destination as! ViewProfileViewController
            target.user = sender as! User
        }
    }
}
