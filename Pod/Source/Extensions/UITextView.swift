//
//  UITextView.swift
//  Pods
//
//  Created by Adam J Share on 11/5/15.
//
//

import UIKit

// MARK: + Content control

public extension UITextView {
    
    func scrollToBottomText() {
        if (self.text.characters.count > 0) {
            let bottom = NSMakeRange(self.text.characters.count - 1, 1);
            self.scrollRangeToVisible(bottom)
        }
    }
    
    public var sizeThatFitsWidth: CGSize {
        return sizeThatFits(CGSizeMake(frame.size.width, CGFloat.max))
    }
    
    public var attributedTextHeight: CGFloat {
//        print(sizeThatFits(CGSizeMake(frame.size.width, CGFloat.max)))
        return attributedText.boundingRectWithSize(CGSizeMake(frame.size.width - textContainerInset.left - textContainerInset.right, CGFloat.max), options:[.UsesLineFragmentOrigin, .UsesFontLeading], context:nil).height
    }
    
    public var lineHeight: CGFloat {
        guard let font = font else {
            return 0
        }
        return "line".sizeWithFont(font, maxWidth:CGFloat.max, maxHeight:CGFloat.max).height
    }
    
    public var numberOfRows: Int {
        return Int(round(attributedTextHeight / lineHeight))
    }
}