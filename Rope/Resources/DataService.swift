//
//  DataService.swift
//  PickSkip
//
//  Created by Eric Duong on 7/18/17.
//  Copyright © 2017 Aaron Kau. All rights reserved.
//

import Foundation
import Firebase

class DataService {
    private static let _instance = DataService()
    
    static var instance: DataService {
        return _instance
    }
    
    var mainRef: DatabaseReference {
        return Database.database().reference()
    }
    
    var usersRef: DatabaseReference {
        return mainRef.child("users")
    }
    
    var storageRef: StorageReference {
        return Storage.storage().reference(forURL: "gs://rope-1ea25.appspot.com")
    }
    
    func saveUser(uid: String) {
        
        let userData: Dictionary<String, AnyObject> = ["phoneNumber": CurrentUser.phoneNumber as AnyObject,
                                                 "firstName" : CurrentUser.firstname as AnyObject,
                                                 "lastName": CurrentUser.lastname as AnyObject,
                                                 "age": CurrentUser.age as AnyObject,
                                                 "ropeIP": false as AnyObject,
                                                 "username": CurrentUser.username as AnyObject]
        mainRef.child("users").child(uid).child("profile").setValue(userData){
            error, databaseReference in
            if let error = error  {
                print("error saving user: \(error.localizedDescription)")
            }
            print("saved user successfully")
        }
        
        mainRef.child("usernames").child(CurrentUser.username).setValue(uid)
    }
    
    func initialFetchRopesIP(completion: @escaping (_ ropeIP: RopeIP) -> Void) {
        print("fetching ropes")
        if let currentUser = Auth.auth().currentUser {
            mainRef.child("users").child(currentUser.uid).child("ropeIP").observe(.childAdded, with: {(snapshot) in
                    self.mainRef.child("ropesIP").child(snapshot.key).observeSingleEvent(of: .value, with: { (ropeshot) in
                        let rope = RopeIP()
                        rope.id = snapshot.key
                        rope.expirationDate = ropeshot.childSnapshot(forPath: "expirationDate").value as? Int
                        rope.knotCount = ropeshot.childSnapshot(forPath: "knotCount").value as? Int
                        rope.title = ropeshot.childSnapshot(forPath: "title").value as? String
                        
                        completion(rope)
                        
                    })
                
                
            })
        }
    }
    
//    func setupRopeIPListener() {
//        if let currentUser = Auth.auth().currentUser {
//            mainRef.child("users").child(currentUser.uid).child("ropeIP").observe(.childAdded, with: { (snapshot) in
//                print(snapshot.key)
//            })
//        }
//    }
    
    func createRope(title: String, participants: inout [User]) {
        let key = mainRef.child("ropes").childByAutoId().key
        
        var ropeData: Dictionary<String, AnyObject> = ["title": title as AnyObject,
                                                       "createdBy" : (Auth.auth().currentUser?.uid)! as AnyObject,
                                                       "knotCount": 0 as AnyObject,
                                                       "expirationDate": Date().millisecondsSince1970 + 43200000 as AnyObject]
        
        var participantsDictionary = Dictionary<String,Int>()
        
        let currentUser = User()
        currentUser.firstname = CurrentUser.firstname
        currentUser.lastname = CurrentUser.lastname
        currentUser.uid = Auth.auth().currentUser?.uid
        currentUser.username = CurrentUser.username

        participants.append(currentUser)
        var random = Int(arc4random_uniform(4) + 1)
        
        for participant in participants {
            participantsDictionary[participant.uid!] = random % 4
            random += 1
        }
        
        mainRef.child("ropesIP").child(key).setValue(ropeData){
            error, databaseReference in
            if let error = error  {
                print("error saving Rope: \(error.localizedDescription)")
            }
        }
        
        mainRef.child("ropesIP").child(key).child("participants").setValue(participantsDictionary){
            error, databaseReference in
            if let error = error  {
                print("error saving Rope participants: \(error.localizedDescription)")
            }
        }
        
        ropeData["role"] = participantsDictionary[(Auth.auth().currentUser?.uid)!] as AnyObject
        
        mainRef.child("users").child((Auth.auth().currentUser?.uid)!).child("ropeIP").child(key).setValue(ropeData)
        
    }
    
    func doesUserExist(uid: String, completion: @escaping (_ result: Bool) -> Void) {
        mainRef.child("users").observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            if snapshot.hasChild(uid) {
                completion(true)
            } else {
                completion(false)
            }
        })
    }
    
    func fetchCurrentUser(uid: String) {
        usersRef.child(uid).child("profile").observeSingleEvent(of: .value) { (snapshot) in
            CurrentUser.username = snapshot.childSnapshot(forPath: "username").value as! String
            CurrentUser.firstname = snapshot.childSnapshot(forPath: "firstName").value as! String
            CurrentUser.lastname = snapshot.childSnapshot(forPath: "lastName").value as! String
            CurrentUser.age = snapshot.childSnapshot(forPath: "age").value as! String
            CurrentUser.phoneNumber = snapshot.childSnapshot(forPath: "phoneNumber").value as! String
        }
    }
    
    func leaveCurrentRope() {
         mainRef.child("users").child((Auth.auth().currentUser?.uid)!).child("ropeIP").setValue(false)
    }
}

extension Date {
    var millisecondsSince1970:Int {
        return Int((self.timeIntervalSince1970 * 1000.0).rounded())
    }
    
    init(milliseconds:Int) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds / 1000))
    }
}


