//
//  Rope.swift
//  Rope
//
//  Created by Eric Duong on 11/8/17.
//  Copyright © 2017 Rope. All rights reserved.
//

import Foundation

class Rope: NSObject {
    var expirationDate: Int!
    var participants: [User]!
    var title: String!
    var knotCount: Int!
    var id: String!
    var media: [Media]!
    var creatorID: String!
    
    func printDetail() {
        print(expirationDate)
        print(title)
        print(knotCount)
        print(id)
        print(creatorID)
        for user in participants {
            print(user.firstname!)
        }
    }
}
