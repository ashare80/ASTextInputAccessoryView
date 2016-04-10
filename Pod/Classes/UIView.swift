//
//  UIView.swift
//  Pods
//
//  Created by Adam J Share on 4/9/16.
//
//

import Foundation


public extension UIView {
    
    func autoLayoutToSuperview(attributes: [NSLayoutAttribute] = [.Left, .Right, .Top, .Bottom], inset: CGFloat = 0) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        for attribute in attributes {
            
            var constant = inset
            switch attribute {
            case .Right:
                constant = -inset
            case .Bottom:
                constant = -inset
            default:
                break
            }
            
            let constraint = NSLayoutConstraint(
                item: self,
                attribute: attribute,
                relatedBy: .Equal,
                toItem: self.superview,
                attribute: attribute,
                multiplier: 1,
                constant: constant
            )
            self.superview?.addConstraint(constraint)
        }
    }
    
}