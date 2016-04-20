//
//  User.swift
//  ASTextInputAccessoryView
//
//  Created by Adam J Share on 4/19/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import Foundation


class User: Equatable {
    var id: Int!
    var firstName: String?
    var lastName: String?
    
    init() {
        
    }
    
    init(id: Int) {
        self.id = id
    }
}

func ==(lhs: User, rhs: User) -> Bool {
    return lhs.id == rhs.id
}
