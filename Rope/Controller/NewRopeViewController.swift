//
//  NewRopeViewController.swift
//  Rope
//
//  Created by Eric Duong on 11/5/17.
//  Copyright © 2017 Rope. All rights reserved.
//

import UIKit
import KSTokenView
import Firebase

class NewRopeViewController: UIViewController {

    var createButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white
        button.layer.borderWidth = 1.5
        button.layer.borderColor = UIColor.black.cgColor
        button.titleLabel?.textAlignment = .center
        button.setTitle("Create", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.setTitleColor(.white, for: .highlighted)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 30.0)
        return button
    }()
    
    var cancelButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white
        button.layer.borderWidth = 1.5
        button.layer.borderColor = UIColor.black.cgColor
        button.titleLabel?.textAlignment = .center
        button.setTitle("Cancel", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.setTitleColor(.white, for: .highlighted)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 30.0)
        return button
    }()
    
    var friends = Dictionary<String,User>()
    var friendNames = [String]()
    var participants = [User]()
    var keyboardIsActive = false
    var tokenView: KSTokenView!
    var titleView: UITextField!
    var createButtonBottomConstraint: NSLayoutConstraint!
    var cancelButtonBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tokenView = KSTokenView(frame: CGRect(x: 15, y: UIApplication.shared.statusBarFrame.height + 50, width: self.view.bounds.width, height: 40.0))
        tokenView.delegate = self
        tokenView.promptText = "With: "
        tokenView.placeholder = "Type to search for friends"
        tokenView.descriptionText = "Friends"
        tokenView.style = .squared
        
        titleView = UITextField(frame: CGRect(x: 0, y: UIApplication.shared.statusBarFrame.height, width: self.view.bounds.width, height: 50.0))
        titleView.textAlignment = .center
        titleView.placeholder = "Title of Rope"
        titleView.font = UIFont.systemFont(ofSize: 30.0)
        view.addSubview(titleView)
        view.addSubview(tokenView)
        view.addSubview(cancelButton)
        view.addSubview(createButton)
        
        let constraints = [
            createButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            createButton.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.5),
            createButton.heightAnchor.constraint(equalToConstant: 40),
            cancelButton.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.5),
            cancelButton.heightAnchor.constraint(equalToConstant: 40),
            cancelButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
        ]
        
        //decalare bottom button constraints separately so they can be bound to keyboard
        cancelButtonBottomConstraint = NSLayoutConstraint(item: cancelButton, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: 0)
        cancelButtonBottomConstraint?.isActive = true
        createButtonBottomConstraint = NSLayoutConstraint(item: createButton, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: 0)
        createButtonBottomConstraint?.isActive = true
        
        NSLayoutConstraint.activate(constraints)
        setupCancelButton()
        setupCreateButton()
        setupKeyboardObserver()
        fetchFriends()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        keyboardIsActive = false
        NotificationCenter.default.removeObserver(self)
    }
    
    
    func setupCancelButton() {
        let cancelGesture = UITapGestureRecognizer(target: self, action: #selector(cancelRopeAction(gesture:)))
        cancelButton.addGestureRecognizer(cancelGesture)
    }
    
    func setupCreateButton() {
        let createGesture = UITapGestureRecognizer(target: self, action: #selector(createRopeAction(gesture:)))
        createButton.addGestureRecognizer(createGesture)
    }
    
    @objc func cancelRopeAction(gesture: UITapGestureRecognizer){
        dismiss(animated: false, completion: nil)
    }
    
    @objc func createRopeAction(gesture: UITapGestureRecognizer) {
        let tokens = tokenView.tokens()
        if tokens?.count != 0 {
            for token in tokens! {
                let object = token.object as! String
                if !participants.contains(friends[object]!) {
                    participants.append(friends[object]!)
                }
            }
        }
        
        if let title = titleView.text {
            DataService.instance.createRope(title: title, participants: &participants)
        }
        
        dismiss(animated: false, completion: nil)
    }
    
    func setupKeyboardObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    ///Called when keyboard will be shown.
    @objc func handleKeyboardWillShow(notification: NSNotification) {
        
        let keyboardAnimationDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! Double
        let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        
        if !keyboardIsActive {
            UIView.animate(withDuration: keyboardAnimationDuration, animations: {
                
                self.cancelButtonBottomConstraint.constant = -(keyboardSize?.height)!
                self.createButtonBottomConstraint.constant = -(keyboardSize?.height)!
                self.view.layoutIfNeeded()
                self.keyboardIsActive = true
            })
        }
        
    }
    
    ///Called when keyboard will be hidden.
    @objc func handleKeyboardWillHide(notification: NSNotification) {
        let keyboardAnimationDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! Double
        
        if keyboardIsActive {
            UIView.animate(withDuration: keyboardAnimationDuration, animations: {
                self.cancelButtonBottomConstraint.constant = 0
                self.createButtonBottomConstraint.constant = 0
                self.view.layoutIfNeeded()
                self.keyboardIsActive = false
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchFriends() {
        if let myID = Auth.auth().currentUser?.uid {
            DataService.instance.mainRef.child("users").child(myID).child("friends").observe(.value) {
                (snapshot) in
                for friend in snapshot.children.allObjects as! [DataSnapshot] {
                    let user = User()
                    user.username = friend.key
                    user.firstname = friend.childSnapshot(forPath: "firstname").value as? String
                    user.lastname = friend.childSnapshot(forPath: "lastname").value as? String
                    user.uid = friend.childSnapshot(forPath: "uid").value as? String
//
                    self.friendNames.append(user.firstname! + " " + user.lastname!)
                    self.friends[user.firstname! + " " + user.lastname!] = user
//
                }
                
            }
            
        }
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

extension NewRopeViewController: KSTokenViewDelegate {
    func tokenView(_ tokenView: KSTokenView, performSearchWithString string: String, completion: ((_ results: Array<AnyObject>) -> Void)?) {
        if (string.isEmpty){
            completion!(friendNames as Array<AnyObject>)
            return
        }
        
        var data: Array<String> = []
        for value in friendNames {
            if value.lowercased().range(of: string.lowercased()) != nil {
                data.append(value)
            }
        }
        completion!(data as Array<AnyObject>)
    }
    
    func tokenView(_ tokenView: KSTokenView, displayTitleForObject object: AnyObject) -> String {

        return object as! String
    }
    
    func tokenView(_ tokenView: KSTokenView, shouldAddToken token: KSToken) -> Bool {
        
        // Restrict adding token based on token text
        if token.title == "f" {
            return false
        }
        
        // If user input something, it can be checked
        //        print(tokenView.text)
        
        return true
    }
}
