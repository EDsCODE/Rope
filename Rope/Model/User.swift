//
//  User.swift
//  Rope
//
//  Created by Eric Duong on 10/25/17.
//  Copyright © 2017 Rope. All rights reserved.
//

import Foundation

struct CurrentUser {
    static var username = ""
    static var firstname = ""
    static var lastname = ""
    static var age = ""
    static var phoneNumber = ""
}

class User: NSObject {
    var username: String?
    var uid: String?
    var firstname: String?
    var lastname: String?
    
    func printDetail() {
        print(username!)
        print(uid!)
        print(firstname!)
        print(lastname!)
    }
}
