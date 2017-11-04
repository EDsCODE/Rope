//
//  ViewController.swift
//  Rope
//
//  Created by Eric Duong on 10/25/17.
//  Copyright © 2017 Rope. All rights reserved.
//

import UIKit
import Firebase
import PhoneNumberKit


class PhoneNumberViewController: UIViewController {
    
    let numberField: PhoneNumberTextField = {
        let field = PhoneNumberTextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.placeholder = "(000) 000-0000"
        field.textAlignment = .center
        field.addTarget(self, action: #selector(showButton(_:)), for: .editingChanged)
        return field
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
    
    let promptLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "To verify you're identity, we're going to use your phone number"
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
    
    @objc func showButton(_ sender: PhoneNumberTextField){
        
        sender.text = sender.text?.trimmingCharacters(in: .whitespaces)
        
        guard let text = sender.text, !text.isEmpty
            else {
                self.submitButton.isHidden = true
                return
        }
        submitButton.isHidden = false
    }
    
    @objc func segueToNext(_ sender: UIButton) {
        self.performSegue(withIdentifier: "verificationSegue", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.view.addSubview(numberField)
        self.view.addSubview(submitButton)
        self.view.addSubview(promptLabel)
        
        let constraints = [
            numberField.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            numberField.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -self.view.bounds.height / 4),
            numberField.widthAnchor.constraint(equalToConstant: 200.0),
            numberField.heightAnchor.constraint(equalToConstant: 50.0),
            submitButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            submitButton.heightAnchor.constraint(equalToConstant: 50.0),
            submitButton.widthAnchor.constraint(equalToConstant: 150.0),
            submitButton.topAnchor.constraint(equalTo: numberField.bottomAnchor, constant: 20.0),
            promptLabel.widthAnchor.constraint(equalToConstant: 350.0),
            promptLabel.heightAnchor.constraint(equalToConstant: 80.0),
            promptLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            promptLabel.bottomAnchor.constraint(equalTo: numberField.topAnchor)
            
        ]
        NSLayoutConstraint.activate(constraints)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}


