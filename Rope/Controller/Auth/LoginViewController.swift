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


class LoginViewController: UIViewController {
    
    let loginButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Start Tying", for: .normal)
        button.titleLabel?.font = UIFont(name: "Nunito-Light", size: 16.0)
        button.titleLabel?.textColor = .white
        button.backgroundColor = UIColor(displayP3Red: 107.0/255.0, green: 107.0/255.0, blue: 107.0/255.0, alpha: 1)
        button.addTarget(self, action: #selector(loginSegue(_:)), for: [.touchUpInside,.touchDragExit])
        button.addTarget(self, action: #selector(touchDown(_:)), for: .touchDown)
        return button
    }()
    
    let ropeStrands: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "RopeStrands"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let ropeImage: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "LoginScreenRope"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let ropeTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Nunito-Light", size: 24.0)
        label.text = "ROPE"
        label.textColor = .white
        label.textAlignment = .center
        label.addCharacterSpacing()
        return label
    }()
    
    @objc func loginSegue(_ sender: UIButton){
        print("login pressed")
        loginButton.backgroundColor = UIColor(displayP3Red: 107.0/255.0, green: 107.0/255.0, blue: 107.0/255.0, alpha: 1)
        self.performSegue(withIdentifier: "phoneNumberSegue", sender: self)
    }
    
    @objc func touchDown(_ sender: UIButton) {
        loginButton.backgroundColor = .white
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNeedsStatusBarAppearanceUpdate()
        self.view.backgroundColor = UIColor(displayP3Red: 42.0/255.0, green: 42.0/255.0, blue: 42.0/255.0, alpha: 1)
        
        self.view.addSubview(ropeStrands)
        self.view.addSubview(loginButton)
        self.view.addSubview(ropeImage)
        self.view.addSubview(ropeTitle)
        
        let constraints = [
            ropeStrands.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            ropeStrands.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            ropeStrands.topAnchor.constraint(equalTo: self.view.topAnchor),
            ropeStrands.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            loginButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            loginButton.topAnchor.constraint(equalTo: ropeTitle.bottomAnchor, constant: 45.0),
            loginButton.widthAnchor.constraint(equalToConstant: 200.0),
            loginButton.heightAnchor.constraint(equalToConstant: 50.0),
            ropeImage.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            ropeImage.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -50.0),
            ropeImage.heightAnchor.constraint(equalToConstant: self.view.frame.height * 0.14),
            ropeImage.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            ropeTitle.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            ropeTitle.widthAnchor.constraint(equalTo: self.view.widthAnchor),
            ropeTitle.heightAnchor.constraint(equalToConstant: 100.0),
            ropeTitle.topAnchor.constraint(equalTo: ropeImage.bottomAnchor, constant: -40.0)
        ]
        NSLayoutConstraint.activate(constraints)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.loginButton.layer.cornerRadius = self.loginButton.frame.height / 2
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        UIApplication.shared.isStatusBarHidden = true
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        UIApplication.shared.isStatusBarHidden = false
        //set navigation bar items visible but keep bar clear
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationController?.navigationBar.barTintColor = .white
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
}

extension UILabel {
    func addCharacterSpacing() {
        if let labelText = text, labelText.count > 0 {
            let attributedString = NSMutableAttributedString(string: labelText)
            attributedString.addAttribute(NSAttributedStringKey.kern, value: 6.0, range: NSRange(location: 0, length: attributedString.length - 1))
            attributedText = attributedString
        }
    }
}

