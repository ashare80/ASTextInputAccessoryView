//
//  NSObject.swift
//  Pods
//
//  Created by Adam J Share on 4/12/16.
//
//

import Foundation


public extension NSObject {
    
    func addKeyboardNotificationsAll() {
        addKeyboardNotificationsShow()
        addKeyboardNotificationsHide()
        addKeyboardNotificationsChangeFrame()
    }
    
    func addKeyboardNotificationsShow() {
        addNotificationSelectors([
            UIKeyboardWillShowNotification: #selector(self.keyboardWillShow(_:)),
            UIKeyboardDidShowNotification: #selector(self.keyboardDidShow(_:))
            ])
    }
    
    func addKeyboardNotificationsHide() {
        addNotificationSelectors([
            UIKeyboardWillHideNotification: #selector(self.keyboardWillHide(_:)),
            UIKeyboardDidHideNotification: #selector(self.keyboardDidHide(_:))
            ])
    }
    
    func addKeyboardNotificationsChangeFrame() {
        addNotificationSelectors([
            UIKeyboardWillChangeFrameNotification: #selector(self.keyboardWillChangeFrame(_:)),
            UIKeyboardDidChangeFrameNotification: #selector(self.keyboardDidChangeFrame(_:))
            ])
    }
    
    func addNotificationSelectors(keyedSelectors: [String: Selector]) {
        let nc = NSNotificationCenter.defaultCenter()
        for (name, selector) in keyedSelectors {
            nc.addObserver(self, selector: selector, name: name, object: nil)
        }
    }
    
    func removeKeyboardNotificationsAll() {
        removeKeyboardNotificationsHide()
        removeKeyboardNotificationsShow()
        removeKeyboardNotificationsChangeFrame()
    }
    
    func removeKeyboardNotificationsHide() {
        removeNotificationNames(
            [UIKeyboardWillHideNotification, UIKeyboardDidHideNotification]
        )
    }
    
    func removeKeyboardNotificationsShow() {
        removeNotificationNames(
            [UIKeyboardWillShowNotification, UIKeyboardDidShowNotification]
        )
    }
    
    func removeKeyboardNotificationsChangeFrame() {
        removeNotificationNames(
            [UIKeyboardWillChangeFrameNotification, UIKeyboardDidChangeFrameNotification]
        )
    }
    
    private func removeNotificationNames(names: [String]) {
        let nc = NSNotificationCenter.defaultCenter()
        for name in names {
            nc.removeObserver(self, name: name, object: nil )
        }
    }
    
    func keyboardWillShow(notification: NSNotification) { }
    func keyboardDidShow(notification: NSNotification) { }
    func keyboardWillHide(notification: NSNotification) { }
    func keyboardDidHide(notification: NSNotification) { }
    func keyboardWillChangeFrame(notification: NSNotification) { }
    func keyboardDidChangeFrame(notification: NSNotification) { }
}