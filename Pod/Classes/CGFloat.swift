//
//  CGFloat.swift
//  Pods
//
//  Created by Adam J Share on 4/10/16.
//
//

import Foundation

public extension CGFloat {
    
    var roundToHalf: CGFloat {
        let rounded = self % 5 == 0 ? self : self + 5 - (self % 5)
        return rounded
    }
}