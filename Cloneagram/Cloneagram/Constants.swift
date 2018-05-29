//
//  Constants.swift
//  Cloneagram
//
//  Created by Student on 2018. 05. 20..
//  Copyright © 2018. Student. All rights reserved.
//

import Foundation

struct Constants {
    static let NAME_LENGTH_MAX = 64
    
    static let PASSWORD_LENGTH_MIN =  6
    static let PASSWORD_LENGTH_MAX = 16
    
    static let COMMENT_LENGTH_MAX = 120
    
    static let DESCRIPTION_LENGTH_MAX = 120
    
    struct NibNames {
        static let PhotoTableViewCell = "PhotoTableViewCell"
    }
    
    struct ReuseIdentifiers {
        static let photoCell = "photoCell"
        static let likesCell = "likesCell"
        static let commentCell = "commentCell"
        static let newCommentCell = "newCommentCell"
        static let searchResultCell = "searchResultCell"
    }
    
    struct SegueIdentifiers {
        static let FeedToViewPhoto = "FeedToViewPhoto"
        static let FeedToViewProfile = "FeedToViewProfile"
        static let SearchEmbed = "SearchEmbed"
        static let SearchToViewProfile = "SearchToViewProfile"
        static let SettingsToChoosePhoto = "SettingsToChoosePhoto"
        static let ViewPhotoToViewProfile = "ViewPhotoToViewProfile"
        static let ViewProfileEmbed = "ViewProfileEmbed"
        static let ViewProfileToViewPhoto = "ViewProfileToViewPhoto"
    }
}
