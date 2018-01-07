//
//  OnboardingViewController.swift
//  Rope
//
//  Created by Eric Duong on 1/2/18.
//  Copyright © 2018 Rope. All rights reserved.
//

import UIKit
import paper_onboarding

class OnboardingViewController: UIViewController, PaperOnboardingDataSource, PaperOnboardingDelegate {
    

    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var onboardingView: PaperOnboarding!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        UIApplication.shared.isStatusBarHidden = true
        onboardingView.dataSource = self
        onboardingView.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.isStatusBarHidden = false
    }
    
    
    func onboardingItemsCount() -> Int {
        return 5
    }
    
    func onboardingItemAtIndex(_ index: Int) -> OnboardingItemInfo {
        let backgroundColorOne = UIColor(displayP3Red: 42.0/255.0, green: 42.0/255.0, blue: 42.0/255.0, alpha: 1)
        let backgroundColorTwo = UIColor(displayP3Red: 42.0/255.0, green: 42.0/255.0, blue: 42.0/255.0, alpha: 1)
        let backgroundColorThree = UIColor(displayP3Red: 42.0/255.0, green: 42.0/255.0, blue: 42.0/255.0, alpha: 1)
        
        let titleFont = UIFont(name: "Nunito-Bold", size: 24)!
        let descirptionFont = UIFont(name: "Nunito-Regular", size: 18)!
        
        return [(#imageLiteral(resourceName: "addgray"), "Create", "Create a new Rope by giving it a title", UIImage(), backgroundColorOne, UIColor.white, UIColor.white, titleFont, descirptionFont),
                
                (#imageLiteral(resourceName: "addfriends"), "Add", "Add friends using a QR code", UIImage(), backgroundColorTwo, UIColor.white, UIColor.white, titleFont, descirptionFont),
                
                (#imageLiteral(resourceName: "tap"), "Capture", "Get assigned the front or back facing camera. Press and hold anywhere on the screen to create a knot", UIImage(), backgroundColorThree, UIColor.white, UIColor.white, titleFont, descirptionFont),
                
                (#imageLiteral(resourceName: "send (1)"), "Send", "Each user can add up to five knots to the rope", UIImage(), backgroundColorThree, UIColor.white, UIColor.white, titleFont, descirptionFont),
                
                (#imageLiteral(resourceName: "ropes"), "View", "View your Rope after four hours or all knots have been tied", UIImage(), backgroundColorThree, UIColor.white, UIColor.white, titleFont, descirptionFont)][index]
        
    }
    
    func onboardingConfigurationItem(_ item: OnboardingContentViewItem, index: Int) {
        
    }
    
    func onboardingWillTransitonToIndex(_ index: Int) {
        if index != 4 {
            UIView.animate(withDuration: 0.2, animations: {
                self.startButton.alpha = 0
            })
        }
    }
    
    func onboardingDidTransitonToIndex(_ index: Int) {
        if index == 4 {
            UIView.animate(withDuration: 0.4, animations: {
                self.startButton.alpha = 1
            })
        }
    }
    
    @IBAction func goToMainView(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating();
        
        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true) {
            let storyBoard = UIStoryboard(name: "Main", bundle: nil)
            let mainViewController = storyBoard.instantiateViewController(withIdentifier: "MainView")
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.window?.rootViewController = mainViewController
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
