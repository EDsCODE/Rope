//
//  AddFriendViewController.swift
//  Rope
//
//  Created by Eric Duong on 11/23/17.
//  Copyright © 2017 Rope. All rights reserved.
//

import UIKit
import Firebase

struct FriendRequest {
    var requestID: String
    var senderID: String
    var status: String
}


class AddFriendViewController: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var requestsTableView: UITableView!
    
    var requests = [FriendRequest]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestsTableView.dataSource = self
        requestsTableView.delegate = self
        requestsTableView.register(UINib(nibName: "FriendRequestCell", bundle: nil), forCellReuseIdentifier: "friendRequest")
        checkForFriendRequests()
        // Do any additional setup after loading the view.
    }
    
    func checkForFriendRequests() {
        DataService.instance.usersRef.child(Auth.auth().currentUser!.uid).child("receivedRequests").observe(.value) { (snapshot) in
            for child in snapshot.children.allObjects as! [DataSnapshot] {
                if child.childSnapshot(forPath: "status").value as! String == "pending" {
                    let _request = FriendRequest(requestID: child.key, senderID: child.childSnapshot(forPath: "sender").value as! String, status: child.childSnapshot(forPath: "status").value as! String)
                    self.requests.append(_request)
                }
            }
            DispatchQueue.main.async {
                self.requestsTableView.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }

    @IBAction func sendRequest(_ sender: Any) {
        if let receiver = usernameField.text, !receiver.isEmpty {
            DataService.instance.sendFriendRequest(to: receiver)
        } else {
            let alert = UIAlertController(title: "Text Field is empty", message: "Please enter a username before sending request", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @objc func acceptButtonClicked(sender:UIButton) {
        let buttonRow = sender.tag
        let sender_Username = requests[buttonRow].senderID
        let requestID = requests[buttonRow].requestID
        
        DataService.instance.addFriend(requestID: requestID, senderUsername: sender_Username)
        self.requests.remove(at: buttonRow)
        print(buttonRow)
        self.requestsTableView.reloadData()
        
        print("accepted: \(buttonRow)")
    }
    @objc func declineButtonClicked(sender:UIButton) {
        let buttonRow = sender.tag
        print("declined: \(buttonRow)")
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension AddFriendViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
}

extension AddFriendViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendRequest", for: indexPath) as! FriendRequestCell
        cell.usernameLabel.text = requests[indexPath.row].senderID
        cell.acceptButton.tag = indexPath.row
        cell.acceptButton.addTarget(self, action: #selector(acceptButtonClicked(sender:)), for: .touchUpInside)
        cell.declineButton.tag = indexPath.row
        cell.declineButton.addTarget(self, action: #selector(declineButtonClicked(sender:)), for: .touchUpInside)
        return cell
    }
    
    
}
