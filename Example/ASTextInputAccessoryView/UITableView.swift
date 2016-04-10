//
//  UITableView.swift
//  Pods
//
//  Created by Adam J Share on 4/9/16.
//
//

import Foundation
import UIKit

public extension UITableView {
    
    func scrollToLastCell(atScrollPosition: UITableViewScrollPosition = .None, animated: Bool = true) {
        
        guard let lastIndexPath = lastIndexPath else {
                return
        }
        
        scrollToRowAtIndexPath(lastIndexPath, atScrollPosition: atScrollPosition, animated: animated)
    }
    
    
    public var lastIndexPath: NSIndexPath? {
        
        guard
            let numberOfSections = dataSource?.numberOfSectionsInTableView?(self),
            let numberOfRows = dataSource?.tableView(self, numberOfRowsInSection: numberOfSections - 1)
            where numberOfRows > 0 else {
                return nil
        }
        
        return NSIndexPath(forRow: numberOfRows - 1, inSection: numberOfSections - 1)
    }
}


