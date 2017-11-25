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
        usersRef.child(uid).child("ropeIP").setValue(false)
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
    
    func createRope(title: String, participants: [User]) {
        let key = mainRef.child("ropes").childByAutoId().key
        let expirationDate = Date().millisecondsSince1970 + 43200000
        let random = Int(arc4random_uniform(4) + 1)
        var ropeData: Dictionary<String, AnyObject> = ["title": title as AnyObject,
                                                       "createdBy" : (Auth.auth().currentUser?.uid)! as AnyObject,
                                                       "knotCount": 0 as AnyObject,
                                                       "expirationDate": expirationDate as AnyObject,
                                                       "nextRole": (random + 1) % 4 as AnyObject]
        for user in participants {
            let rr: Dictionary<String, AnyObject> = ["sentDate": Date().millisecondsSince1970 as AnyObject,
                                                     "title": title as AnyObject,
                                                     "sender" : CurrentUser.username as AnyObject,
                                                     "status" : "pending" as AnyObject]
            usersRef.child(user.uid!).child("ropeRequests").child(key).setValue(rr)
        }
        
        mainRef.child("ropesIP").child(key).setValue(ropeData){
            error, databaseReference in
            if let error = error  {
                print("error saving Rope: \(error.localizedDescription)")
            }
        }
        
        mainRef.child("ropesIP").child(key).child("participants").child(Auth.auth().currentUser!.uid).setValue(random){
            error, databaseReference in
            if let error = error  {
                print("error saving Rope participants: \(error.localizedDescription)")
            }
        }
        
        ropeData["role"] = random as AnyObject
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
    
    func sendMedia(senderID: String, mediaURL: URL, mediaType: String, ropeIP: RopeIP){
        print("sending media!")
        let key = mainRef.childByAutoId().key
        let date = Date()
        let pr: Dictionary<String, AnyObject> = ["mediaType": mediaType as AnyObject,
                                                 "mediaURL" : mediaURL.absoluteString as AnyObject,
                                                 "sentDate": Int(date.timeIntervalSince1970 * 1000) as AnyObject,
                                                 "senderID": senderID as AnyObject]
        
        //update knotcount
        mainRef.child("ropesIP").child(ropeIP.id!).child("knotCount").setValue(ropeIP.knotCount!)
        
        usersRef.child(Auth.auth().currentUser!.uid).child("ropeIP").child(ropeIP.id!).child("knotCount").setValue(ropeIP.knotCount!)
        
        mainRef.child("ropesIP").child(ropeIP.id!).child("media").child(key).updateChildValues(pr){
            error, databaseReference in
            if let error = error  {
                print("error sending media DataService#sendMedia: \(error.localizedDescription)")
            }
        }
    }
    
    func addFriend(requestID: String, senderUsername: String) {
        //change status to accepted
        DataService.instance.usersRef.child(Auth.auth().currentUser!.uid).child("receivedRequests").child(requestID).child("status").setValue("accepted")
        
        //get uid of sender username
        DataService.instance.mainRef.child("usernames").child(senderUsername).observeSingleEvent(of: .value) { (uid) in
            
            //get profile info of sender username
            DataService.instance.usersRef.child(uid.value as! String).child("profile").observeSingleEvent(of: .value, with: { (info) in
                let firstname = info.childSnapshot(forPath: "firstName").value as! String
                let lastname = info.childSnapshot(forPath: "lastName").value as! String
                let pr: Dictionary<String, AnyObject> = ["firstname" : firstname as AnyObject,
                                                         "lastname" : lastname as AnyObject,
                                                         "uid" : uid.value as AnyObject
                ]
                //set value for receiver of request
                DataService.instance.usersRef.child(Auth.auth().currentUser!.uid).child("friends").child(senderUsername).setValue(pr, withCompletionBlock: { (error, _) in
                    if let _ = error {
                        DataService.instance.usersRef.child(Auth.auth().currentUser!.uid).child("receivedRequests").child(requestID).child("status").setValue("pending")
                    } else {
                        DataService.instance.usersRef.child(Auth.auth().currentUser!.uid).child("receivedRequests").child(requestID).removeValue()
                    }
                })
            })
            
            let user: Dictionary<String, AnyObject> = [ "firstname": CurrentUser.username as AnyObject,
                                                        "lastname": CurrentUser.lastname as AnyObject,
                                                        "uid": Auth.auth().currentUser!.uid as AnyObject
            ]
            
            DataService.instance.usersRef.child(uid.value as! String).child("friends").child(CurrentUser.username).setValue(user)
            
            
        }
    }
    
    func sendFriendRequest(to username: String) {
        let key = mainRef.childByAutoId().key
        let pr: Dictionary<String, AnyObject> = ["sentDate": Date().millisecondsSince1970 as AnyObject,
                                                 "receiver" : username as AnyObject,
                                                 "sender" : CurrentUser.username as AnyObject,
                                                 "status" : "pending" as AnyObject]
        DataService.instance.mainRef.child("users").child(Auth.auth().currentUser!.uid).child("sentRequests").child(key).setValue(pr)
    }
    
    func acceptRopeIP(ropeID: String) {
        mainRef.child("ropesIP").child(ropeID).observeSingleEvent(of: .value) { (snapshot) in
            let role = snapshot.childSnapshot(forPath: "nextRole").value as! Int
            
            let ropeIPData: Dictionary<String, AnyObject> = ["createdBy": snapshot.childSnapshot(forPath: "createdBy").value as AnyObject,
                                                     "expirationDate" : snapshot.childSnapshot(forPath: "expirationDate").value as AnyObject,
                                                     "knotCount" : snapshot.childSnapshot(forPath: "knotCount").value as AnyObject,
                                                     "role" : role as AnyObject,
                                                     "title": snapshot.childSnapshot(forPath: "title").value as AnyObject]
            self.mainRef.child("ropesIP").child(ropeID).child("nextRole").setValue((role + 1) % 4)
            self.mainRef.child("ropesIP").child(ropeID).child("participants").updateChildValues([Auth.auth().currentUser!.uid: role])
            self.usersRef.child(Auth.auth().currentUser!.uid).child("ropeIP").child(snapshot.key).setValue(ropeIPData)
        }
        self.usersRef.child(Auth.auth().currentUser!.uid).child("ropeRequests").child(ropeID).removeValue()
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


