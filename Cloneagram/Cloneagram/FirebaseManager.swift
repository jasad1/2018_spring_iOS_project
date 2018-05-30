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

protocol FeedDelegate {
    func photo(photo: Photo)
    func reset()
    func reloadProfilePictures()
}

/* Real-time updates could have been used in many places, e.g.
 * feed, comments, likes, profile description, profile picture changes etc.
 * The structure of the app was organized in a static way from the beginning
 * and due to time constraints, real-time functionality is not implemented.
 * From the user's point of view, the app works more in a content-consuming
 * way, rather than having full real-time interactivity. Users can open the
 * app, go through all the uploaded stuff at the current point in time, post
 * some likes or comments, then close the app. Next time they open it again,
 * all the new interactions that happened by other users in the meantime will
 * be available for consumption.
 */

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
    
    private var ownFirebaseUser: FirebaseAuth.User!
    private(set) var ownUser: User!
    
    var delegate: FeedDelegate? = nil
    
    // MARK: - Constructor
    
    private init() {
        if !FirebaseManager.firebaseAppConfigured {
            FirebaseApp.configure()
            FirebaseManager.firebaseAppConfigured = true
        }
        
        auth = Auth.auth()
        databaseRef = Database.database().reference()
        storageRef = Storage.storage().reference()
        
        ownFirebaseUser = auth.currentUser
    }
    
    // MARK: - Authentication and user management
    
    func loadOwnUser(callback: @escaping (User?) -> Void) {
        // Do not load the user again
        if ownUser != nil {
            callback(ownUser)
            return
        }
        
        loadUser(uid: ownFirebaseUser!.uid) { (user) in
            self.ownUser = user
            self.ownUser?.isOwn = true
            callback(user)
        }
    }
    
    var isSignedIn: Bool {
        return ownFirebaseUser != nil
    }
    
    func signIn(email: String, password: String, callback: @escaping (String?) -> Void) {
        auth.signIn(withEmail: email, password: password) { (user, error) in
            if let error = error {
                callback(error.localizedDescription)
            } else {
                self.ownFirebaseUser = user!
                callback(nil)
            }
        }
    }
    
    func signOut() {
        do {
            try auth.signOut()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
        FirebaseManager.instance = nil
    }
    
    func createUser(name: String, email: String, password: String, callback: @escaping (String?) -> Void) {
        auth.createUser(withEmail: email, password: password) { (user, error) in
            if let error = error {
                callback(error.localizedDescription)
                return
            }
            
            let uid = user!.uid
            
            var map = [String: Any]()
            map["name"] = name
            map["followedUserUids/\(uid)"] = true
            map["followedByUserUids/\(uid)"] = true
            
            self.databaseRef.child("users/\(uid)").updateChildValues(map) { (error, ref) in
                if let error = error {
                    callback(error.localizedDescription)
                    return
                }
                
                self.ownFirebaseUser = user!
            }
        }
    }
    
    func update(description: String, callback: @escaping (String?) -> Void) {
        databaseRef.child("users/\(ownUser.uid)/description").setValue(description) { (error, ref) in
            if let error = error {
                callback(error.localizedDescription)
                return
            }
            
            self.ownUser.description = description
            callback(nil)
        }
    }
    
    func update(password: String, callback: @escaping (String?) -> Void) {
        // This operation can fail with 'old authentication' error.
        // In this case a reauthentication would be required, which is not implemented
        // here due to time constraints. The error message is descriptive enough to
        // convey the proper meaning to the user, i.e. that a recent sign-in is required.
        ownFirebaseUser.updatePassword(to: password) { (error) in
            if let error = error {
                callback(error.localizedDescription)
                return
            }
            
            callback(nil)
        }
    }
    
    func deleteProfile(callback: @escaping (String?) -> Void) {
        // This operation can fail with 'old authentication' error.
        // In this case a reauthentication would be required, which is not implemented
        // here due to time constraints. The error message is descriptive enough to
        // convey the proper meaning to the user, i.e. that a recent sign-in is required.
        ownFirebaseUser.delete { (error) in
            if let error = error {
                callback(error.localizedDescription)
                return
            }
            
            // Delete previously set data.
            // Not checking completion, because the auth user is already deleted
            // and this way we only have some stale data in the database.
            self.databaseRef.child("users/\(self.ownUser.uid)").removeValue()
            
            /* Other data that should be delete here:
             * - Own user id from followedUserIds from all other users which follow this user
             * - All comments and likes posted by this user
             *
             * The solution is to use Firebase Cloud Functions that trigger on user deletion
             * and delete the needed data based on:
             * - followedByUserUids (to know which users follow the current user and
             *                       be able to delete the current user uid from their list)
             * - likedPhotoUids (to know which photos are liked by the current user
             *                   so the like can be removed)
             * - commentUids (to know the posted comments and remove them)
             *
             * Due to time constraints, this server-side functionality is not implemented.
             */
            
            FirebaseManager.instance = nil
            callback(nil)
        }
    }
    
    private func loadComment(from commentSnapshot: DataSnapshot) -> Comment? {
        var ownerUid: String? = nil
        var timestamp: UInt64? = nil
        var text: String? = nil
        
        for child in commentSnapshot.children {
            guard let childSnapshot = child as? DataSnapshot else {
                return nil
            }
            
            switch childSnapshot.key {
            case "ownerUid":
                ownerUid = childSnapshot.value as? String
              
            case "timestamp":
                timestamp = childSnapshot.value as? UInt64
                
            case "text":
                text = childSnapshot.value as? String
                
            default:
                break
            }
        }
        
        guard let ownerUidU = ownerUid, let timestampU = timestamp,
              let textU = text else {
            return nil
        }
        
        let comment = Comment(uid: commentSnapshot.key,
                              ownerUid: ownerUidU,
                              timestamp: timestampU,
                              text: textU)
        return comment
    }
    
    private func loadPhoto(from photoSnapshot: DataSnapshot) -> Photo? {
        var title: String? = nil
        var timestamp: UInt64? = nil
        var storageUuid: String? = nil
        var likedByUserUids: [String] = []
        
        for child in photoSnapshot.children {
            guard let childSnapshot = child as? DataSnapshot else {
                return nil
            }
            
            switch childSnapshot.key {
            case "title":
                title = childSnapshot.value as? String
                
            case "timestamp":
                timestamp = childSnapshot.value as? UInt64
                
            case "storageUuid":
                storageUuid = childSnapshot.value as? String

            case "likedByUserUids":
                guard let dbLikes = childSnapshot.value as? [String: Bool] else {
                    continue
                }
                
                likedByUserUids.append(contentsOf: dbLikes.keys)
                
            default:
                break
            }
        }
        
        guard let timestampU = timestamp, let storageUuidU = storageUuid else {
            return nil
        }
        
        let photo = Photo(uid: photoSnapshot.key,
                          timestamp: timestampU,
                          storageUuid: storageUuidU)
        photo.title = title
        photo.likedByUserUids = likedByUserUids
        return photo
    }
    
    private func loadPhoto(for uid: String, callback: @escaping (Photo?) -> Void) {
        databaseRef.child("photos/\(uid)")
                   .observeSingleEvent(of: .value) { (snapshot) in
            let photo = self.loadPhoto(from: snapshot)
            if photo == nil {
                callback(nil)
            } else {
                callback(photo)
            }
        }
    }
    
    private var alreadyLoadedUsers: [String: User] = [:]
    
    private func loadUser(uid: String, callback: @escaping (User?) -> Void) {
        if let loadedUser = alreadyLoadedUsers[uid] {
            callback(loadedUser)
            return
        }
        
        databaseRef.child("users/\(uid)")
                   .observeSingleEvent(of: .value) { (snapshot) in
            var name: String? = nil
            var description: String? = nil
            var profilePictureStorageUuid: String? = nil
            var photos: [String: AnyObject] = [:]
            var followedUserUids: [String] = []
            
            for child in snapshot.children {
                guard let childSnapshot = child as? DataSnapshot else {
                    callback(nil)
                    return
                }
                
                switch childSnapshot.key {
                case "name":
                    name = childSnapshot.value as? String
                    
                case "description":
                    description = childSnapshot.value as? String
                    
                case "profilePictureStorageUuid":
                    profilePictureStorageUuid = childSnapshot.value as? String
                    
                case "photoUids":
                    let dict = childSnapshot.value as! [String: Bool]
                    for photoUid in dict.keys {
                        photos[photoUid] = NSNull()
                    }
                    
                case "followedUserUids":
                    let dict = childSnapshot.value as! [String: Bool]
                    followedUserUids.append(contentsOf: dict.keys)
                    
                default:
                    break
                }
            }
            
            guard let nameU = name else {
                callback(nil)
                return
            }

            let user = User(uid: uid, name: nameU)
            user.isOwn = self.ownFirebaseUser!.uid == uid
            user.description = description
            user.profilePictureStorageUuid = profilePictureStorageUuid
            user.photos = photos
            user.followedUserUids = followedUserUids
                
            self.alreadyLoadedUsers[uid] = user
            callback(user)
        }
    }
    
    // MARK: - Profile picture and photo upload
    
    func uploadProfilePicture(data: Data, callback: @escaping (String?) -> Void) {
        let uuid = UUID().uuidString
        let path = "photos/\(uuid).jpg"
        
        let photoStorageRef = storageRef.child(path)
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        photoStorageRef.putData(data, metadata: metadata) { (metadata, error) in
            if let error = error {
                callback(error.localizedDescription)
                return
            }
            
            // Delete previous profile picture if any
            if let pPSUuid = self.ownUser.profilePictureStorageUuid {
                let previousPath = "photos/\(pPSUuid).jpg"
                let previousPhotoRef = self.storageRef.child(previousPath)
                previousPhotoRef.delete(completion: nil)
            }
         
            // Update UUID
            let child = self.databaseRef.child("users/\(self.ownUser.uid)/profilePictureStorageUuid")
            child.setValue(uuid)
            
            self.ownUser.profilePictureStorageUuid = uuid
            
            self.delegate?.reloadProfilePictures()
            callback(nil)
        }
    }
    
    func uploadPhoto(data: Data, title: String?, callback: @escaping (String?) -> Void) {
        let uuid = UUID().uuidString
        let path = "photos/\(uuid).jpg"

        let photoStorageRef = storageRef.child(path)
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        photoStorageRef.putData(data, metadata: metadata) { (metadata, error) in
            if let error = error {
                callback(error.localizedDescription)
                return
            }
            
            let newPhotoUid = self.databaseRef.child("photos").childByAutoId().key
            let photosDir = "photos/\(newPhotoUid)/"
            let userPhotoPath = "users/\(self.ownUser!.uid)/photoUids/\(newPhotoUid)"
            
            var map: [String: Any] = [:]
            
            // Photo
            map[photosDir + "ownerUid"] = self.ownUser!.uid
            let timestamp = UInt64(NSDate().timeIntervalSince1970 * 1000)
            map[photosDir + "timestamp"] = timestamp
            if let title = title {
                map[photosDir + "title"] = title
            }
            map[photosDir + "storageUuid"] = uuid
            
            // User photo
            map[userPhotoPath] = true
            
            self.databaseRef.updateChildValues(map) { (error, ref) in
                if let error = error {
                    // Try to delete dangling photo in storage
                    photoStorageRef.delete(completion: nil)
                    callback(error.localizedDescription)
                    return
                }
                
                let photo = Photo(uid: newPhotoUid,
                                  timestamp: timestamp,
                                  storageUuid: uuid)
                photo.owner = self.ownUser!
                photo.title = title
                
                self.ownUser!.photos[newPhotoUid] = photo
                self.delegate?.photo(photo: photo)
                callback(nil)
            }
        }
    }
    
    // MARK: - Feed loading
    
    func loadPhotosOfFollowedUsers() {
        delegate?.reset()
        
        for followedUserUid in ownUser!.followedUserUids {
            loadUser(uid: followedUserUid) { (followedUser) in
                guard let followedUser = followedUser else {
                    return
                }
                
                for entry in followedUser.photos {
                    if let photo = entry.value as? Photo {
                        self.delegate?.photo(photo: photo)
                    } else {
                        self.loadPhoto(for: entry.key) { (photo) in
                            if let photo = photo {
                                photo.owner = followedUser
                                self.delegate?.photo(photo: photo)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func loadPhotos(for user: User, callback: @escaping (String?) -> Void) {
        databaseRef.child("photos/").queryOrdered(byChild: "ownerUid").queryEqual(toValue: user.uid)
            .observeSingleEvent(of: .value, with: { (snapshot) in
                for child in snapshot.children {
                    guard let childSnapshot = child as? DataSnapshot else {
                        continue
                    }
                    
                    if let photo = self.loadPhoto(from: childSnapshot) {
                        photo.owner = user
                        user.photos[photo.uid] = photo
                    }
                }
                callback(nil)
            }, withCancel: { (error) in
                callback(error.localizedDescription)
            })
    }
    
    func loadComments(for photo: Photo, callback: @escaping (String?) -> Void) {
        databaseRef.child("comments/").queryOrdered(byChild: "parentPhotoUid").queryEqual(toValue: photo.uid)
            .observeSingleEvent(of: .value, with: { (snapshot) in
                photo.comments.removeAll()
                for child in snapshot.children {
                    guard let childSnapshot = child as? DataSnapshot else {
                        continue
                    }
                    
                    if let comment = self.loadComment(from: childSnapshot) {
                        comment.parentPhoto = photo
                        
                        self.loadUser(uid: comment.ownerUid) { (user) in
                            if let user = user {
                                comment.owner = user
                                photo.comments.append(comment)
                            }
                        }
                    }
                }
                callback(nil)
            }, withCancel: { (error) in
                callback(error.localizedDescription)
            })
    }
    
    func loadPhoto(for uuid: String?, into imageView: UIImageView,
                   callback: @escaping (String?) -> Void) {
        guard let uuid = uuid else {
            return
        }
        
        let path = "photos/" + uuid + ".jpg"

        let photoRef = storageRef.child(path)
        //imageView.sd_setImage(with: photoRef)
        
        imageView.sd_setImage(with: photoRef, placeholderImage: nil) {
            (uiImage, error, cacheType, ref) in
            if let error = error {
                callback(error.localizedDescription)
                return
            }
            callback(nil)
        }
    }
    
    // MARK: - Photo removal
    
    func deletePhoto(_ photo: Photo, _ callback: @escaping (String?) -> Void) {
        // Here all associated comments to the photo should be deleted.
        // However, it is better to do it server-side in a Cloud Function.
        // Due to time constraints, this functionality is not implemented.
        
        var map: [String: Any] = [:]
        map["users/\(photo.owner.uid)/photoUids/\(photo.uid)"] = NSNull()
        map["photos/\(photo.uid)"] = NSNull()
        
        databaseRef.updateChildValues(map) { (error, ref) in
            if let error = error {
                callback(error.localizedDescription)
                return
            }
            
            let path = "photos/" + photo.storageUuid + ".jpg"
            let photoRef = self.storageRef.child(path)
            // Not checking completion, because the photo data is already deleted
            // from the DB and this way we only have a stale photo in storage.
            photoRef.delete(completion: nil)
            
            photo.owner.photos.removeValue(forKey: photo.uid)
            photo.callPhotoDeletedDelegates()
            
            callback(nil)
        }
    }
    
    // MARK: - Follow / unfollow
    
    func followUnfollow(userToFollow: User, callback: @escaping (String?) -> Void) {
        let completion: (Error?, DatabaseReference) -> Void = { (error, ref) in
            if let error = error {
                callback(error.localizedDescription)
                return
            }
            
            callback(nil)
        }
        
        let followedPath   = "users/\(ownUser.uid)/followedUserUids/\(userToFollow.uid)"
        let followedByPath = "users/\(userToFollow.uid)/followedByUserUids/\(ownUser.uid)"
        
        var map = [String: Any]()
        
        if ownUser.followedUserUids.contains(userToFollow.uid) {
            map[followedPath]   = NSNull()
            map[followedByPath] = NSNull()
            databaseRef.updateChildValues(map, withCompletionBlock: completion)
            
            ownUser.followedUserUids.remove(object: userToFollow.uid)
        } else {
            map[followedPath]   = true
            map[followedByPath] = true
            databaseRef.updateChildValues(map, withCompletionBlock: completion)
            
            ownUser.followedUserUids.append(userToFollow.uid)
        }
        
        loadPhotosOfFollowedUsers()
    }
    
    // MARK: - Like / Unlike
    
    func likeUnlike(photo: Photo, callback: @escaping (String?) -> Void) {
        let completion: (Error?, DatabaseReference) -> Void = { (error, ref) in
            if let error = error {
                callback(error.localizedDescription)
                return
            }
            
            callback(nil)
        }
        
        let likedByPath     = "photos/\(photo.uid)/likedByUserUids/\(ownUser.uid)"
        let likedPhotosPath = "users/\(ownUser.uid)/likedPhotoUids/\(photo.uid)"
        
        var map = [String: Any]()
        
        if photo.isLikedByOwnUser {
            map[likedByPath]     = NSNull()
            map[likedPhotosPath] = NSNull()
            databaseRef.updateChildValues(map, withCompletionBlock: completion)
            
            photo.likedByUserUids.remove(object: ownUser.uid)
        } else {
            map[likedByPath]     = true
            map[likedPhotosPath] = true
            databaseRef.updateChildValues(map, withCompletionBlock: completion)
            
            photo.likedByUserUids.append(ownUser.uid)
        }
    }
    
    // MARK: - Comments
    
    func addComment(photo: Photo, text: String, callback: @escaping (String?) -> Void) {
        let newCommentUid = databaseRef.child("comments/").childByAutoId().key
        let commentsDir      = "comments/\(newCommentUid)/"
        let photoCommentPath = "photos/\(photo.uid)/commentUids/\(newCommentUid)"
        let userCommentPath  = "users/\(ownUser.uid)/commentUids/\(newCommentUid)"
        
        var map = [String: Any]()
        
        // Comment
        map[commentsDir + "ownerUid"] = ownUser.uid
        map[commentsDir + "parentPhototUid"] = photo.uid
        let timestamp = UInt64(NSDate().timeIntervalSince1970 * 1000)
        map[commentsDir + "timestamp"] = timestamp
        map[commentsDir + "text"] = text
        
        // Photo comment
        map[photoCommentPath] = true
        
        // User comment
        map[userCommentPath] = true
        
        databaseRef.updateChildValues(map) { (error, ref) in
            if let error = error {
                callback(error.localizedDescription)
                return
            }
            
            let comment = Comment(uid: newCommentUid,
                                  ownerUid: self.ownUser.uid,
                                  timestamp: timestamp,
                                  text: text)
            comment.owner = self.ownUser
            comment.parentPhoto = photo
            
            photo.comments.append(comment)
            
            callback(nil)
        }
    }
    
    func deleteComment(comment: Comment, callback: @escaping (String?) -> Void) {
        var map = [String: Any]()
        map["photos/\(comment.parentPhoto.uid)/commentUids/\(comment.uid)"] = NSNull()
        map["comments/\(comment.uid)"] = NSNull()
        
        databaseRef.updateChildValues(map) { (error, ref) in
            if let error = error {
                callback(error.localizedDescription)
                return
            }
            
            comment.parentPhoto.comments.remove(object: comment)
            callback(nil)
        }
    }
    
    // MARK: - User searching
    
    func searchUsers(query: String, callback: @escaping (User?) -> Void) {
        // Appending the '\u{f8ff}' Unicode character is necessary to
        // 'cheat' the search system and allow 'starts with' queries.
        databaseRef.child("users/").queryOrdered(byChild: "name")
            .queryStarting(atValue: query).queryEnding(atValue: query + "\u{f8ff}")
            .observeSingleEvent(of: .value) { (snapshot) in
                for child in snapshot.children {
                    guard let childSnapshot = child as? DataSnapshot else {
                        continue
                    }
                    
                    self.loadUser(uid: childSnapshot.key) { (user) in
                        if let user = user {
                            callback(user)
                        }
                    }
                }
        }
    }
}
