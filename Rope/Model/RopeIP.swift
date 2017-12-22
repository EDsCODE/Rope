//
//  RopeIP.swift
//  Rope
//
//  Created by Eric Duong on 11/8/17.
//  Copyright © 2017 Rope. All rights reserved.
//

import Foundation

class RopeIP: NSObject, NSCopying {
    var expirationDate: Int?
    var participants: [User]?
    var title: String?
    var id: String?
    var role: Int?
    var contribution: Int?
    
    func printdetail() {
        if let expiration = expirationDate {
            print(expiration)
        }
        if let title = title {
            print(title)
        }
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = RopeIP()
        copy.expirationDate = expirationDate
        copy.participants = participants
        copy.title = title
        copy.id = id
        copy.role = role
        copy.contribution = contribution
        return copy
    }
    
}
