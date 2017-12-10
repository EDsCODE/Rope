//
//  TabBarViewController.swift
//  Rope
//
//  Created by Eric Duong on 11/5/17.
//  Copyright © 2017 Rope. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let tabBarItems = self.tabBar.items as! [UITabBarItem]
        for item in tabBarItems {
            item.title = nil
            item.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        }
        self.tabBar.backgroundColor = UIColor(displayP3Red: 0.0, green: 0.0, blue: 0.0, alpha: 0.4)
        self.tabBar.barTintColor = .black
        self.tabBar.unselectedItemTintColor = .white
        self.tabBar.tintColor = .white
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if item.tag == 1000 {
            self.tabBar.backgroundColor = UIColor(displayP3Red: 0.0, green: 0.0, blue: 0.0, alpha: 0.4)
            self.tabBar.barTintColor = .black
            self.tabBar.unselectedItemTintColor = .white
            self.tabBar.tintColor = .white
        } else if item.tag == 2000 {
            self.tabBar.backgroundColor = .clear
            self.tabBar.barTintColor = .white
            self.tabBar.unselectedItemTintColor = .black
            self.tabBar.tintColor = .black
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
