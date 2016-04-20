//
//  Message.swift
//  ASTextInputAccessoryView
//
//  Created by Adam J Share on 4/19/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation


class Message: Equatable {
    
    var text: String?
    var date: NSDate = NSDate()
    var user: User!
    
    init() {
        
    }
    
    init(text: String?, user: User) {
        self.user = user
        self.text = text
    }
}

func ==(lhs: Message, rhs: Message) -> Bool {
    return lhs.text == rhs.text && lhs.user == rhs.user && lhs.date == rhs.date
}