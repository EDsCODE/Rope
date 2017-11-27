//
//  RopeIPDetailViewController.swift
//  Rope
//
//  Created by Eric Duong on 11/26/17.
//  Copyright © 2017 Rope. All rights reserved.
//

import UIKit

class RopeIPDetailViewController: UIViewController {

    @IBOutlet weak var qrImageView: UIImageView!
    var ropeIP: RopeIP!
    @IBOutlet weak var ropeLogo: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ropeLogo.isHidden = true
        let image = generateQRCode(from: ropeIP.id!)
        qrImageView.image = image
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        
        return nil
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
