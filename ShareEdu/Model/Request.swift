//
//  Request.swift
//  ShareEdu
//
//  Created by Abdulkadir Oruç on 20.02.2024.
//

import Foundation

struct Request{
    let senderId: String
    let receiverId: String
    let status: String
    let email: String
    let message: String
    
    init(dictionary: [String: Any]) {
        self.senderId = dictionary["senderId"] as? String ?? ""
        self.receiverId = dictionary["receiverId"] as? String ?? ""
        self.status = dictionary["status"] as? String ?? ""
        self.email = dictionary["email"] as? String ?? ""
        self.message = dictionary["message"] as? String ?? ""
    }
}
