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
import SkyFloatingLabelTextField

class NewRopeViewController: UIViewController {

    var createButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white
        button.layer.cornerRadius = 5
        button.titleLabel?.textAlignment = .center
        button.setTitle("Create", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.setTitleColor(.white, for: .highlighted)
        button.titleLabel?.font = UIFont(name: "Nunito-Regular", size: 16.0)
        button.isHidden = true
        return button
    }()
    
    var titleView: SkyFloatingLabelTextField = {
        var field = SkyFloatingLabelTextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.placeholder = "Rope Title"
        field.placeholderFont = UIFont(name: "Nunito-Light", size: 36.0)
        field.font = UIFont(name: "Nunito-Light", size: 36.0)
        field.tintColor = .white
        field.lineColor = .gray
        field.selectedTitleColor = .lightGray
        field.selectedLineColor = .white
        field.keyboardAppearance = .dark
        field.textColor = .white
        field.textAlignment = .center
        field.title = ""
        field.addTarget(self, action: #selector(showButton(_:)), for: .editingChanged)
        return field
    }()
    
    var friends = Dictionary<String,User>()
    var friendNames = [String]()
    var participants = [User]()
    var keyboardIsActive = false
    var createButtonBottomConstraint: NSLayoutConstraint!
    var cancelButtonBottomConstraint: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(displayP3Red: 42.0/255.0, green: 42.0/255.0, blue: 42.0/255.0, alpha: 1)
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        
        view.addSubview(titleView)
        view.addSubview(createButton)
        
        let constraints = [
            createButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            createButton.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.5),
            createButton.heightAnchor.constraint(equalToConstant: 40),
            titleView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 50.0),
            titleView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -50.0),
            titleView.heightAnchor.constraint(equalToConstant: 70.0),
            titleView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -30.0)
        ]
        
        //decalare bottom button constraints separately so they can be bound to keyboard
        createButtonBottomConstraint = NSLayoutConstraint(item: createButton, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1.0, constant: -10)
        createButtonBottomConstraint?.isActive = true
        
        NSLayoutConstraint.activate(constraints)
        setupCreateButton()
        setupKeyboardObserver()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        keyboardIsActive = false
        NotificationCenter.default.removeObserver(self)
    }
    
    func setupCreateButton() {
        let createGesture = UITapGestureRecognizer(target: self, action: #selector(createRopeAction(gesture:)))
        createButton.addGestureRecognizer(createGesture)
    }
    
    @objc func createRopeAction(gesture: UITapGestureRecognizer) {
        
        titleView.text = titleView.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let text = titleView.text, !text.isEmpty
            else {
                let alert = UIAlertController(title: "Invalid Title", message: "The Rope Title cannot be empty", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
                self.createButton.isHidden = true
                return
        }
        
        DataService.instance.createRope(title: text)
        dismiss(animated: false, completion: nil)
        
        
    }
    
    @objc func showButton(_ sender: SkyFloatingLabelTextField){
        
        guard let text = sender.text, !text.isEmpty
            else {
                self.createButton.isHidden = true
                return
        }
        createButton.isHidden = false
    }
    
    @IBAction func cancelCreation(_ sender: Any) {
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
                self.createButtonBottomConstraint.constant = -(keyboardSize?.height)! - 10
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
                self.createButtonBottomConstraint.constant = -10
                self.view.layoutIfNeeded()
                self.keyboardIsActive = false
            })
        }
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
