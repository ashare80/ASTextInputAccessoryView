//
//  ASAnimationOptions.swift
//  Pods
//
//  Created by Adam J Share on 4/11/16.
//
//

import Foundation

public struct ASAnimationOptions {
    
    public var duration: NSTimeInterval = 0.2
    public var delay: NSTimeInterval = 0.0
    public var damping: CGFloat = 0.8
    public var velocity: CGFloat = 0.8
    public var options: UIViewAnimationOptions = .BeginFromCurrentState
    
    public init() { }
}