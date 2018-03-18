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
    private var ownUserModel: UserModel!
    
    private var databaseRef: DatabaseReference!
    private var storageRef: StorageReference!
    
    struct Item {
        var name: String
        var profilePicture: UIImage?
        var title: String
        var image: UIImage
    }
    var items = [Item]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set bounce color
        /*let view = UIView(frame: CGRect(x: 0, y: -480, width: 320, height: 480))
        view.backgroundColor = tableView.backgroundColor
        tableView.addSubview(view)*/
        
        // Initialize Firebase
        user = Auth.auth().currentUser!
       
        databaseRef = Database.database().reference()
        storageRef = Storage.storage().reference()
        
        loadUser(uid: user.uid) { (userModel) in
            if userModel == nil {
                self.createAndShowErrorAlert(forMessage: "Could not load own user. Try again later!")
                return
            }
            self.ownUserModel = userModel
            self.startObservingDatabase()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Firebase
    
    struct UserModel {
        var displayName: String = ""
        var description: String? = nil
        var photoUUID: String? = nil
        var images: [String] = []
        var followedUsers: [String] = []
    }
    
    private func loadUser(uid: String, onLoad: @escaping (UserModel?) -> Void) {
        databaseRef.child("users/\(uid)").observeSingleEvent(of: .value) { (snapshot) in
            var userModel = UserModel()
            
            for child in snapshot.children {
                let childSnapshot = child as! DataSnapshot
                switch childSnapshot.key {
                case "displayName":
                    userModel.displayName = childSnapshot.value as! String
                    
                case "description":
                    userModel.description = (childSnapshot.value as! String)
                    
                case "photoUUID":
                    userModel.photoUUID = (childSnapshot.value as! String)
                    
                case "images":
                    let dict = childSnapshot.value as! [String: String]
                    userModel.images.append(contentsOf: dict.values)
                    
                case "followedUsers":
                    let dict = childSnapshot.value as! [String: String]
                    userModel.followedUsers.append(contentsOf: dict.values)
                    
                default:
                    break
                }
            }
            
            onLoad(userModel)
        }
    }
    
    private func startObservingDatabase() {
        let loadImagesOfUser: (UserModel, UIImage?) -> Void = { (userModel, profilePictureImage) in
            for imageId in userModel.images {
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
                        
                        self.items.append(Item(name: userModel.displayName, profilePicture: profilePictureImage, title: dict["title"]!, image: image!))
                        self.tableView.insertRows(at: [IndexPath(item: self.items.count - 1, section: 0)], with: .bottom)
                    }
                }
            }
        }
        
        for followedUserId in ownUserModel.followedUsers {
            loadUser(uid: followedUserId) { (userModel) in
                guard let userModel = userModel else {
                    return
                }
                
                if let photoUUID = userModel.photoUUID {
                    let path = "images/" + photoUUID + ".jpg"
                    
                    let imageRef = self.storageRef.child(path)
                    imageRef.getData(maxSize: 1 * 1024 * 1024) { (data, error) in
                        if let _ = error {
                            /*let errorMessage = StorageErrorCode(rawValue: error._code)?.errorMessage ?? String(format: "Unknown error (code: %d).", error._code)
                             
                             self.createAndShowErrorAlert(forMessage: errorMessage)*/
                            
                            loadImagesOfUser(userModel, nil)
                            return
                        }
                        
                        let image = UIImage(data: data!)
                        loadImagesOfUser(userModel, image)
                    }
                } else {
                    loadImagesOfUser(userModel, nil)
                }
            }
        }
    }
    
    deinit {
        databaseRef.removeAllObservers()
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
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
