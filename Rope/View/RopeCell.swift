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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 10/UIFont.labelFontSize
        self.layer.cornerRadius = 5.0
    }
}
