//
//  UIViewController.swift
//  Pods
//
//  Created by Adam J Share on 11/2/15.
//
//

import Foundation
import UIKit

public extension UIViewController {
    
    public var topBarHeight: CGFloat {
        
        var topHeight = UIApplication.sharedApplication().statusBarFrame.size.height
        if let height = navigationController?.navigationBar.frame.size.height {
            topHeight += height
        }
        
        return topHeight
    }
}

//MARK: - Hierarchy

public extension UIViewController {
    
    var firstPresentedViewController: UIViewController? {
        
        var viewController = presentedViewController
        
        while viewController?.presentingViewController != self && viewController?.presentingViewController != navigationController {
            
            viewController = viewController?.presentingViewController
            
            if viewController == nil {
                return nil
            }
        }
        
        if let controller = (viewController as? UINavigationController)?.viewControllers.first {
            return controller
        }
        
        return viewController
    }
    
    var isFirstController: Bool {
        
        return navigationController?.viewControllers.first == self
    }
    
    var topLevelController: UIViewController {
        
        if presentedViewController == nil {
            return self
        }
        
        return presentedViewController!.topLevelController
    }
    
    var isRootViewController: Bool {
        return navigationController?.viewControllers.count <= 1;
    }
    
    class var topViewController: UIViewController {
        
        let rootViewController = UIApplication.sharedApplication().delegate!.window!!.rootViewController
        return topViewControllerWithRootViewController(rootViewController!)
    }
    
    class func topViewControllerWithRootViewController(rootViewController: UIViewController) -> UIViewController {
        // Handling UITabBarController
        
        if let rootViewController = rootViewController as? UITabBarController, let selected = rootViewController.selectedViewController {
            return topViewControllerWithRootViewController(selected)
        }
        else if let rootViewController = rootViewController as? UINavigationController, let visible = rootViewController.visibleViewController {
            return topViewControllerWithRootViewController(visible)
        }
        else if let presentedViewController = rootViewController.presentedViewController {
            return topViewControllerWithRootViewController(presentedViewController)
        }
        
        return rootViewController
    }
}


//MARK: Keyboard
public extension UIViewController {
    
    func addKeyboardNotifications() {
        addShowKeyboardNotifications()
        addHideKeyboardNotifications()
    }
    
    private func addShowKeyboardNotifications() {
        NSNotificationCenter.defaultCenter()
            .addObserver(
                self,
                selector: #selector(UIViewController._keyboardWillShow(_:)),
                name:      UIKeyboardWillShowNotification,
                object:    nil
        )
        NSNotificationCenter.defaultCenter()
            .addObserver(
                self,
                selector: #selector(UIViewController._keyboardDidShow(_:)),
                name: UIKeyboardDidShowNotification,
                object: nil
        )
    }
    
    private func addHideKeyboardNotifications() {
        NSNotificationCenter.defaultCenter()
            .addObserver(
                self,
                selector: #selector(UIViewController._keyboardDidHide(_:)),
                name: UIKeyboardDidHideNotification,
                object: nil
        )
        NSNotificationCenter.defaultCenter()
            .addObserver(
                self,
                selector: #selector(UIViewController._keyboardWillHide(_:)),
                name: UIKeyboardWillHideNotification,
                object: nil
        )
    }
    
    func removeKeyboardNotifications() {
        removeHideKeyboardNotifications()
        removeShowKeyboardNotifications()
    }
    
    private func removeHideKeyboardNotifications() {
        NSNotificationCenter.defaultCenter()
            .removeObserver(
                self,
                name: UIKeyboardWillHideNotification,
                object: nil
        )
        NSNotificationCenter.defaultCenter()
            .removeObserver(
                self,
                name: UIKeyboardDidHideNotification,
                object: nil
        )
    }
    
    private func removeShowKeyboardNotifications() {
        NSNotificationCenter.defaultCenter()
            .removeObserver(
                self,
                name: UIKeyboardWillShowNotification,
                object: nil
        )
        NSNotificationCenter.defaultCenter()
            .removeObserver(
                self,
                name: UIKeyboardDidShowNotification,
                object: nil
        )
    }
   
    func _keyboardWillShow(notification: NSNotification) {
        
        keyboardAnimation(notification) { (keyboardFrame, animated) in
            self.keyboardWillShow(keyboardFrame, animated:animated)
        }
    }
    
    func _keyboardDidShow(notification: NSNotification) {
        
        var keyboardFrame = CGRectZero
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue() {
            keyboardFrame = view.convertRect(keyboardSize, toView:nil)
        }
        
        keyboardDidShow(keyboardFrame)
    }
    
    func _keyboardWillHide(notification: NSNotification) {
        keyboardAnimation(notification) { (keyboardFrame, animated) in
            self.keyboardWillHideAnimation()
        }
    }
    
    func _keyboardDidHide(notification: NSNotification) {
        keyboardDidHide()
    }
    
    
    private func keyboardAnimation(notification: NSNotification, commit: (keyboardFrame: CGRect, animated: Bool) -> Void) {
        
        var keyboardFrame = CGRectZero
        
        guard let userInfo = notification.userInfo else {
            commit(keyboardFrame: keyboardFrame, animated: false)
            return
        }
        
        if let keyboardSize = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue() {
            keyboardFrame = view.convertRect(keyboardSize, toView:nil)
        }
        
        var animated = false
        var duration: NSTimeInterval = 0
        var options: UIViewAnimationOptions = .BeginFromCurrentState
        
        if let time = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSTimeInterval) {
            animated = time > 0
            duration = time
        }
        
        if let rawValue = userInfo[UIKeyboardAnimationCurveUserInfoKey]?.integerValue {
            options = [(UIViewAnimationOptions(rawValue: UInt(rawValue << 16))), .BeginFromCurrentState]
        }

        if !animated {
            commit(keyboardFrame: keyboardFrame, animated: animated)
            return
        }
        
        UIView.animateWithDuration(
            duration,
            delay: 0.0,
            options: options,
            animations: {
                commit(keyboardFrame: keyboardFrame, animated: animated)
            },
            completion: nil
        )
    }
    
    
    func keyboardWillShow(keyboardFrame: CGRect, animated: Bool) {
        //Subclass puts animations here
    }
    
    func keyboardWillHideAnimation() {
        //Subclass puts animations here
        
    }
    
    func keyboardDidShow(keyboardFrame: CGRect) {
        
    }
    
    func keyboardDidHide() {
        
    }
}