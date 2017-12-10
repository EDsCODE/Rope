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
        var placeHolder = NSMutableAttributedString()
        let placeholdertext  = "(000) 000-0000"
        
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
        button.setTitle("Send Verification Code", for: .normal)
        button.titleLabel?.font = UIFont(name: "Nunito-Regular", size: 16.0)
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    let promptLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Mobile Number"
        label.font = UIFont(name: "Nunito-Regular", size: 22.0)
        label.textAlignment = .center
        label.textColor = .white
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
        view.isUserInteractionEnabled = false
        
        //Attempt to parse phone number.
        let phoneNumberKit = PhoneNumberKit()
        do {
            let phoneNumber = try phoneNumberKit.parse(numberField.text!)
            let parsedNumber = phoneNumberKit.format(phoneNumber, toType: .e164)

            //If parse successful, connect to firebase and attempt to verify.
            CurrentUser.phoneNumber = parsedNumber
            self.performSegue(withIdentifier: "verificationSegue", sender: nil)
            
            PhoneAuthProvider.provider().verifyPhoneNumber(parsedNumber, uiDelegate: nil) { (verificationID, error) in
                //When response received, stop spinner and re-enable user input
                self.view.isUserInteractionEnabled = true
                //If response received is an error, print the error.
                if let error = error {
                    print("error authentication: \(error)")
                    return
                }
                //Otherwise, send to verification page.
                UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
                self.view.isUserInteractionEnabled = true
            }
            //If phone number parsing fails, print error.
        } catch {
            self.view.isUserInteractionEnabled = true
            print("parsing phonenumber failed")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(displayP3Red: 42.0/255.0, green: 42.0/255.0, blue: 42.0/255.0, alpha: 1)
        UIApplication.shared.statusBarStyle = .lightContent
        
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.view.addSubview(numberField)
        self.view.addSubview(submitButton)
        self.view.addSubview(promptLabel)
        
        let constraints = [
            numberField.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            numberField.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -self.view.bounds.height / 4),
            numberField.widthAnchor.constraint(equalToConstant: 300.0),
            numberField.heightAnchor.constraint(equalToConstant: 50.0),
            submitButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            submitButton.heightAnchor.constraint(equalToConstant: 50.0),
            submitButton.widthAnchor.constraint(equalToConstant: 250.0),
            submitButton.topAnchor.constraint(equalTo: numberField.bottomAnchor, constant: 20.0),
            promptLabel.widthAnchor.constraint(equalToConstant: 350.0),
            promptLabel.heightAnchor.constraint(equalToConstant: 80.0),
            promptLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            promptLabel.bottomAnchor.constraint(equalTo: numberField.topAnchor)
            
        ]
        NSLayoutConstraint.activate(constraints)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        numberField.underlined()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

extension UITextField {
    func underlined(){
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor.lightGray.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width:  self.frame.size.width, height: self.frame.size.height)
        border.borderWidth = width
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
}


