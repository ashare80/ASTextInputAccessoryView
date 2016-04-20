//
//  Dictionary.swift
//  ASTextInputAccessoryView
//
//  Created by Adam J Share on 4/19/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation

extension Dictionary where Key : NSDate, Value: _ArrayType, Value.Generator.Element: Message {
    
    var sortedKeys: [Key] {
        return keys.sort({ $0.timeIntervalSince1970 < $1.timeIntervalSince1970})
    }
    
    func itemForIndexPath(indexPath: NSIndexPath) -> Message {
        return self[sortedKeys[indexPath.section]]![indexPath.item]
    }
    
    func arrayForIndex(section: Int) -> [Message] {
        return self[sortedKeys[section]] as! [Message]
    }
}