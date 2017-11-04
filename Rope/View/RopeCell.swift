//
//  RopeCell.swift
//  Rope
//
//  Created by Eric Duong on 11/1/17.
//  Copyright © 2017 Rope. All rights reserved.
//

import Foundation
import UIKit

class RopeCell: UITableViewCell {
    @IBOutlet weak var ropeImage: UIImageView!
    @IBOutlet weak var infoView: UIView!
    
    override func layoutSubviews() {
        self.ropeImage.layer.cornerRadius = 8.0
        self.ropeImage.contentMode = .scaleAspectFit
        self.ropeImage.layer.masksToBounds = true
        //infoView.roundCorners(corners: [.bottomLeft, .bottomRight], radius: 8.0)
    }
    
}

extension UIView {
    func roundCorners(corners:UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
}
