//
//  Comment.swift
//  twitter
//
//  Created by 大久勝利 on 2019/08/16.
//  Copyright © 2019 大久勝利. All rights reserved.
//

import UIKit

class Comment {
    var postId: String
    var user: User
    var text: String
    var createDate: Date
    
    init(postId: String, user: User, text: String, createDate: Date) {
        self.postId = postId
        self.user = user
        self.text = text
        self.createDate = createDate
    }
}
