//
//  FirebaseManager.swift
//  Cloneagram
//
//  Created by Student on 2018. 03. 26..
//  Copyright © 2018. Student. All rights reserved.
//

import Foundation

import Firebase
import FirebaseAuth
import FirebaseDatabase
import FirebaseStorage

struct Item {
    var user: User
    var profilePicture: UIImage?
    var image: Image
    var uiImage: UIImage
}

protocol FeedItemDelegate {
    func feedItem(item: Item)
}

// This class is a singleton
class FirebaseManager {
    // MARK: - Class and instance fields
    
    private static var firebaseAppConfigured = false
    private static var instance: FirebaseManager?
    
    static var shared: FirebaseManager {
        if instance == nil {
            instance = FirebaseManager()
        }
        return instance!
    }
    
    private var auth: Auth!
    private var databaseRef: DatabaseReference!
    private var storageRef: StorageReference!
    
    private var firebaseUser: FirebaseAuth.User?
    private(set) var user: User?
    
    var delegate: FeedItemDelegate? = nil
    
    // MARK: - Constructor
    
    private init() {
        if !FirebaseManager.firebaseAppConfigured {
            FirebaseApp.configure()
            FirebaseManager.firebaseAppConfigured = true
        }
        
        auth = Auth.auth()
        databaseRef = Database.database().reference()
        storageRef = Storage.storage().reference()
        
        firebaseUser = auth.currentUser
    }
    
    // MARK: - Authentication and user management
    
    func loadOwnUser(callback: @escaping (User?) -> Void) {
        // Do not load the user again
        if user != nil {
            callback(user)
            return
        }
        
        loadUser(uid: firebaseUser!.uid) { (user) in
            self.user = user
            self.user?.isOwn = true
            callback(user)
        }
    }
    
    var isLoggedIn: Bool {
        return firebaseUser != nil
    }
    
    func login(email: String, password: String, callback: @escaping (String?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if let error = error {
                let errorMessage = AuthErrorCode(rawValue: error._code)?.errorMessage ?? String(format: "Unknown error (code: %d).", error._code)
                callback(errorMessage)
            } else {
                self.firebaseUser = user!
                callback(nil)
            }
        }
    }
    
    func logout() {
        do {
            try auth.signOut()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
        FirebaseManager.instance = nil
    }
    
    func register(name: String, email: String, password: String, callback: @escaping (String?) -> Void) {
        auth.createUser(withEmail: email, password: password) { (user, error) in
            if let error = error {
                let errorMessage = AuthErrorCode(rawValue: error._code)?.errorMessage ?? String(format: "Unknown error (code: %d).", error._code)
                
                callback(errorMessage)
                return
            }
            
            self.databaseRef.child("users/\(user!.uid)/name")
                .setValue(name) { (error, ref) in
                if error != nil {
                    callback("Could not save user data.")
                    return
                }
                
                self.databaseRef.child("users/\(user!.uid)/followedUserIds")
                    .childByAutoId().setValue(user!.uid) { (error, ref) in
                    if error != nil {
                        callback("Could not save user data.")
                        return
                    }
                    
                    callback(nil)
                }
            }
        }
    }
    
    private func loadImage(from imageSnapshot: DataSnapshot,
                           withOwnerUid ownerUid: String) -> Image {
        var image = Image()
        image.uid = imageSnapshot.key
        image.ownerUid = ownerUid
        
        for child in imageSnapshot.children {
            let childSnapshot = child as! DataSnapshot
            switch childSnapshot.key {
            case "title":
                image.title = (childSnapshot.value as! String)
                
            case "storageUuid":
                image.storageUuid = childSnapshot.value as! String
                
            // TODO: implement these
            //case "comments":
                
            //case "likes":
                
            default:
                break
            }
        }
        
        return image
    }
    
    private func loadUser(uid: String, onLoad: @escaping (User?) -> Void) {
        databaseRef.child("users/\(uid)")
                   .observeSingleEvent(of: .value) { (snapshot) in
            var user = User()
            user.uid = uid
            user.isOwn = self.firebaseUser!.uid == uid
            
            for child in snapshot.children {
                let childSnapshot = child as! DataSnapshot
                switch childSnapshot.key {
                case "name":
                    user.name = childSnapshot.value as! String
                    
                case "description":
                    user.description = (childSnapshot.value as! String)
                    
                case "profilePictureStorageUuid":
                    user.profilePictureStorageUuid = (childSnapshot.value as! String)
                    
                case "images":
                    for imageChild in childSnapshot.children {
                        let imageChildSnapshot = imageChild as! DataSnapshot
                        user.images.append(self.loadImage(from: imageChildSnapshot,
                                                          withOwnerUid: uid))
                    }
                    
                case "followedUserIds":
                    let dict = childSnapshot.value as! [String: String]
                    user.followedUserIds.append(contentsOf: dict.values)
                    
                default:
                    break
                }
            }
            
            onLoad(user)
        }
    }
    
    // MARK: - Image upload
    
    func uploadImage(data: Data, title: String?, callback: @escaping (String?) -> Void) {
        let uuid = UUID().uuidString
        let path = "images/" + uuid + ".jpg"
        
        let imageRef = storageRef.child(path)
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        imageRef.putData(data, metadata: metadata) { (metadata, error) in
            if let error = error {
                let errorMessage = StorageErrorCode(rawValue: error._code)?.errorMessage ?? String(format: "Unknown error (code: %d).", error._code)
                
                callback(errorMessage)
                return
            }
            
            let imageDBRef = self.databaseRef
                .child("users/\(self.firebaseUser!.uid)/images")
                .childByAutoId()
            imageDBRef.updateChildValues([
                "title": title ?? "",
                "storageUuid": uuid
            ]) { (error, ref) in
                if error != nil {
                    // completion is nil, because we do not care about the result.
                    // It could happen that the image is uploaded, but we lose network connection
                    // and that is unfortunate, but there is nothing we can do.
                    imageRef.delete(completion: nil)
                    callback("Could not save image data.")
                    return
                }
                
                callback(nil)
            }
        }
    }
    
    // MARK: - Feed loading
    
    private func loadImagesOfUser(_ user: User, _ profilePictureImage: UIImage?) {
        for image in user.images {
            let path = "images/" + image.storageUuid + ".jpg"
            
            let imageRef = self.storageRef.child(path)
            imageRef.getData(maxSize: 1 * 1024 * 1024) { (data, error) in
                if let _ = error {
                    /*let errorMessage = StorageErrorCode(rawValue: error._code)?.errorMessage ?? String(format: "Unknown error (code: %d).", error._code)
                     
                     self.createAndShowErrorAlert(forMessage: errorMessage)*/
                    return
                }
                
                let downloadedImage = UIImage(data: data!)
                guard downloadedImage != nil else {
                    return
                }
                
                let item = Item(user: user, profilePicture: profilePictureImage,
                                image: image, uiImage: downloadedImage!)
                self.delegate?.feedItem(item: item)
            }
        }
    }
    
    func startObservingDatabase() {
        for followedUserId in user!.followedUserIds {
            loadUser(uid: followedUserId) { (user) in
                guard let user = user else {
                    return
                }
                
                guard let photoUuid = user.profilePictureStorageUuid else {
                    // No profile picture, just load the images
                    self.loadImagesOfUser(user, nil)
                    return
                }
                
                let path = "images/" + photoUuid + ".jpg"
                
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
    
    // MARK: - Image removal
    
    func removeImage(_ image: Image) {
        let path = "images/" + image.storageUuid + ".jpg"
        let imageRef = storageRef.child(path)
        imageRef.delete(completion: nil)
        
        databaseRef.child("users/\(image.ownerUid)/images/\(image.uid)")
                   .removeValue()
    }
}

extension AuthErrorCode {
    var errorMessage: String {
        switch self {
        case .networkError:
            return "A network error occurred."
        case .tooManyRequests:
            return "Too many requests. Try again later."
        case .invalidEmail:
            return "The e-mail address is invalid."
        case .userNotFound:
            return "The account does not exist."
        case .wrongPassword:
            return "Wrong password."
        case .emailAlreadyInUse:
            return "The email is already in use with another account."
        case .weakPassword:
            return "The password is too weak."
        default:
            return String(format: "Unknown error (code: %d).", self.rawValue)
        }
    }
}

extension StorageErrorCode {
    var errorMessage: String {
        switch self {
        case .unauthenticated:
            return "You are not logged in."
        case .unauthorized:
            return "You do not have permission to do this."
        case .retryLimitExceeded:
            return "Retry limit exceeded. Try again later."
        default:
            return String(format: "Unknown error (code: %d).", self.rawValue)
        }
    }
}
