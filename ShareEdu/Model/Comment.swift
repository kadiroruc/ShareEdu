//
//  Comment.swift
//  ShareEdu
//
//  Created by Abdulkadir Oruç on 18.02.2024.
//

import Foundation

struct Comment{
    let user: User
    let uid: String
    let text: String
    
    init(user: User, dictionary: [String:Any]) {
        self.user = user
        self.uid = dictionary["uid"] as? String ?? ""
        self.text = dictionary["text"] as? String ?? ""
    }
}
