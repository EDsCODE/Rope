//
//  RopeCell.swift
//  Rope
//
//  Created by Eric Duong on 11/1/17.
//  Copyright © 2017 Rope. All rights reserved.
//

import Foundation
import UIKit

class RopeIPCell: UITableViewCell {

    @IBOutlet weak var bubbleView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var senderLabel: UILabel!
    @IBOutlet weak var declineButton: UIButton!
    @IBOutlet weak var acceptButton: UIButton!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        bubbleView.layer.cornerRadius = 10.0
        bubbleView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        bubbleView.layer.shadowColor = UIColor.black.cgColor
        bubbleView.layer.shadowRadius = 4
        bubbleView.layer.shadowOpacity = 0.25
        bubbleView.layer.masksToBounds = false;
        bubbleView.clipsToBounds = false;
        bubbleView.backgroundColor = UIColor(displayP3Red: 180.0, green: 180.0, blue: 180.0, alpha: 0.2)
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        if (highlighted) {
            self.bubbleView.backgroundColor = .white
        } else {
            self.bubbleView.backgroundColor = UIColor(displayP3Red: 180.0, green: 180.0, blue: 180.0, alpha: 0.2)
        }
    }
    
}


