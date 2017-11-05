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
        self.tabBar.barTintColor = .black
        self.tabBar.tintColor = .white
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if item.tag == 1000 {
            self.tabBar.barTintColor = .black
            self.tabBar.tintColor = .white
        } else if item.tag == 2000 {
            self.tabBar.barTintColor = .white
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
