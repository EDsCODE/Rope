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
    var knotCount: Int?
    var id: String?
    
    func printdetail() {
        if let expiration = expirationDate {
            print(expiration)
        }
        if let title = title {
            print(title)
        }
        if let count = knotCount {
            print(count)
        }
    }
    
}
