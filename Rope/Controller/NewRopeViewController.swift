//
//  NewRopeViewController.swift
//  Rope
//
//  Created by Eric Duong on 11/5/17.
//  Copyright © 2017 Rope. All rights reserved.
//

import UIKit
import KSTokenView

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
    
    let names: Array<String> = ["hello", "Goodbye"]
    var keyboardIsActive = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tokenView = KSTokenView(frame: CGRect(x: 15, y: UIApplication.shared.statusBarFrame.height + 50, width: self.view.bounds.width, height: 40.0))
        tokenView.delegate = self
        tokenView.promptText = "With: "
        tokenView.placeholder = "Type to search for friends"
        tokenView.descriptionText = "Languages"
        tokenView.style = .squared
        
        let titleView = UITextField(frame: CGRect(x: 0, y: UIApplication.shared.statusBarFrame.height, width: self.view.bounds.width, height: 50.0))
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
            createButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            cancelButton.widthAnchor.constraint(equalTo: self.view.widthAnchor, multiplier: 0.5),
            cancelButton.heightAnchor.constraint(equalToConstant: 40),
            cancelButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            cancelButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
        setupKeyboardObserver()
        setupCancelButton()
        // Do any additional setup after loading the view.
    }
    
    func setupCancelButton() {
        let cancelGesture = UITapGestureRecognizer(target: self, action: #selector(cancelRopeSetup(gesture:)))
        cancelButton.addGestureRecognizer(cancelGesture)
    }
    
    @objc func cancelRopeSetup(gesture: UITapGestureRecognizer){
        dismiss(animated: false, completion: nil)
    }
    
    func setupKeyboardObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    ///Called when keyboard will be shown.
    @objc func handleKeyboardWillShow(notification: NSNotification) {
        
        let keyboardAnimationDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! Double
        let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
        if !keyboardIsActive {
            UIView.animate(withDuration: keyboardAnimationDuration, animations: {
                self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height - (keyboardSize?.height)!)
                self.view.layoutIfNeeded()
                self.keyboardIsActive = true
            })
        }
        
    }
    
    ///Called when keyboard will be hidden.
    @objc func handleKeyboardWillHide(notification: NSNotification) {
        let keyboardAnimationDuration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as! Double
        let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue
        
        if keyboardIsActive {
            UIView.animate(withDuration: keyboardAnimationDuration, animations: {
                self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height + (keyboardSize?.height)!)
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

extension NewRopeViewController: KSTokenViewDelegate {
    func tokenView(_ tokenView: KSTokenView, performSearchWithString string: String, completion: ((_ results: Array<AnyObject>) -> Void)?) {
        if (string.characters.isEmpty){
            completion!(names as Array<AnyObject>)
            return
        }
        
        var data: Array<String> = []
        for value: String in names {
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
