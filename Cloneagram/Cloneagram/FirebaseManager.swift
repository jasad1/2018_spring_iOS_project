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
import FirebaseStorageUI

/*struct Item {
    var user: User
    var profilePicture: UIImage?
    var image: Image
    var uiImage: UIImage
}*/

protocol ImageDelegate {
    func image(image: Image)
}

// This class is a singleton
class FirebaseManager {
    // MARK: - Class fields
    
    private static var firebaseAppConfigured = false
    private static var instance: FirebaseManager?
    
    static var shared: FirebaseManager {
        if instance == nil {
            instance = FirebaseManager()
        }
        return instance!
    }
    
    // MARK: - Instance fields
    
    private var auth: Auth!
    private var databaseRef: DatabaseReference!
    private var storageRef: StorageReference!
    
    private var firebaseUser: FirebaseAuth.User?
    private(set) var user: User?
    
    var delegate: ImageDelegate? = nil
    
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
    
    private func loadImage(from imageSnapshot: DataSnapshot) -> Image? {
        var title: String? = nil
        var storageUuid: String? = nil
        var likes: [Like] = []
        
        for child in imageSnapshot.children {
            guard let childSnapshot = child as? DataSnapshot else {
                return nil
            }
            
            switch childSnapshot.key {
            case "title":
                title = childSnapshot.value as? String
                
            case "storageUuid":
                storageUuid = childSnapshot.value as? String
                
            // TODO: implement these
            //case "comments":
                
            case "likes":
                guard let dbLikes = childSnapshot.value as? [String: String] else {
                    continue
                }
                
                for (uid, userId) in dbLikes {
                    likes.append(Like(uid: uid, userId: userId))
                }
                
            default:
                break
            }
        }
        
        guard let storageUuidU = storageUuid else {
            return nil
        }
        
        let image = Image(uid: imageSnapshot.key,
                          storageUuid: storageUuidU)
        image.title = title
        return image
    }
    
    private func loadUser(uid: String, onLoad: @escaping (User?) -> Void) {
        databaseRef.child("users/\(uid)")
                   .observeSingleEvent(of: .value) { (snapshot) in
            var name: String? = nil
            var description: String? = nil
            var profilePictureStorageUuid: String? = nil
            var images: [Image] = []
            var followedUserIds: [String] = []
            
            for child in snapshot.children {
                guard let childSnapshot = child as? DataSnapshot else {
                    onLoad(nil)
                    return
                }
                
                switch childSnapshot.key {
                case "name":
                    name = childSnapshot.value as? String
                    
                case "description":
                    description = childSnapshot.value as? String
                    
                case "profilePictureStorageUuid":
                    profilePictureStorageUuid = childSnapshot.value as? String
                    
                case "images":
                    for imageChild in childSnapshot.children {
                        guard let imageChildSnapshot = imageChild as? DataSnapshot,
                              let image = self.loadImage(from: imageChildSnapshot) else {
                            continue
                        }
                        images.append(image)
                    }
                    
                case "followedUserIds":
                    let dict = childSnapshot.value as! [String: String]
                    followedUserIds.append(contentsOf: dict.values)
                    
                default:
                    break
                }
            }
            
            guard let nameU = name else {
                onLoad(nil)
                return
            }

            let user = User(uid: uid, name: nameU)
            user.isOwn = self.firebaseUser!.uid == uid
            user.description = description
            user.profilePictureStorageUuid = profilePictureStorageUuid
            user.images = images
            user.followedUserIds = followedUserIds

            for image in user.images {
                image.owner = user
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
    
    func loadDatabase() {
        for followedUserId in user!.followedUserIds {
            loadUser(uid: followedUserId) { (followedUser) in
                guard let followedUser = followedUser else {
                    return
                }
                
                for image in followedUser.images {
                    self.delegate?.image(image: image)
                }
            }
        }
    }
    
    func loadImage(forUuid uuid: String, into imageView: UIImageView) {
        let path = "images/" + uuid + ".jpg"

        let imageRef = storageRef.child(path)
        imageView.sd_setImage(with: imageRef)
    }
    
    // MARK: - Image removal
    
    func removeImage(_ image: Image) {
        let path = "images/" + image.storageUuid + ".jpg"
        let imageRef = storageRef.child(path)
        imageRef.delete(completion: nil)
        
        databaseRef.child("users/\(image.owner.uid)/images/\(image.uid)")
                   .removeValue()
        image.owner.images.remove(object: image)
    }
    
    // MARK: - Like / Unlike
    
    func likeUnlike(_ image: Image) {
        if image.likedByMe {
            let like = image.myLike!
            
            databaseRef.child("users/\(image.owner.uid)/images/\(image.uid)/likes/\(like.uid)").removeValue()

            image.likes.removeLike(byUserId: user!.uid)
        } else {
            let child = databaseRef.child("users/\(image.owner.uid)/images/\(image.uid)/likes")
                                   .childByAutoId()
            child.setValue(user!.uid)

            image.likes.append(Like(uid: child.key, userId: user!.uid))
        }
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
