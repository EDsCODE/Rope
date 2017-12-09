//
//  ViewController.swift
//  Rope
//
//  Created by Eric Duong on 10/25/17.
//  Copyright © 2017 Rope. All rights reserved.
//

import UIKit
import Firebase

class VerificationViewController: UIViewController {
    
    let codeField: UITextField = {
        let field = UITextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        var placeHolder = NSMutableAttributedString()
        let placeholdertext  = "000000"
        
        // Set the Font
        placeHolder = NSMutableAttributedString(string: placeholdertext, attributes:
            [NSAttributedStringKey.font:UIFont(name: "Nunito-Light", size: 36.0)!])
        // Set the color
        placeHolder.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.lightGray, range:NSRange(location:0,length: placeholdertext.count))
        field.attributedPlaceholder = placeHolder
        field.tintColor = .white
        field.font = UIFont(name: "Nunito-Light", size: 36.0)
        field.textAlignment = .center
        field.textColor = .white
        field.keyboardAppearance = .dark
        field.keyboardType = .numberPad
        
        field.addTarget(self, action: #selector(showButton(_:)), for: .editingChanged)
        return field
    }()
    
    let submitButton: UIButton = {
        var button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white
        button.layer.cornerRadius = 5
        button.isHidden = true
        button.addTarget(self, action: #selector(segueToNext(_:)), for: .touchUpInside)
        button.setTitle("Continue", for: .normal)
        button.titleLabel?.font = UIFont(name: "Nunito-Regular", size: 16.0)
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    let promptLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Verification Code"
        label.font = UIFont(name: "Nunito-Regular", size: 22.0)
        label.textAlignment = .center
        label.textColor = .white
        label.numberOfLines = 2
        return label
    }()
    
    
    var currentUser: User!
    
    @objc func showButton(_ sender: UITextField){
        
        sender.text = sender.text?.trimmingCharacters(in: .whitespaces)
        
        guard let text = sender.text, !text.isEmpty
            else {
                self.submitButton.isHidden = true
                return
        }
        submitButton.isHidden = false
    }
    
    @objc func segueToNext(_ sender: UIButton) {
        
        view.isUserInteractionEnabled = false
        //Retrieve saved verification ID and attempt to create login credentials.

        let verificationID = UserDefaults.standard.string(forKey: "authVerificationID") ?? ""
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: codeField.text!)

        //Use credentials to attempt to sign in.

        Auth.auth().signIn(with: credential) {
            user, error in
            //When response received, stop spinner and re-enable user input
            //If response is an error, display error message.
            if let error = error {
                print("Verification Error: \(error)")
                return
            } else {
                let uid = Auth.auth().currentUser!.uid
                DataService.instance.doesUserExist(uid: uid) {(exists) in
                    if exists {
                        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
                        let mainViewController = storyBoard.instantiateViewController(withIdentifier: "MainView")
                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                        appDelegate.window?.rootViewController = mainViewController
                    } else {
                        self.performSegue(withIdentifier: "usernameSegue", sender: self)
                    }
                }
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(displayP3Red: 42.0/255.0, green: 42.0/255.0, blue: 42.0/255.0, alpha: 1)
        UIApplication.shared.statusBarStyle = .lightContent
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.view.addSubview(codeField)
        self.view.addSubview(submitButton)
        self.view.addSubview(promptLabel)
        
        let constraints = [
            codeField.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            codeField.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -self.view.bounds.height / 4),
            codeField.widthAnchor.constraint(equalToConstant: 200.0),
            codeField.heightAnchor.constraint(equalToConstant: 50.0),
            submitButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            submitButton.heightAnchor.constraint(equalToConstant: 50.0),
            submitButton.widthAnchor.constraint(equalToConstant: 250.0),
            submitButton.topAnchor.constraint(equalTo: codeField.bottomAnchor, constant: 20.0),
            promptLabel.widthAnchor.constraint(equalToConstant: 350.0),
            promptLabel.heightAnchor.constraint(equalToConstant: 80.0),
            promptLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            promptLabel.bottomAnchor.constraint(equalTo: codeField.topAnchor)
            
        ]
        NSLayoutConstraint.activate(constraints)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        codeField.underlined()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

