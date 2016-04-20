//
//  ASComponent.swift
//  Pods
//
//  Created by Adam J Share on 4/14/16.
//
//

import Foundation


public protocol ASComponent {
    
    var contentHeight: CGFloat { get }
    var textInputView: UITextInputTraits? { get }
    func animatedLayout(newheight: CGFloat)
    func postAnimationLayout(newheight: CGFloat)
}

extension ASComponent where Self: UIView {
    
    public var parentView: ASResizeableInputAccessoryView? {
        return superview?.superview as? ASResizeableInputAccessoryView
    }
    
    public var textInputView: UITextInputTraits? {
        return nil
    }
}