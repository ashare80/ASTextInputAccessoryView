//
//  CGFloat.swift
//  Pods
//
//  Created by Adam J Share on 4/10/16.
//
//

import Foundation

// MARK: + Rounding

public extension CGFloat {
    
    var roundToNearestHalf: CGFloat {
        return round(self * 2)/2
    }
}