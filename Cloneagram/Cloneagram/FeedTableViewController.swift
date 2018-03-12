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
    private var handle: DatabaseHandle?
    
    struct Item {
        var title: String
        var image: UIImage
    }
    var items = [Item]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize Firebase
        user = Auth.auth().currentUser!
        databaseRef = Database.database().reference()
        startObservingDatabase()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Firebase
    private func startObservingDatabase()  {
        handle = databaseRef.child("users/\(user.uid)/images").observe(.value) { (snapshot) in
            for child in snapshot.children {
                let childSnapshot = child as! DataSnapshot
                let imageId = childSnapshot.value as! String
                
                self.databaseRef.child("images/\(imageId)").observeSingleEvent(of: .value) { (snapshot) in
                    let dict = snapshot.value as! [String: String]
                    
                    let imageRef = Storage.storage().reference(forURL: dict["url"]!)
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
                        
                        self.items.append(Item(title: dict["title"]!, image: image!))
                        self.tableView.insertRows(at: [IndexPath(item: self.items.count - 1, section: 0)], with: .bottom)
                    }
                }
            }
        }
    }
    
    deinit {
        if handle != nil {
            databaseRef.child("users/\(user.uid)/images").removeObserver(withHandle: handle!)
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

        // Configure the cell...
        let item = items[indexPath.row]
        cell.titleLabel.text = item.title
        cell.photoImageView.image = item.image
        
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
