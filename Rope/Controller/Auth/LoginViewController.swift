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
        button.setTitle("Braid", for: .normal)
        button.titleLabel?.textColor = .white
        button.backgroundColor = .black
        button.addTarget(self, action: #selector(loginSegue(_:)), for: .touchUpInside)
        return button
    }()
    
    let ropeImage: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "plain_rope"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    let ropeTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont(name: "Helvetica Neue", size: 50.0)
        label.text = "Rope"
        label.textAlignment = .center
        return label
    }()
    
    @objc func loginSegue(_ sender: UIButton){
        print("login pressed")
        self.performSegue(withIdentifier: "phoneNumberSegue", sender: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(loginButton)
        self.view.addSubview(ropeImage)
        self.view.addSubview(ropeTitle)
        
        let constraints = [
            loginButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            loginButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            loginButton.widthAnchor.constraint(equalToConstant: 200.0),
            loginButton.heightAnchor.constraint(equalToConstant: 50.0),
            ropeImage.widthAnchor.constraint(equalToConstant: self.view.bounds.width * 2),
            ropeImage.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            ropeImage.heightAnchor.constraint(equalToConstant: 20.0),
            ropeImage.bottomAnchor.constraint(equalTo: loginButton.topAnchor, constant: -80.0),
            ropeTitle.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            ropeTitle.widthAnchor.constraint(equalTo: self.view.widthAnchor),
            ropeTitle.heightAnchor.constraint(equalToConstant: 100.0),
            ropeTitle.bottomAnchor.constraint(equalTo: ropeImage.topAnchor, constant: -40.0)
        ]
        NSLayoutConstraint.activate(constraints)
        // Do any additional setup after loading the view, typically from a nib.
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
        self.navigationController?.navigationBar.barTintColor = .white
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
}

