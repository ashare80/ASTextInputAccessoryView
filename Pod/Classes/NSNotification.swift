//
//  UINotification.swift
//  Pods
//
//  Created by Adam J Share on 4/12/16.
//
//

import Foundation

// MARK: + Keyboard
public extension NSNotification {
    
    public var keyboardFrameBegin: CGRect {
        return frameValueForKey(UIKeyboardFrameBeginUserInfoKey)
    }
    
    public var keyboardFrameEnd: CGRect {
        return frameValueForKey(UIKeyboardFrameEndUserInfoKey)
    }
    
    private func frameValueForKey(key: String) -> CGRect {
        guard
            let userInfo = userInfo,
            let keyboardSize = (userInfo[key] as? NSValue)?.CGRectValue(),
            let window = UIApplication.sharedApplication().keyWindow
            else {
                return CGRectZero
        }
        
        return window.convertRect(keyboardSize, toView:nil)
    }
    
    public var keyboardAnimationDuration: NSTimeInterval {
        
        guard
            let userInfo = userInfo,
            let time = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSTimeInterval)
            else {
                return 0
        }
        
        return time
    }
    
    public var keyboardAnimationCurve: UIViewAnimationOptions {
        guard
            let userInfo = userInfo,
            let rawValue = userInfo[UIKeyboardAnimationCurveUserInfoKey]?.integerValue
            else {
                return []
        }
        
        return [(UIViewAnimationOptions(rawValue: UInt(rawValue << 16))), .BeginFromCurrentState]
    }
}