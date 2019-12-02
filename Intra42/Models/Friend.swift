//
//  Friend.swift
//  Intra42
//
//  Created by Felix Maury on 2019-05-25.
//  Copyright © 2019 Felix Maury. All rights reserved.
//

import Foundation

struct FriendInfo {
    let id: Int
    let online: Date
    var campus: String
}

struct Friend: Equatable {
    
    let id: Int
    let username: String
    let phone: String
    let email: String
    var imageURL: String {
        return "https://cdn.intra.42.fr/users/medium_\(username).jpg"
    }
    
    static func == (lhs: Friend, rhs: Friend) -> Bool {
        return lhs.id == rhs.id
    }
}
