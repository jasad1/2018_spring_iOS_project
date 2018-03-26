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
    var displayName: String = ""
    var description: String? = nil
    var profilePictureUUID: String? = nil
    var images: [String] = []
    var followedUsers: [String] = []
}

struct Image {
    var title: String? = nil
    var url: String = ""
    var commentIds: [String] = []
    var likeIds: [String] = []
}
