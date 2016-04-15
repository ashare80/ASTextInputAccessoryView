//
//  ASResizeableContentView.swift
//  Pods
//
//  Created by Adam J Share on 4/14/16.
//
//

import Foundation


public protocol ASResizeableContentView {
    
    var contentHeight: CGFloat { get }
    func animatedLayout(newheight: CGFloat)
    func postAnimationLayout(newheight: CGFloat)
}

extension ASResizeableContentView where Self: UIView {
    
    var parentView: ASResizeableInputAccessoryView? {
        return superview?.superview as? ASResizeableInputAccessoryView
    }
}