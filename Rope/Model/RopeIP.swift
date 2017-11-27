//
//  RopeIP.swift
//  Rope
//
//  Created by Eric Duong on 11/8/17.
//  Copyright © 2017 Rope. All rights reserved.
//

import Foundation

class RopeIP: NSObject {
    var expirationDate: Int?
    var participants: [User]?
    var title: String?
    var id: String?
    var role: Int?
    
    func printdetail() {
        if let expiration = expirationDate {
            print(expiration)
        }
        if let title = title {
            print(title)
        }
    }
    
}
