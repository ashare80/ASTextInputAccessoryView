//
//  ASResizeableInputAccessoryViewDelegate.swift
//  Pods
//
//  Created by Adam J Share on 4/12/16.
//
//

import Foundation

public protocol ASResizeableInputAccessoryViewDelegate: class {
    /**
     The maximum point in the window's Y axis that the InputAccessoryView origin should reach.
     
     - parameters:
     - view: Input accessory view.
     
     - default:
     ````
     UIApplication.sharedApplication().statusBarFrame.size.height + navigationController!.navigationBar.frame.size.height
     ````
     */
    func inputAccessoryViewMaximumBarY(view: UIView) -> CGFloat
    
    /**
     On reload, asks the delegate what the next height should be.
     
     - parameters:
     - view: Input accessory view.
     - nextHeight: Suggested content height based off the view's calculations.
     - currentHeight: CurrentHeight view height.
     
     - returns: Desired height. Defaults to nextHeight.
     */
    func inputAccessoryViewNextHeight(view: UIView, suggestedHeight: CGFloat, currentHeight: CGFloat) -> CGFloat
    
    
    /**
     Prior to animating height, asks the receiver for a possible animateable block of code.
     
     - parameters:
     - view: Input accessory view.
     - height: Height the view will animate to.
     - keyboardHeight: Full height of the keyboard frame, including input accessory view.
     
     - returns: A block of animateable changes.
     */
    func inputAccessoryViewWillAnimateToHeight(view: UIView, height: CGFloat, keyboardHeight: CGFloat) -> (() -> Void)?
    
    /**
     Informs the receiver of a height change completion.
     
     - parameters:
     - view: Input accessory view.
     - height: New height of the view.
     - keyboardHeight: Full height of the keyboard frame, including input accessory view.
     */
    func inputAccessoryViewDidAnimateToHeight(view: UIView, height: CGFloat, keyboardHeight: CGFloat)
    
    /**
     Keyboard will present from a dismissed state.
     
     - parameters:
     - view: Input accessory view.
     - notification: The received notification with keyboard related userInfo.
     - returns: A block of animateable changes to coincide with keyboard animation.
     */
    func inputAccessoryViewKeyboardWillPresent(view: UIView, notification: NSNotification) -> (() -> Void)?
    
    /**
     Keyboard will dismiss from a presented state.
     
     - parameters:
     - view: Input accessory view.
     - notification: The received notification with keyboard related userInfo.
     - returns: A block of animateable changes to coincide with keyboard animation.
     */
    func inputAccessoryViewKeyboardWillDismiss(view: UIView, notification: NSNotification) -> (() -> Void)?
}

public extension ASResizeableInputAccessoryViewDelegate {
    
    func inputAccessoryViewNextHeight(view: UIView, suggestedHeight: CGFloat, currentHeight: CGFloat) -> CGFloat { return suggestedHeight }
    func inputAccessoryViewWillAnimateToHeight(view: UIView, height: CGFloat, keyboardHeight: CGFloat) -> (() -> Void)? { return nil }
    func inputAccessoryViewDidAnimateToHeight(view: UIView, height: CGFloat, keyboardHeight: CGFloat) {}
    func inputAccessoryViewKeyboardWillPresent(view: UIView, notification: NSNotification) -> (() -> Void)? { return nil }
    func inputAccessoryViewKeyboardWillDismiss(view: UIView, notification: NSNotification) -> (() -> Void)? { return nil }
}

public extension ASResizeableInputAccessoryViewDelegate where Self: UIViewController {
    
    func inputAccessoryViewMaximumBarY(view: UIView) -> CGFloat { return topBarHeight }
}
