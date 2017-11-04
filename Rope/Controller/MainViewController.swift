//
//  MainViewController.swift
//  Rope
//
//  Created by Eric Duong on 10/26/17.
//  Copyright © 2017 Rope. All rights reserved.
//

import UIKit
import Tabman
import Pageboy

class MainViewController: TabmanViewController, PageboyViewControllerDataSource {
    
    var viewControllers = [UIViewController]()

    override func viewDidLoad() {
        // change selected bar color
        super.viewDidLoad()
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        viewControllers.append(storyboard.instantiateViewController(withIdentifier: "Rope"))
        viewControllers.append(storyboard.instantiateViewController(withIdentifier: "Camera"))
        viewControllers.append(storyboard.instantiateViewController(withIdentifier: "Braiding"))
        self.dataSource = self

        // configure the bar
        self.bar.items = [Item(title: "Rope"), Item(title: "Knot"), Item(title: "Braiding")]
        self.bar.style = .buttonBar
        self.bar.appearance = TabmanBar.Appearance({ (appearance) in
            
            // customise appearance here
            appearance.indicator.color = .brown
        })
        
    }
    
    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        
        return viewControllers.count
    }
    
    func viewController(for pageboyViewController: PageboyViewController,
                        at index: PageboyViewController.PageIndex) -> UIViewController? {
        return viewControllers[index]
    }
    
    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        return .at(index: 1)
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
