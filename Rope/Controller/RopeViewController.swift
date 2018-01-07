//
//  RopeViewController.swift
//  Rope
//
//  Created by Eric Duong on 11/6/17.
//  Copyright © 2017 Rope. All rights reserved.
//

import UIKit
import Firebase

class RopeViewController: UIViewController {

    @IBOutlet weak var ropeCollectionView: UICollectionView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var promptLabel: UILabel!
    
    var ropes = [Rope]()
    var selectedIndex = 0
    
    var latestQueryPoint = 0
    var earliestQueryPoint = Int.max
    var loadingMore = false
    var initialLoadComplete = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ropeCollectionView.delegate = self
        ropeCollectionView.dataSource = self
        self.initialRopeFetch()
        shouldPromptAppear()
        //load layout async so the tab button has no lag
        DispatchQueue.global(qos: .userInitiated).async {
            let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
            layout.minimumInteritemSpacing = 3
            layout.minimumLineSpacing = 6
            DispatchQueue.main.async {
                layout.itemSize = CGSize(width: self.view.frame.width/2.1, height: self.view.frame.height/2.1)
                self.ropeCollectionView.collectionViewLayout = layout
            }
        }
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //set navigation bar items visible but keep bar clear
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    func shouldPromptAppear() {
        if ropeCollectionView.numberOfItems(inSection: 0) == 0 {
            promptLabel.isHidden = false
            self.view.bringSubview(toFront: promptLabel)
        } else {
            promptLabel.isHidden = true
        }
    }
    
    func initialRopeFetch() {
        DataService.instance.usersRef.child((Auth.auth().currentUser?.uid)!).child("ropes").queryOrdered(byChild: "expirationDate").queryLimited(toLast: 6).observeSingleEvent(of: .value) { (snapshot) in
            
            if let ropeData = snapshot.value as? Dictionary<String, AnyObject>{
                for (key,value) in ropeData as! [String:Dictionary<String, AnyObject>]{
                    
                    let _rope = Rope()
                    _rope.expirationDate = value["expirationDate"] as! Int
                    _rope.creatorID = value["createdBy"] as! String
                    _rope.title = value["title"] as! String
                    _rope.participants = [User]()
                    _rope.media = [Media]()
                    _rope.id = key
                    _rope.viewed = value["viewed"] as! Bool
                    
                    if _rope.expirationDate < self.earliestQueryPoint {
                        self.earliestQueryPoint = _rope.expirationDate
                    }
                    
                    if _rope.expirationDate > self.latestQueryPoint {
                        self.latestQueryPoint = _rope.expirationDate
                    }
                    
                    //get random thumbnail
                    let thumbnail = value["thumbnail"] as! Dictionary<String, String>
                    let index: Int = Int(arc4random_uniform(UInt32(thumbnail.count)))
                    let imageURL = Array(thumbnail.values)[index]
                    let storageURL = Storage.storage().reference(forURL: imageURL)
                    storageURL.getData(maxSize: 1073741824, completion: {(data, error) in
                        if let error = error {
                            print("Error loading image from Media#load: \(error.localizedDescription)")
                        } else {
                            _rope.thumbnailData = data!
                            
                            for rope in self.ropes {
                                if rope.id == snapshot.key {
                                    return
                                }
                            }
                            
                            let index = self.ropes.insertionIndexOf(elem: _rope) { $0.expirationDate > $1.expirationDate }
                            self.ropes.insert(_rope, at: index)
                            if self.ropes.count == ropeData.count {
                                self.initialLoadComplete = true
                                self.ropeCollectionView.reloadData()
                                self.shouldPromptAppear()
                                self.setupRopeObserver()
                            }
                            
                            DispatchQueue.main.async {
                                self.ropeCollectionView.reloadData()
                            }
                            
                            //start loading media and push onto async queues
                            DispatchQueue.global(qos: .userInitiated).async {
                                DataService.instance.mainRef.child("ropes").child(key).child("media").queryOrdered(byChild: "sentDate").queryStarting(atValue: 0).observeSingleEvent(of: .value, with: { (snapshot) in
                                    if let mediaDictionary = snapshot.value as? Dictionary<String,AnyObject> {
                                        for (key,value) in mediaDictionary as! [String:Dictionary<String, AnyObject>] {
                                            let _media = Media()
                                            _media.senderName = value["senderName"] as! String
                                            _media.senderID = value["senderID"] as! String
                                            _media.key = key
                                            _media.mediaType = value["mediaType"] as! String
                                            _media.sentDate = value["sentDate"] as! Int
                                            _media.loadState = .unloaded

                                            _media.url = URL(string: value["mediaURL"] as! String)

                                            let index = _rope.media.insertionIndexOf(elem: _media) { $0.sentDate < $1.sentDate }

                                            _rope.media.insert(_media, at: index)
//                                            DispatchQueue.global(qos: .utility).async {
//                                                _media.load {
//                                                    print("media loaded")
//                                                }
//                                            }
                                        }
                                    }
                                })
                            }
                            
                            //load users async because they're unneeded at the moment
                            DispatchQueue.global(qos: .userInitiated).async {
                                for (key,_) in value["participants"] as! Dictionary<String, Int>{
                                    DataService.instance.usersRef.child(key).child("profile").observeSingleEvent(of: .value, with: { (snapshot) in
                                        if let dictionary = snapshot.value as? Dictionary<String, AnyObject> {
                                            let _user = User()
                                            _user.firstname = (dictionary["firstName"] as! String)
                                            _user.lastname = dictionary["lastName"] as? String
                                            _user.username = dictionary["username"] as? String
                                            _user.uid = key
                                            _rope.participants.append(_user)
                                        }
                                    })
                                }
                            }
                        }
                    })
                    
                }
                
            } else {
                self.setupRopeObserver()
            }
        }
    }
    
    func setupRopeObserver() {
        DataService.instance.usersRef.child((Auth.auth().currentUser?.uid)!).child("ropes").queryOrdered(byChild: "expirationDate").queryLimited(toLast: 1).observe(.childAdded) { (snapshot) in
            
            if let ropedata = snapshot.value as? [String: AnyObject]{
                let _rope = Rope()
                _rope.expirationDate = ropedata["expirationDate"] as! Int
                _rope.creatorID = ropedata["createdBy"] as! String
                _rope.title = ropedata["title"] as! String
                _rope.participants = [User]()
                _rope.media = [Media]()
                _rope.id = snapshot.key
                _rope.viewed = ropedata["viewed"] as! Bool
                
                if _rope.expirationDate < self.earliestQueryPoint {
                    self.earliestQueryPoint = _rope.expirationDate
                }
                
                if _rope.expirationDate > self.latestQueryPoint {
                    self.latestQueryPoint = _rope.expirationDate
                }
                
                
                //get random thumbnail
                let thumbnail = ropedata["thumbnail"] as! Dictionary<String, String>
                let index: Int = Int(arc4random_uniform(UInt32(thumbnail.count)))
                let imageURL = Array(thumbnail.values)[index]
                let storageURL = Storage.storage().reference(forURL: imageURL)
                storageURL.getData(maxSize: 1073741824, completion: {(data, error) in
                    if let error = error {
                        print("Error loading image from Media#load: \(error.localizedDescription)")
                    } else {
                        
                        _rope.thumbnailData = data!
                        
                        for rope in self.ropes {
                            //Don't add new media if already in list
                            if rope.id == snapshot.key {
                                return
                            }
                        }
                        
                        let index = self.ropes.insertionIndexOf(elem: _rope) { $0.expirationDate > $1.expirationDate }
                        
                        self.ropes.insert(_rope, at: index)
                        
                        DispatchQueue.main.async {
                            self.ropeCollectionView.reloadData()
                        }
                        
                        //start loading media and push onto async queues
                        DispatchQueue.global(qos: .userInitiated).async {
                            DataService.instance.mainRef.child("ropes").child(snapshot.key).child("media").queryOrdered(byChild: "sentDate").queryStarting(atValue: 0).observeSingleEvent(of: .value, with: { (snapshot) in
                                if let mediaDictionary = snapshot.value as? Dictionary<String,AnyObject> {
                                    for (key,value) in mediaDictionary as! [String:Dictionary<String, AnyObject>] {
                                        let _media = Media()
                                        _media.senderName = value["senderName"] as! String
                                        _media.senderID = value["senderID"] as! String
                                        _media.key = key
                                        _media.mediaType = value["mediaType"] as! String
                                        _media.sentDate = value["sentDate"] as! Int
                                        _media.url = URL(string: value["mediaURL"] as! String)
                                        _media.loadState = .unloaded

                                        let index = _rope.media.insertionIndexOf(elem: _media) { $0.sentDate < $1.sentDate }
                                        _rope.media.insert(_media, at: index)
//                                        DispatchQueue.global(qos: .utility).async {
//                                            _media.load {
//                                                print("media loaded")
//                                            }
//                                        }
                                    }
                                }
                            })
                        }
                        
                        //load users async because they're unneeded at the moment
                        DispatchQueue.global(qos: .userInitiated).async {
                            for (key,_) in ropedata["participants"] as! Dictionary<String, Int>{
                                DataService.instance.usersRef.child(key).child("profile").observeSingleEvent(of: .value, with: { (snapshot) in
                                    if let dictionary = snapshot.value as? Dictionary<String, AnyObject> {
                                        let _user = User()
                                        _user.firstname = (dictionary["firstName"] as! String)
                                        _user.lastname = dictionary["lastName"] as? String
                                        _user.username = dictionary["username"] as? String
                                        _user.uid = key
                                        _rope.participants.append(_user)
                                    }
                                })
                            }
                        }
                    }
                })
            }
            self.ropeCollectionView.reloadData()
            self.shouldPromptAppear()
        }
        
    }
    
    func loadmore() {
        print(self.latestQueryPoint)
        print(self.earliestQueryPoint)
        DataService.instance.usersRef.child((Auth.auth().currentUser?.uid)!).child("ropes").queryOrdered(byChild: "expirationDate").queryEnding(atValue: self.ropes[self.ropes.count - 1].expirationDate - 1).queryLimited(toLast: 1).observeSingleEvent(of: .value) { (snapshot) in
            if let ropeData = snapshot.value as? Dictionary<String, AnyObject>{
                for (key,value) in ropeData as! [String:Dictionary<String, AnyObject>]{
                    if value["expirationDate"] == nil {
                        return
                    }
                    let _rope = Rope()
                    _rope.expirationDate = value["expirationDate"] as! Int
                    _rope.creatorID = value["createdBy"] as! String
                    _rope.title = value["title"] as! String
                    _rope.participants = [User]()
                    _rope.media = [Media]()
                    _rope.id = key
                    _rope.viewed = value["viewed"] as! Bool
                    
                    if _rope.expirationDate < self.earliestQueryPoint {
                        self.earliestQueryPoint = _rope.expirationDate
                    }
                    
                    if _rope.expirationDate > self.latestQueryPoint {
                        self.latestQueryPoint = _rope.expirationDate
                    }
                    
                    //get random thumbnail
                    let thumbnail = value["thumbnail"] as! Dictionary<String, String>
                    let index: Int = Int(arc4random_uniform(UInt32(thumbnail.count)))
                    let imageURL = Array(thumbnail.values)[index]
                    let storageURL = Storage.storage().reference(forURL: imageURL)
                    storageURL.getData(maxSize: 1073741824, completion: {(data, error) in
                        if let error = error {
                            print("Error loading image from Media#load: \(error.localizedDescription)")
                        } else {
                            _rope.thumbnailData = data!
                            
                            for rope in self.ropes {
                                if rope.id == snapshot.key {
                                    return
                                }
                            }
                            
                            let index = self.ropes.insertionIndexOf(elem: _rope) { $0.expirationDate > $1.expirationDate }
                            self.ropes.insert(_rope, at: index)
                            self.loadingMore = false
                            
                            DispatchQueue.main.async {
                                self.ropeCollectionView.reloadData()
                            }
                            
                            //start loading media and push onto async queues
                            DispatchQueue.global(qos: .userInitiated).async {
                                DataService.instance.mainRef.child("ropes").child(key).child("media").queryOrdered(byChild: "sentDate").queryStarting(atValue: 0).observeSingleEvent(of: .value, with: { (snapshot) in
                                    if let mediaDictionary = snapshot.value as? Dictionary<String,AnyObject> {
                                        for (key,value) in mediaDictionary as! [String:Dictionary<String, AnyObject>] {
                                            let _media = Media()
                                            _media.senderName = value["senderName"] as! String
                                            _media.senderID = value["senderID"] as! String
                                            _media.key = key
                                            _media.mediaType = value["mediaType"] as! String
                                            _media.sentDate = value["sentDate"] as! Int
                                            _media.loadState = .unloaded

                                            _media.url = URL(string: value["mediaURL"] as! String)

                                            let index = _rope.media.insertionIndexOf(elem: _media) { $0.sentDate < $1.sentDate }

                                            _rope.media.insert(_media, at: index)
//                                            DispatchQueue.global(qos: .utility).async {
//                                                _media.load {
//                                                    print("media loaded")
//                                                }
//                                            }
                                        }
                                    }
                                })
                            }
                            
                            //load users async because they're unneeded at the moment
                            DispatchQueue.global(qos: .userInitiated).async {
                                for (key,_) in value["participants"] as! Dictionary<String, Int>{
                                    DataService.instance.usersRef.child(key).child("profile").observeSingleEvent(of: .value, with: { (snapshot) in
                                        if let dictionary = snapshot.value as? Dictionary<String, AnyObject> {
                                            let _user = User()
                                            _user.firstname = (dictionary["firstName"] as! String)
                                            _user.lastname = dictionary["lastName"] as? String
                                            _user.username = dictionary["username"] as? String
                                            _user.uid = key
                                            _rope.participants.append(_user)
                                        }
                                    })
                                }
                            }
                        }
                    })
                }
                self.ropeCollectionView.reloadData()
                self.shouldPromptAppear()
            } else {
                self.loadingMore = false
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showRope" {
            let destination = segue.destination as? RopeDisplayViewController
            destination?.rope = ropes[selectedIndex]
        }
    }

}

extension Array {
    func insertionIndexOf(elem: Element, isOrderedBefore: (Element, Element) -> Bool) -> Int {
        var lo = 0
        var hi = self.count - 1
        while lo <= hi {
            let mid = (lo + hi)/2
            if isOrderedBefore(self[mid], elem) {
                lo = mid + 1
            } else if isOrderedBefore(elem, self[mid]) {
                hi = mid - 1
            } else {
                return mid // found at position mid
            }
        }
        return lo // not found, would be inserted at position lo
    }
}

extension RopeViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        let cell = collectionView.cellForItem(at: indexPath) as! RopeCell
        print(cell.contentView.frame)
        let fakeImage = UIImageView(frame: cell.contentView.convert(cell.contentView.frame, to: self.view))
        fakeImage.image = cell.ropeImage.image!
        //self.view.addSubview(fakeImage)
        UIView.animate(withDuration: 0.15, animations: {
            fakeImage.frame = self.view.bounds
            self.view.addSubview(fakeImage)
        }) { (_) in
            self.performSegue(withIdentifier: "showRope", sender: self)
            DispatchQueue.main.async {
                fakeImage.removeFromSuperview()
            }
        }
        cell.rope.viewed = true
        DataService.instance.setViewed(cell.rope.id)
        self.ropeCollectionView.reloadData()
        
        //performSegue(withIdentifier: "showRope", sender: self)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if (indexPath.section == 0 &&
            indexPath.row == self.ropes.count - 1 &&
            !self.loadingMore &&
            self.initialLoadComplete == true) {
            self.loadingMore = true
            self.loadmore()
        }
    }
    
}

extension RopeViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        shouldPromptAppear()
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "rope", for: indexPath) as! RopeCell
        cell.titleLabel.text = "hello"
        cell.rope = ropes[indexPath.row]
        cell.titleLabel.text = cell.rope.title
        cell.ropeImage.image = UIImage(data: cell.rope.thumbnailData)
        if cell.rope.viewed {
            cell.newLabel.isHidden = true
        } else {
            cell.newLabel.isHidden = false
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ropes.count
    }
    
}

