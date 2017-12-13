//
//  DataService.swift
//  PickSkip
//
//  Created by Eric Duong on 7/18/17.
//  Copyright © 2017 Aaron Kau. All rights reserved.
//

import Foundation
import Firebase
import AVFoundation

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
    
    func doesUsernameExist(username: String, completion: @escaping (_ exists: Bool) -> Void) {
        mainRef.child("usernames").observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.hasChild(username) {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func saveUser(uid: String, completion: @escaping (_ passed: Bool) -> Void) {
        
        let profileData: Dictionary<String, AnyObject> = ["phoneNumber": CurrentUser.phoneNumber as AnyObject,
                                                          "firstName" : CurrentUser.firstname as AnyObject,
                                                          "lastName": CurrentUser.lastname as AnyObject,
                                                          "age": CurrentUser.age as AnyObject,
                                                          "ropeIP": false as AnyObject,
                                                          "username": CurrentUser.username.lowercased() as AnyObject,
                                                          "notificationToken": InstanceID.instanceID().token() as AnyObject]
        let ropeData : Dictionary<String,AnyObject> = ["profile": profileData as AnyObject,
                                                       "ropeIP": false as AnyObject]
        
        self.mainRef.child("users").child(uid).setValue(ropeData){
            error, databaseReference in
            if let error = error  {
                print("error saving user: \(error.localizedDescription)")
                return
            }
            completion(true)
            print("saved user successfully")
        }
        self.mainRef.child("usernames").child(CurrentUser.username.lowercased()).setValue(uid)
        
//        mainRef.child("usernames").observeSingleEvent(of: .value) { (snapshot) in
//            if snapshot.hasChild(CurrentUser.username.lowercased()) {
//                let profileData: Dictionary<String, AnyObject> = ["phoneNumber": CurrentUser.phoneNumber as AnyObject,
//                                                               "firstName" : CurrentUser.firstname as AnyObject,
//                                                               "lastName": CurrentUser.lastname as AnyObject,
//                                                               "age": CurrentUser.age as AnyObject,
//                                                               "ropeIP": false as AnyObject,
//                                                               "username": CurrentUser.username as AnyObject,
//                                                               "notificationToken": InstanceID.instanceID().token() as AnyObject]
//                let ropeData : Dictionary<String,AnyObject> = ["profile": profileData as AnyObject,
//                                                               "ropeIP": false as AnyObject]
//
//                self.mainRef.child("users").child(uid).setValue(ropeData){
//                    error, databaseReference in
//                    if let error = error  {
//                        print("error saving user: \(error.localizedDescription)")
//                        return
//                    }
//                    completion(true)
//                    print("saved user successfully")
//                }
//                self.mainRef.child("usernames").child(CurrentUser.username).setValue(uid)
//            } else {
//                completion(false)
//            }
//        }
        
//        let userData: Dictionary<String, AnyObject> = ["phoneNumber": CurrentUser.phoneNumber as AnyObject,
//                                                 "firstName" : CurrentUser.firstname as AnyObject,
//                                                 "lastName": CurrentUser.lastname as AnyObject,
//                                                 "age": CurrentUser.age as AnyObject,
//                                                 "ropeIP": false as AnyObject,
//                                                 "username": CurrentUser.username as AnyObject,
//                                                 "notificationToken": InstanceID.instanceID().token() as AnyObject]
//        usersRef.child(uid).child("ropeIP").setValue(false)
//        mainRef.child("users").child(uid).child("profile").setValue(userData){
//            error, databaseReference in
//            if let error = error  {
//                print("error saving user: \(error.localizedDescription)")
//                return
//            }
//            print("saved user successfully")
//        }
//        mainRef.child("usernames").child(CurrentUser.username).setValue(uid)
    }
    
    func initialFetchRopesIP(completion: @escaping (_ ropeIP: RopeIP) -> Void) {
        print("fetching ropes")
        if let currentUser = Auth.auth().currentUser {
            mainRef.child("users").child(currentUser.uid).child("ropeIP").observe(.childAdded, with: {(snapshot) in
                    self.mainRef.child("ropesIP").child(snapshot.key).observeSingleEvent(of: .value, with: { (ropeshot) in
                        let _ropeIP = RopeIP()
                        _ropeIP.id = snapshot.key
                        _ropeIP.expirationDate = ropeshot.childSnapshot(forPath: "expirationDate").value as? Int
                        _ropeIP.title = ropeshot.childSnapshot(forPath: "title").value as? String
                        _ropeIP.contribution = ropeshot.childSnapshot(forPath: "contribution").value as? Int
                        completion(_ropeIP)
                    })
            })
        }
    }
    
    func updateContribution(_ ropeIPkey: String, _ contribution: Int) {
        mainRef.child("users").child((Auth.auth().currentUser?.uid)!).child("ropeIP").child(ropeIPkey).child("contribution").setValue(contribution)
    }
    
    func createRope(title: String) {
        let key = mainRef.child("ropes").childByAutoId().key
        let expirationDate = Date().millisecondsSince1970 + 43200000
        let random = Int(arc4random_uniform(2))
        var ropeData: Dictionary<String, AnyObject> = ["title": title as AnyObject,
                                                       "createdBy" : (Auth.auth().currentUser?.uid)! as AnyObject,
                                                       "expirationDate": expirationDate as AnyObject,
                                                       "nextRole": (1 - random) as AnyObject]
        
        mainRef.child("ropesIP").child(key).setValue(ropeData){
            error, databaseReference in
            if let error = error  {
                print("error saving Rope: \(error.localizedDescription)")
            }
        }
        
        mainRef.child("ropesIP").child(key).child("participants").child(Auth.auth().currentUser!.uid).setValue(random)
        
        ropeData["role"] = random as AnyObject
        ropeData["contribution"] = 0 as AnyObject
        ropeData["nextRole"] = nil
        mainRef.child("users").child((Auth.auth().currentUser?.uid)!).child("ropeIP").child(key).setValue(ropeData)
    }
    
    func join(ropeID: String, completion: @escaping (_ result: Bool) -> Void) {
        mainRef.child("ropesIP").child(ropeID).observeSingleEvent(of: .value) { (snapshot) in
            var ropeData = snapshot.value as! Dictionary<String, AnyObject>
            let currentRole = ropeData["nextRole"] as! Int
            self.mainRef.child("ropesIP").child(ropeID).updateChildValues(["nextRole": (1 - currentRole) as AnyObject])
            self.mainRef.child("ropesIP").child(ropeID).child("participants").updateChildValues([Auth.auth().currentUser!.uid: currentRole])
            
            ropeData["nextRole"] = nil
            ropeData["contribution"] = 0 as AnyObject
            ropeData["role"] = currentRole as AnyObject
            DataService.instance.usersRef.child(Auth.auth().currentUser!.uid).child("ropeIP").child(ropeID).setValue(ropeData) {
                error, databaseReference in
                if let error = error  {
                    print("error saving Rope: \(error.localizedDescription)")
                    completion(false)
                } else {
                    completion(true)
                }
            }
        }
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
    
    func setViewed(_ ropeID: String) {
        mainRef.child("users").child((Auth.auth().currentUser?.uid)!).child("ropes").child(ropeID).child("viewed").setValue(true)
    }
    
    func sendMedia(senderID: String, mediaURL: URL, mediaType: String, ropeIP: RopeIP, videoURL: URL?, image: Data?){
        
        let key = mainRef.childByAutoId().key
        let id = ropeIP.id!
        let date = Date()
        print("sending media")
        let pr: Dictionary<String, AnyObject> = ["mediaType": mediaType as AnyObject,
                                                 "mediaURL" : mediaURL.absoluteString as AnyObject,
                                                 "sentDate": Int(date.timeIntervalSince1970 * 1000) as AnyObject,
                                                 "senderID": senderID as AnyObject,
                                                 "senderName": "\(CurrentUser.firstname) \(CurrentUser.lastname)" as AnyObject]
        UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
            self.mainRef.child("ropesIP").child(id).child("media").child(key).updateChildValues(pr){
                error, databaseReference in
                if let error = error  {
                    print("error sending media DataService#sendMedia: \(error.localizedDescription)")
                }
                print("sucess sending message")
            }
            
            let uid = NSUUID().uuidString
            let ref = self.storageRef.child("\(uid).jpg")
            
            //add thumbnail
            if let videoURL = videoURL {
                let asset = AVURLAsset(url: videoURL, options: nil)
                let imgGenerator = AVAssetImageGenerator(asset: asset)
                imgGenerator.appliesPreferredTrackTransform = true
                do {
                    let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(0, 1), actualTime: nil)
                    let uiImage = UIImage(cgImage: cgImage)
                    _ = ref.putData(UIImageJPEGRepresentation(uiImage, 0.5)!, metadata: nil, completion: {(metadata, error) in
                        if let error  = error {
                            print("error: \(error.localizedDescription))")
                        } else {
                            let downloadURL = metadata?.downloadURL()
                            self.mainRef.child("ropesIP").child(id).child("thumbnail").child(key).setValue(downloadURL?.absoluteString){
                                error, databaseReference in
                                if let error = error  {
                                    print("error sending media DataService#sendMedia: \(error.localizedDescription)")
                                }
                            }
                        }
                    })
                } catch {
                    print("thumbnail error: \(error)")
                }
            }
        
        
        
        
        
        
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


