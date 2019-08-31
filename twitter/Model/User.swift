//
//  User.swift
//  twitter
//
//  Created by 大久勝利 on 2019/08/09.
//  Copyright © 2019 大久勝利. All rights reserved.
//

import UIKit

class User {
    
    var objectId: String
    var userName: String
    var displayName: String?
    var introduction: String?
    
    init(objectId: String, userName: String) {
        self.objectId = objectId
        self.userName = userName
    }
}
