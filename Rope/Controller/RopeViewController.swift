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
    
    var ropes = [Rope]()
    var selectedIndex = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ropeCollectionView.delegate = self
        ropeCollectionView.dataSource = self
        self.setupRopeObserver()
        
        //load layout async so the tab button has no lag
        DispatchQueue.global(qos: .userInitiated).async {
            let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
            layout.minimumInteritemSpacing = 3
            layout.minimumLineSpacing = 6
            DispatchQueue.main.async {
                layout.itemSize = CGSize(width: self.view.frame.width/2.1, height: self.view.frame.width/2.1)
                self.ropeCollectionView.collectionViewLayout = layout
            }
        }
        // Do any additional setup after loading the view.
    }
    
    func setupRopeObserver() {
        DataService.instance.usersRef.child((Auth.auth().currentUser?.uid)!).child("ropes").observe(.value) { (snapshot) in
            if let ropeData = snapshot.value as? Dictionary<String, AnyObject>{
                for (key,value) in ropeData as! [String:Dictionary<String, AnyObject>]{
                    let _rope = Rope()
                    _rope.expirationDate = value["expirationDate"] as! Int
                    _rope.knotCount = value["knotCount"] as! Int
                    _rope.creatorID = value["createdBy"] as! String
                    _rope.title = value["title"] as! String
                    _rope.participants = [User]()
                    _rope.media = [Media]()
                    _rope.id = key
                    self.ropes.append(_rope)
                    
                    //start loading media and push onto async queues
                    DispatchQueue.global(qos: .userInitiated).async {
                        DataService.instance.mainRef.child("ropes").child(key).child("media").queryOrdered(byChild: "sentDate").queryStarting(atValue: 0).observeSingleEvent(of: .value, with: { (snapshot) in
                            if let mediaDictionary = snapshot.value as? Dictionary<String,AnyObject> {
                                for (key,value) in mediaDictionary as! [String:Dictionary<String, AnyObject>] {
                                    let _media = Media()
                                    _media.senderID = value["senderID"] as! String
                                    _media.key = key
                                    _media.mediaType = value["mediaType"] as! String
                                    _media.sentDate = value["sentDate"] as! Int
                                    print(_media.sentDate)
                                    _media.url = URL(string: value["mediaURL"] as! String)
                                    _rope.media.append(_media)
                                    DispatchQueue.global(qos: .utility).async {
                                        _media.load {
                                            print("media loaded")
                                        }
                                    }
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
                self.ropeCollectionView.reloadData()
            }
        }
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

extension RopeViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        performSegue(withIdentifier: "showRope", sender: self)
    }
    
}

extension RopeViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "rope", for: indexPath) as! RopeCell
        cell.titleLabel.text = "hello"
        cell.rope = ropes[indexPath.row]
        cell.titleLabel.text = cell.rope.title
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return ropes.count
    }
    
}

