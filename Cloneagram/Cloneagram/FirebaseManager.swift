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

class FirebaseManager {
    // This is a singleton
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
    
    // MARK: - Authentication and user management
    
    var isLoggedIn: Bool {
        return firebaseUser != nil
    }
    
    func login(email: String, password: String, callback: @escaping (String?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if let error = error {
                let errorMessage = AuthErrorCode(rawValue: error._code)?.errorMessage ?? String(format: "Unknown error (code: %d).", error._code)
                callback(errorMessage)
            } else {
                callback(nil)
                self.firebaseUser = user!
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
            
            let request = user!.createProfileChangeRequest()
            request.displayName = name
            request.commitChanges { (error) in
                if let error = error {
                    let errorMessage = AuthErrorCode(rawValue: error._code)?.errorMessage ?? String(format: "Unknown error (code: %d).", error._code)
                    
                    callback(errorMessage)
                    return
                }
                
                self.databaseRef.child("users/\(user!.uid)/displayName").setValue(name) { (error, ref) in
                    if error != nil {
                        callback("Could not save user data.")
                        return
                    }
                    
                    self.databaseRef.child("users/\(user!.uid)/followedUsers")
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
    }
    
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
            
            let imageDBRef = self.databaseRef.child("images").childByAutoId()
            imageDBRef.updateChildValues([
                "title": title ?? "",
                "uuid": uuid
            ]) { (error, ref) in
                if error != nil {
                    // completion is nil, because we do not care about the result.
                    // It could happen that the image is uploaded, but we lose network connection
                    // and that is unfortunate, but there is nothing we can do.
                    imageRef.delete(completion: nil)
                    callback("Could not save image data.")
                    return
                }
                
                self.databaseRef.child("users/\(self.firebaseUser!.uid)/images")
                    .childByAutoId().setValue(imageDBRef.key) { (error, ref) in
                        if error != nil {
                            imageDBRef.removeValue()
                            imageRef.delete(completion: nil)
                            
                            callback("Could not save user data.")
                            return
                        }
                        
                        callback(nil)
                }
            }
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
