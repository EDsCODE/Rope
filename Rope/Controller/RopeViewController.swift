//
//  RopeViewController.swift
//  Rope
//
//  Created by Eric Duong on 11/6/17.
//  Copyright © 2017 Rope. All rights reserved.
//

import UIKit
import Firebase

class RopeViewController: UIViewController {

    @IBOutlet weak var ropeCollectionView: UICollectionView!
    @IBOutlet weak var headerView: UIView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ropeCollectionView.delegate = self
        ropeCollectionView.dataSource = self
        
        
        //setup flow layout for collectionview
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: self.view.frame.width/2.1, height: self.view.frame.width/2.1)
        layout.minimumInteritemSpacing = 3
        layout.minimumLineSpacing = 6
        ropeCollectionView.collectionViewLayout = layout
        
        setupRopeObserver()
        
        // Do any additional setup after loading the view.
    }
    
    func setupRopeObserver() {
        DataService.instance.usersRef.child((Auth.auth().currentUser?.uid)!).child("ropes").observe(.value) { (snapshot) in
            print(snapshot.childrenCount)
        }
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

extension RopeViewController: UICollectionViewDelegate {
}

extension RopeViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "rope", for: indexPath)
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }
    
}

