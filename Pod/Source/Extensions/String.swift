//
//  NSString.swift
//  Pods
//
//  Created by Adam J Share on 12/29/15.
//
//

import Foundation
import UIKit

// MARK: + Size

public extension String {
    
    func sizeWithFont(font: UIFont, maxWidth: CGFloat = CGFloat.max, maxHeight: CGFloat = CGFloat.max) -> CGSize {
        let constraint = CGSize(width: maxWidth, height: maxHeight)
        
        let frame = self.boundingRectWithSize(
            constraint,
            options:[.UsesLineFragmentOrigin , .UsesFontLeading],
            attributes:[NSFontAttributeName: font],
            context:nil
        )
        
        return CGSizeMake(frame.size.width, frame.size.height);
    }
}