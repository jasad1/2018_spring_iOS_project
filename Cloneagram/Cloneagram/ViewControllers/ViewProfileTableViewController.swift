//
//  ViewProfileTableViewController.swift
//  Cloneagram
//
//  Created by Student on 2018. 05. 21..
//  Copyright © 2018. Student. All rights reserved.
//

import UIKit

class ViewProfileTableViewController: UITableViewController, PhotoDeletedDelegate {
    
    var user: User!
    
    private var photos = [Photo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Register custom photo cell from xib
        tableView.register(UINib(nibName: Constants.NibNames.PhotoTableViewCell, bundle: Bundle.main),
                           forCellReuseIdentifier: Constants.ReuseIdentifiers.photoCell)
        
        FirebaseManager.shared.loadPhotos(for: user) { (error) in
            if let error = error {
                self.createAndShowErrorAlert(for: "Failed to load photos for user! " + error)
                return
            }
            
            for obj in self.user.photos.values {
                guard let photo = obj as? Photo else {
                    continue
                }
                
                photo.photoDeletedDelegates.append(self)
                self.photos.append(photo)
            }
            self.photos.sort { $0.timestamp > $1.timestamp }
            self.tableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Photo deleted delegate
    
    func photoDeleted(photo: Photo) {
        photos.remove(object: photo)
        tableView.reloadData()
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
        cell.fill(from: photos[indexPath.row], viewController: self, isOnProfile: true)
        return cell
    }

    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return user.isOwn
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            FirebaseManager.shared.deletePhoto(photos[indexPath.row]) { (error) in
                if let error = error {
                    self.createAndShowErrorAlert(for: "Failed to delete photo! " + error)
                    return
                }
                
                self.photos.remove(at: indexPath.row)
                self.tableView.reloadData()
            }
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == Constants.SegueIdentifiers.ViewProfileToViewPhoto {
            let target = segue.destination as! ViewPhotoTableViewController
            target.photo = sender as! Photo
        }
    }
}
