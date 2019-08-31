//
//  Post.swift
//  twitter
//
//  Created by 大久勝利 on 2019/08/09.
//  Copyright © 2019 大久勝利. All rights reserved.
//

import UIKit

class Post {
    
    var objectId: String
    var user: User
    var imageUrl: String
    var text: String
    var createDate: Date
    var isLiked: Bool?
    var comments: [Comment]?
    var likeCount: Int = 0
    
    init(objectId: String,user: User, imageUrl: String, text: String, createDate: Date) {
        self.objectId = objectId
        self.user = user
        self.imageUrl = imageUrl
        self.text = text
        self.createDate = createDate
    }
}
