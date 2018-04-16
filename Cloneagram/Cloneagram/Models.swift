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
    var images: [Image] = []
    var followedUserIds: [String] = []
    
    init(uid: String, name: String) {
        self.uid = uid
        self.name = name
    }
}

class Image: Equatable {
    var uid: String
    var owner: User!
    var title: String? = nil
    var storageUuid: String
    var comments: [Comment] = []
    var likes: [Like] = []
    
    var likedByMe: Bool {
        return likes.contains {
            $0.userId == FirebaseManager.shared.user!.uid
        }
    }
    
    var myLike: Like? {
        return likes.filter {
            $0.userId == FirebaseManager.shared.user!.uid
        }.first
    }
    
    init(uid: String, storageUuid: String) {
        self.uid = uid
        self.storageUuid = storageUuid
    }
    
    static func ==(lhs: Image, rhs: Image) -> Bool {
        return lhs.uid == rhs.uid
    }
}

class Comment {
    var uid: String
    var owner: User!
    var parentImage: Image!
    var text: String
    
    init(uid: String, text: String) {
        self.uid = uid
        self.text = text
    }
}

struct Like {
    var uid: String
    var userId: String
}

extension Array where Element == Like {
    mutating func removeLike(byUserId userId: String) {
        for (i, e) in enumerated() {
            if e.userId == userId {
                remove(at: i)
                return
            }
        }
    }
}
