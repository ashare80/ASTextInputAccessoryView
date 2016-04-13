//
//  ASAnimationOptions.swift
//  Pods
//
//  Created by Adam J Share on 4/11/16.
//
//

import Foundation

public struct ASAnimationOptions {
    
    public var duration: NSTimeInterval = 0.25
    public var delay: NSTimeInterval = 0.0
    public var damping: CGFloat = 0.8
    public var velocity: CGFloat = 0.0
    public var options: UIViewAnimationOptions = [.BeginFromCurrentState]
    
    public init() { }
}


public extension ASAnimationOptions {
    
    func animate(animations: () -> Void, completion: ((Bool) -> Void)?) {
        
        UIView.animateWithDuration(
            duration,
            delay: delay,
            usingSpringWithDamping: damping,
            initialSpringVelocity: velocity,
            options: options,
            animations: animations,
            completion: completion
        )
    }
}