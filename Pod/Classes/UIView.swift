//
//  UIView.swift
//  Pods
//
//  Created by Adam J Share on 4/9/16.
//
//

import Foundation


public extension UIView {
    
    func autoLayoutToSuperview(attributes: [NSLayoutAttribute] = [.Left, .Right, .Top, .Bottom], inset: CGFloat = 0) -> [NSLayoutConstraint] {
        
        var constraints: [NSLayoutConstraint] = []
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
            constraints.append(constraint)
        }
        
        return constraints
    }
    
    func addHeightConstraint(constant: CGFloat, priority: UILayoutPriority = UILayoutPriorityDefaultHigh) -> NSLayoutConstraint {
        
        return addSizeConstraint(.Height, constant: constant, priority: priority)
    }
    
    func addWidthConstraint(constant: CGFloat, priority: UILayoutPriority = UILayoutPriorityDefaultHigh) -> NSLayoutConstraint {
        
        return addSizeConstraint(.Width, constant: constant, priority: priority)
    }
    
    private func addSizeConstraint(attribute: NSLayoutAttribute, constant: CGFloat, priority: UILayoutPriority = UILayoutPriorityDefaultHigh) -> NSLayoutConstraint {
        
        let constraint = NSLayoutConstraint(
            item: self,
            attribute: attribute,
            relatedBy: .Equal,
            toItem: nil,
            attribute: .NotAnAttribute,
            multiplier: 1,
            constant: constant
        )
        constraint.priority = priority
        superview?.addConstraint(constraint)
        return constraint
    }
}