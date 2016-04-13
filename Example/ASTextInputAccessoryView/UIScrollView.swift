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
    
    func scrollToBottomContent(animated: Bool = true) {
        let bottom = bottomOffset
        if !CGPointEqualToPoint(bottom, contentOffset) {
            setContentOffset(bottom, animated: animated)
        }
    }
    
    var bottomOffset: CGPoint {
        let contentHeight = contentSize.height
        
        var offset = contentOffset
        
        let bottom = contentInset.bottom
        let top = contentInset.top
        let availableHeight = frame.size.height - bottom
        let newOffsetY = contentHeight - availableHeight
        
        if newOffsetY >= -top {
            offset.y = newOffsetY
        } else {
            offset.y = -top
        }
        
        return offset
    }
    
    var isScrolledToBottom: Bool {
        return CGPointEqualToPoint(bottomOffset, contentOffset)
    }
}