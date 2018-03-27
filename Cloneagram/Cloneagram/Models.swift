//
//  Models.swift
//  Cloneagram
//
//  Created by Student on 2018. 03. 24..
//  Copyright © 2018. Student. All rights reserved.
//

import Foundation

struct User {
    var uid: String = ""
    var isOwn: Bool = false
    var name: String = ""
    var description: String? = nil
    var profilePictureStorageUuid: String? = nil
    var images: [Image] = []
    var followedUserIds: [String] = []
}

struct Image {
    var uid: String = ""
    var ownerUid: String = ""
    var title: String? = nil
    var storageUuid: String = ""
    var comments: [Comment] = []
    var likeUserIds: [String] = []
}

struct Comment {
    var uid: String = ""
    var ownerUid: String = ""
    var text: String = ""
}
