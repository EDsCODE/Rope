//
//  User.swift
//  Rope
//
//  Created by Eric Duong on 10/25/17.
//  Copyright © 2017 Rope. All rights reserved.
//

import Foundation

class User {
    private var _firstName: String!
    private var _lastName: String!
    private var _age: Int!
    private var _phoneNumber: String!
    
    init(firstName: String? = nil, lastName: String? = nil, age: Int? = nil, phoneNumber: String? = nil){
        if let firstName = firstName {
             _firstName = firstName
        }
        if let lastName = lastName {
            _lastName = lastName
        }
        if let age = age {
            _age = age
        }
        if let phoneNumber = phoneNumber {
            _phoneNumber = phoneNumber
        }
    }
    
    var firstName: String {
        get{
            return _firstName
        }
        set {
            _firstName = newValue
        }
    }
    
    var lastName: String {
        get{
            return _lastName
        }
        set {
            _lastName = newValue
        }
    }
    
    var age: Int {
        get{
            return _age
        }
        set {
            _age = newValue
        }
    }
    
    var phoneNumber: String {
        get{
            return _phoneNumber
        }
        set {
            _phoneNumber = newValue
        }
    }
    
    
    
    
}
