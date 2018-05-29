//
//  Models.swift
//  Cloneagram
//
//  Created by Student on 2018. 03. 24..
//  Copyright © 2018. Student. All rights reserved.
//

import UIKit

class User {
    var uid: String
    var isOwn: Bool = false
    var name: String
    var description: String? = nil
    var profilePictureStorageUuid: String? = nil
    var photos: [String: AnyObject] = [:]
    var followedUserUids: [String] = []
    
    init(uid: String, name: String) {
        self.uid = uid
        self.name = name
    }
}

protocol PhotoDeletedDelegate {
    func photoDeleted(photo: Photo)
}

class Photo: Equatable {
    var uid: String
    var owner: User!
    var timestamp: UInt64
    var title: String? = nil
    var storageUuid: String
    var comments: [Comment] = []
    var likedByUserUids: [String] = []
    
    var photoDeletedDelegates: [PhotoDeletedDelegate] = []
    
    func callPhotoDeletedDelegates() {
        for delegate in photoDeletedDelegates {
            delegate.photoDeleted(photo: self)
        }
    }
    
    var isLikedByOwnUser: Bool {
        return likedByUserUids.contains(FirebaseManager.shared.ownUser!.uid)
    }
    
    init(uid: String, timestamp: UInt64, storageUuid: String) {
        self.uid = uid
        self.timestamp = timestamp
        self.storageUuid = storageUuid
    }
    
    static func ==(lhs: Photo, rhs: Photo) -> Bool {
        return lhs.uid == rhs.uid
    }
}

class Comment: Equatable {
    var uid: String
    var ownerUid: String
    var owner: User!
    var timestamp: UInt64
    var parentPhoto: Photo!
    var text: String
    
    var isOwnComment: Bool {
        return ownerUid == FirebaseManager.shared.ownUser.uid
    }
    
    init(uid: String, ownerUid: String, timestamp: UInt64, text: String) {
        self.uid = uid
        self.ownerUid = ownerUid
        self.timestamp = timestamp
        self.text = text
    }
    
    static func ==(lhs: Comment, rhs: Comment) -> Bool {
        return lhs.uid == rhs.uid
    }
}
