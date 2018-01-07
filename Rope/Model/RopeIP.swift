//
//  RopeIP.swift
//  Rope
//
//  Created by Eric Duong on 11/8/17.
//  Copyright © 2017 Rope. All rights reserved.
//

import Foundation

class RopeIP: NSObject, NSCopying {
    var expirationDate: Int
    var participants: [User]
    var title: String
    var id: String
    var role: Int
    var contribution: Int
    
    init(expirationDate: Int, participants: [User], title: String, id: String, role: Int, contribution: Int) {
        self.expirationDate = expirationDate
        self.participants = participants
        self.title = title
        self.id = id
        self.role = role
        self.contribution = contribution
    }
    
    func printdetail() {
        print(expirationDate)
        print(title)
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = RopeIP(expirationDate: expirationDate, participants: participants, title: title, id: id, role: role, contribution: contribution)
        return copy
    }
    
}
