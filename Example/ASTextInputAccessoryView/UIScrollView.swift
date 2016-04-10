//
//  UIScrollView.swift
//  Pods
//
//  Created by Adam J Share on 4/9/16.
//
//

import Foundation
import UIKit

public extension UIScrollView {
    
    func scrollToBottomContent(inset: UIEdgeInsets = UIEdgeInsetsZero, animated: Bool = true) {
        let contentHeight = contentSize.height
        
        var offset = contentOffset
        
        let bottom = inset.bottom
        let top = inset.top
        
        let availableHeight = frame.size.height - bottom
        
        let newOffsetY = contentHeight - availableHeight
        
        if newOffsetY >= -top {
            offset.y = newOffsetY
            setContentOffset(offset, animated: animated)
        }
    }
}