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
    @IBOutlet weak var cancelButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(displayP3Red: 42.0/255.0, green: 42.0/255.0, blue: 42.0/255.0, alpha: 1)
        
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
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: false, completion: nil)
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
