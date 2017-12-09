//
//  FirstNameViewController.swift
//  Rope
//
//  Created by Eric Duong on 10/25/17.
//  Copyright © 2017 Rope. All rights reserved.
//

import UIKit
import Firebase
import SkyFloatingLabelTextField

class SignUpViewController: UIViewController {
    
    let firstnameField: SkyFloatingLabelTextField = {
        var field = SkyFloatingLabelTextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.placeholder = "First Name"
        field.placeholderFont = UIFont(name: "Nunito-Light", size: 18.0)
        field.font = UIFont(name: "Nunito-Light", size: 18.0)
        field.tintColor = .white
        field.lineColor = .gray
        field.selectedTitleColor = .lightGray
        field.selectedLineColor = .white
        field.keyboardAppearance = .dark
        field.textColor = .white
        field.title = "First Name"
        field.addTarget(self, action: #selector(showButton(_:)), for: .editingChanged)
        return field
    }()
    
    let lastnameField: SkyFloatingLabelTextField = {
        var field = SkyFloatingLabelTextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.placeholder = "Last Name"
        field.placeholderFont = UIFont(name: "Nunito-Light", size: 18.0)
        field.font = UIFont(name: "Nunito-Light", size: 18.0)
        field.tintColor = .white
        field.lineColor = .gray
        field.selectedTitleColor = .lightGray
        field.selectedLineColor = .white
        field.keyboardAppearance = .dark
        field.textColor = .white
        field.title = "Last Name"
        field.addTarget(self, action: #selector(showButton(_:)), for: .editingChanged)
        return field
    }()
    
    let usernameField: SkyFloatingLabelTextField = {
        var field = SkyFloatingLabelTextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.placeholder = "Username"
        field.placeholderFont = UIFont(name: "Nunito-Light", size: 18.0)
        field.font = UIFont(name: "Nunito-Light", size: 18.0)
        field.tintColor = .white
        field.lineColor = .gray
        field.selectedTitleColor = .lightGray
        field.selectedLineColor = .white
        field.textColor = .white
        field.keyboardAppearance = .dark
        field.title = "Username"
        field.addTarget(self, action: #selector(showButton(_:)), for: .editingChanged)
        return field
    }()
    
    let ageField: SkyFloatingLabelTextField = {
        var field = SkyFloatingLabelTextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.placeholder = "Age"
        field.placeholderFont = UIFont(name: "Nunito-Light", size: 18.0)
        field.font = UIFont(name: "Nunito-Light", size: 18.0)
        field.tintColor = .white
        field.lineColor = .gray
        field.selectedTitleColor = .lightGray
        field.selectedLineColor = .white
        field.textColor = .white
        field.keyboardType = .numberPad
        field.keyboardAppearance = .dark
        field.title = "Age"
        field.addTarget(self, action: #selector(showButton(_:)), for: .editingChanged)
        return field
    }()
    
    
    let submitButton: UIButton = {
        var button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white
        button.layer.cornerRadius = 10
        button.isHidden = true
        button.setTitle("Submit", for: .normal)
        button.titleLabel?.font = UIFont(name: "Nunito-Regular", size: 16.0)
        button.addTarget(self, action: #selector(segueToNext(_:)), for: .touchUpInside)
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    var currentUser: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Sign Up"
        self.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedStringKey.font: UIFont(name: "Nunito-Light", size: 22.0)!, NSAttributedStringKey.foregroundColor: UIColor.white]
        self.view.backgroundColor = UIColor(displayP3Red: 42.0/255.0, green: 42.0/255.0, blue: 42.0/255.0, alpha: 1)
        UIApplication.shared.statusBarStyle = .lightContent
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

        self.view.addSubview(firstnameField)
        self.view.addSubview(lastnameField)
        self.view.addSubview(usernameField)
        self.view.addSubview(ageField)
        self.view.addSubview(submitButton)
        
        
        let contraints = [
            firstnameField.topAnchor.constraint(equalTo: self.topLayoutGuide.bottomAnchor),
            firstnameField.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15.0),
            firstnameField.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -15.0),
            firstnameField.heightAnchor.constraint(equalToConstant: 50.0),
            lastnameField.topAnchor.constraint(equalTo: self.firstnameField.bottomAnchor, constant: 10.0),
            lastnameField.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15.0),
            lastnameField.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -15.0),
            lastnameField.heightAnchor.constraint(equalToConstant: 50.0),
            usernameField.topAnchor.constraint(equalTo: self.lastnameField.bottomAnchor, constant: 10.0),
            usernameField.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15.0),
            usernameField.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -15.0),
            usernameField.heightAnchor.constraint(equalToConstant: 50.0),
            ageField.topAnchor.constraint(equalTo: self.usernameField.bottomAnchor, constant: 10.0),
            ageField.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 15.0),
            ageField.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.1),
            ageField.heightAnchor.constraint(equalToConstant: 50.0),
            submitButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            submitButton.heightAnchor.constraint(equalToConstant: 50.0),
            submitButton.widthAnchor.constraint(equalToConstant: 250.0),
            submitButton.topAnchor.constraint(equalTo: ageField.bottomAnchor, constant: 10.0),
        ]
        NSLayoutConstraint.activate(contraints)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func showButton(_ sender: SkyFloatingLabelTextField){

        firstnameField.text = firstnameField.text?.trimmingCharacters(in: .whitespaces)
        lastnameField.text = lastnameField.text?.trimmingCharacters(in: .whitespaces)
        usernameField.text = usernameField.text?.trimmingCharacters(in: .whitespaces)
        ageField.text = ageField.text?.trimmingCharacters(in: .whitespaces)
        
        if !firstnameField.text!.isEmpty,!lastnameField.text!.isEmpty, !usernameField.text!.isEmpty, !ageField.text!.isEmpty {
            submitButton.isHidden = false
        } else {
            self.submitButton.isHidden = true
        }
    }
    
    @objc func segueToNext(_ sender: UIButton){
        CurrentUser.firstname = firstnameField.text!
        CurrentUser.lastname = lastnameField.text!
        CurrentUser.username = usernameField.text!
        CurrentUser.age = ageField.text!
        //make instance in firebase database
        if let user = Auth.auth().currentUser?.uid {
            DataService.instance.saveUser(uid: user)
        }
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let mainViewController = storyBoard.instantiateViewController(withIdentifier: "MainView")
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = mainViewController
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

