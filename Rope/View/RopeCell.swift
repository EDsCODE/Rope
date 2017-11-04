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

    @IBOutlet weak var bubbleView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var knotLabel: UILabel!


}

extension UIView {
    func roundCorners(corners:UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
}

//import UIKit
//
//class RopeCell: UITableViewCell {
//
//    var myLabel1: UILabel!
//    var myLabel2: UILabel!
//    var myButton1 : UIButton!
//    var myButton2 : UIButton!
//
//    required init(coder aDecoder: NSCoder) {
//        fatalError("init(coder:)")
//    }
//
//    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
//        super.init(style: style, reuseIdentifier: reuseIdentifier)
//
//        let gap : CGFloat = 10
//        let labelHeight: CGFloat = 30
//        let labelWidth: CGFloat = 150
//        let lineGap : CGFloat = 5
//        let label2Y : CGFloat = gap + labelHeight + lineGap
//        let imageSize : CGFloat = 30
//
//        myLabel1 = UILabel()
//        myLabel1.frame = CGRect(x: gap, y: gap, width: labelWidth, height: labelHeight)
//        myLabel1.textColor = UIColor.black
//        contentView.addSubview(myLabel1)
//
//        myLabel2 = UILabel()
//        myLabel2.frame = CGRect(x: gap, y: label2Y, width: labelWidth, height: labelHeight)
//        myLabel2.textColor = UIColor.black
//        contentView.addSubview(myLabel2)
//
//        myButton1 = UIButton()
//        myButton1.frame = CGRect(x: bounds.width-imageSize - gap, y: gap, width: imageSize, height: imageSize)
//        myButton1.setImage(UIImage(named: "browser.png"), for: UIControlState.normal)
//        contentView.addSubview(myButton1)
//
//        myButton2 = UIButton()
//        myButton2.frame = CGRect(x: bounds.width-imageSize - gap, y: label2Y, width: imageSize, height: imageSize)
//        myButton2.setImage(UIImage(named: "telephone.png"), for: UIControlState.normal)
//        contentView.addSubview(myButton2)
//    }
//
//}

