//
//  FeedTableViewController.swift
//  Cloneagram
//
//  Created by Student on 2018. 03. 09..
//  Copyright © 2018. Student. All rights reserved.
//

import UIKit

import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

class FeedTableViewController: UITableViewController {

    private var user: User!
    
    private var databaseRef: DatabaseReference!
    private var storageRef: StorageReference!
    
    struct Item {
        var isMine: Bool
        var name: String
        var profilePicture: UIImage?
        var title: String
        var image: UIImage
    }
    var items = [Item]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set bounce color, does not work though
        /*let view = UIView(frame: CGRect(x: 0, y: -480, width: 320, height: 480))
        view.backgroundColor = tableView.backgroundColor
        tableView.addSubview(view)*/
        
        // Initialize Firebase
        databaseRef = Database.database().reference()
        storageRef = Storage.storage().reference()
        
        FirebaseManager.shared.loadOwnUser { (user) in
            if user == nil {
                self.createAndShowErrorAlert(forMessage: "Could not load own user. Try again later!")
                return
            }
            self.user = user
            self.startObservingDatabase()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Firebase

    private func loadUser(uid: String, onLoad: @escaping (User?) -> Void) {
        databaseRef.child("users/\(uid)").observeSingleEvent(of: .value) { (snapshot) in
            var user = User()
            user.uid = uid
            
            for child in snapshot.children {
                let childSnapshot = child as! DataSnapshot
                switch childSnapshot.key {
                case "displayName":
                    user.displayName = childSnapshot.value as! String
                    
                case "description":
                    user.description = (childSnapshot.value as! String)
                    
                case "profilePictureUUID":
                    user.profilePictureUUID = (childSnapshot.value as! String)
                    
                case "images":
                    let dict = childSnapshot.value as! [String: String]
                    user.images.append(contentsOf: dict.values)
                    
                case "followedUsers":
                    let dict = childSnapshot.value as! [String: String]
                    user.followedUsers.append(contentsOf: dict.values)
                    
                default:
                    break
                }
            }
            
            onLoad(user)
        }
    }
    
    private func loadImagesOfUser(_ user: User, _ profilePictureImage: UIImage?) {
        for imageId in user.images {
            self.databaseRef.child("images/\(imageId)").observeSingleEvent(of: .value) { (snapshot) in
                let dict = snapshot.value as! [String: String]
                
                let path = "images/" + dict["uuid"]! + ".jpg"
                
                let imageRef = self.storageRef.child(path)
                imageRef.getData(maxSize: 1 * 1024 * 1024) { (data, error) in
                    if let _ = error {
                        /*let errorMessage = StorageErrorCode(rawValue: error._code)?.errorMessage ?? String(format: "Unknown error (code: %d).", error._code)
                         
                        self.createAndShowErrorAlert(forMessage: errorMessage)*/
                        return
                    }
                    
                    let image = UIImage(data: data!)
                    guard image != nil else {
                        return
                    }
                    
                    self.items.append(Item(isMine: self.user.isOwn, name: user.displayName, profilePicture: profilePictureImage, title: dict["title"]!, image: image!))
                    self.tableView.reloadData()
                    //self.tableView.insertRows(at: [IndexPath(item: self.items.count - 1, section: 0)], with: .bottom)
                }
            }
        }
    }
    
    private func startObservingDatabase() {
        for followedUserId in user.followedUsers {
            loadUser(uid: followedUserId) { (user) in
                guard let user = user else {
                    return
                }
                
                guard let photoUUID = user.profilePictureUUID else {
                    // No profile picture, just load the images
                    self.loadImagesOfUser(user, nil)
                    return
                }
                
                let path = "images/" + photoUUID + ".jpg"
                
                let imageRef = self.storageRef.child(path)
                imageRef.getData(maxSize: 1 * 1024 * 1024) { (data, error) in
                    if error != nil {
                        /*let errorMessage = StorageErrorCode(rawValue: error._code)?.errorMessage ?? String(format: "Unknown error (code: %d).", error._code)
                         
                         self.createAndShowErrorAlert(forMessage: errorMessage)*/
                        
                        self.loadImagesOfUser(user, nil)
                        return
                    }
                    
                    let image = UIImage(data: data!)
                    self.loadImagesOfUser(user, image)
                }
            }
        }
    }
    
    deinit {
        print("deinit called")
        
        // Not needed, because observeSingleEvent is used everywhere
        //databaseRef.removeAllObservers()
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        // TODO: open ViewPhoto
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let item = items[indexPath.row]
        return item.isMine
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            items.remove(at: indexPath.row)
            // TODO: remove from Firebase
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! FeedTableViewCell
        cell.selectionStyle = .none
        
        // Configure the cell...
        let item = items[indexPath.row]
        cell.nameLabel.text = item.name
        cell.profilePictureImageView.image = item.profilePicture
        cell.titleLabel.text = item.title
        cell.photoImageView.image = item.image
        
        return cell
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
