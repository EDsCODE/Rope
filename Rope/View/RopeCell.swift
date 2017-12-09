//
//  RopeCell.swift
//  Rope
//
//  Created by Eric Duong on 11/6/17.
//  Copyright © 2017 Rope. All rights reserved.
//

import Foundation
import UIKit

class RopeCell: UICollectionViewCell {
    
    @IBOutlet weak var ropeImage: UIImageView!
    @IBOutlet weak var overlayView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    var rope: Rope!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.layoutIfNeeded()
        for layer in overlayView.layer.sublayers! {
            if(layer.name == "gradient"){
                layer.removeFromSuperlayer()
            }
        }
        
        let gradient : CAGradientLayer = CAGradientLayer()
        gradient.frame = overlayView.bounds
        gradient.name = "gradient"
        gradient.colors = [UIColor.clear.cgColor, UIColor(displayP3Red: 0.0, green: 0.0, blue: 0.0, alpha: 0.7).cgColor]
        gradient.startPoint = CGPoint(x: 1, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        overlayView.layer.insertSublayer(gradient, at: 0)
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 10/UIFont.labelFontSize
        self.layer.cornerRadius = 5.0
    }
}
