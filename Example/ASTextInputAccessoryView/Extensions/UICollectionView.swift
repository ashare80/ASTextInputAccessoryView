//
//  UICollectionView.swift
//  ASTextInputAccessoryView
//
//  Created by Adam J Share on 4/18/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit


extension UICollectionView {
    
    public var lastIndexPath: NSIndexPath? {
        
        guard
            let numberOfSections = dataSource?.numberOfSectionsInCollectionView?(self),
            let numberOfItems = dataSource?.collectionView(self, numberOfItemsInSection: numberOfSections - 1)
            where numberOfItems > 0 else {
                return nil
        }
        
        return NSIndexPath(forItem: numberOfItems - 1, inSection: numberOfSections - 1)
    }
    
    func scrollToLastCell(atScrollPosition: UICollectionViewScrollPosition = .None, animated: Bool = true) {
        
        guard let lastIndexPath = lastIndexPath else {
            return
        }
        
        scrollToItemAtIndexPath(lastIndexPath, atScrollPosition: atScrollPosition, animated: animated)
    }
}