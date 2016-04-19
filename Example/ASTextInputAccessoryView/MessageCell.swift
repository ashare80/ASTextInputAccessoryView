//
//  MessageCell.swift
//  ASTextInputAccessoryView
//
//  Created by Adam J Share on 4/17/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import ASTextInputAccessoryView

class MessageCell: UICollectionViewCell {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var bubbleView: UIView!
    
    class var minimumHeight: CGFloat { return 40 }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        bubbleView.layer.cornerRadius = MessageCell.minimumHeight/2
    }
}



