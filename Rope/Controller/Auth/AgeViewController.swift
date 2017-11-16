//
//  FirstNameViewController.swift
//  Rope
//
//  Created by Eric Duong on 10/25/17.
//  Copyright © 2017 Rope. All rights reserved.
//

import UIKit
import Firebase

class AgeViewController: UIViewController {
    
    let promptLabel: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.text = "Please enter your age"
        label.textAlignment = .center
        return label
    }()
    
    let textField: UITextField = {
        var textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.addTarget(self, action: #selector(showButton(_:)), for: .editingChanged)
        textField.placeholder = "00"
        textField.keyboardType = .numberPad
        return textField
    }()
    
    let submitButton: UIButton = {
        var button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .black
        button.layer.cornerRadius = 10
        button.isHidden = true
        button.addTarget(self, action: #selector(segueToNext(_:)), for: .touchUpInside)
        return button
    }()
    
    
    @objc func showButton(_ sender: UITextField){
        
        sender.text = sender.text?.trimmingCharacters(in: .whitespaces)
        
        guard let text = sender.text, !text.isEmpty
            else {
                self.submitButton.isHidden = true
                return
        }
        submitButton.isHidden = false
    }

    @objc func segueToNext(_ sender: UIButton){
        CurrentUser.age = textField.text!
        
        //make instance in firebase database
        if let user = Auth.auth().currentUser?.uid {
            DataService.instance.saveUser(uid: user)
        }
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let mainViewController = storyBoard.instantiateViewController(withIdentifier: "MainView")
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = mainViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.view.addSubview(promptLabel)
        self.view.addSubview(textField)
        self.view.addSubview(submitButton)
        
        let contraints = [
            promptLabel.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -self.view.bounds.height / 3),
            promptLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            promptLabel.widthAnchor.constraint(equalToConstant: 250.0),
            promptLabel.heightAnchor.constraint(equalToConstant: 40.0),
            textField.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            textField.heightAnchor.constraint(equalToConstant: 70.0),
            textField.widthAnchor.constraint(equalToConstant: 250.0),
            textField.topAnchor.constraint(equalTo: promptLabel.bottomAnchor),
            submitButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            submitButton.heightAnchor.constraint(equalToConstant: 50.0),
            submitButton.widthAnchor.constraint(equalToConstant: 150.0),
            submitButton.topAnchor.constraint(equalTo: textField.bottomAnchor)
        ]
        NSLayoutConstraint.activate(contraints)
        
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


