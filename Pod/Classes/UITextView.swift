//
//  UITextView.swift
//  Pods
//
//  Created by Adam J Share on 11/5/15.
//
//

import UIKit

public extension UITextView {
    
    func scrollToBottomText() {
        if (self.text.characters.count > 0) {
            let bottom = NSMakeRange(self.text.characters.count - 1, 1);
            self.scrollRangeToVisible(bottom)
        }
    }
    
    public var textContentHeight: CGFloat {
        return contentSize.height - textContainerInset.top - textContainerInset.bottom
    }
    
    public var lineHeight: CGFloat {
        guard let font = font else {
            return 0
        }
        return "line".sizeWithFont(font, maxWidth:CGFloat.max, maxHeight:CGFloat.max).height
    }
    
    public var numberOfRows: Int {
        return Int(textContentHeight / lineHeight)
    }
}