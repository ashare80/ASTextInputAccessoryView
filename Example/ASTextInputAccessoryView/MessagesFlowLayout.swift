//
//  MessagesFlowLayout.swift
//  ASTextInputAccessoryView
//
//  Created by Adam J Share on 4/19/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit

public extension UICollectionViewLayoutAttributes {
    
    func alignFrameWithInset(inset: UIEdgeInsets) {
        var frame = self.frame
        frame.origin.x = inset.left
        self.frame = frame
    }
}

public protocol LayoutAlignment {
    func insetsForIndexPath(indexPath: NSIndexPath) -> UIEdgeInsets
}


class MessagesFlowLayout: UICollectionViewFlowLayout {
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let originalAttributes = super.layoutAttributesForElementsInRect(rect) else {
            return nil
        }
        
        var updatedAttributes = originalAttributes
        
        for attributes in originalAttributes {
            if attributes.representedElementKind != nil {
                continue
            }
            
            if let index = updatedAttributes.indexOf(attributes),
                let layout = layoutAttributesForItemAtIndexPath(attributes.indexPath) {
                updatedAttributes[index] = layout
            }
        }
        
        return updatedAttributes
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        
        let currentItemAttributes = super.layoutAttributesForItemAtIndexPath(indexPath)?.copy() as? UICollectionViewLayoutAttributes
        
        let sectionInset = evaluatedSectionInsetForItemAtIndexPath(indexPath)
        
        currentItemAttributes?.alignFrameWithInset(sectionInset)
        
        return currentItemAttributes
    }
    
    func evaluatedMinimumInteritemSpacingForItemAtIndex(index: Int) -> CGFloat {
        if let delegate = collectionView?.delegate as? UICollectionViewDelegateFlowLayout,
            let spacing = delegate.collectionView?(collectionView!, layout:self, minimumInteritemSpacingForSectionAtIndex: index) {
            return spacing
        }
        
        return self.minimumInteritemSpacing
    }
    
    func evaluatedSectionInsetForItemAtIndexPath(indexPath: NSIndexPath) -> UIEdgeInsets {
        
        if let inset = (collectionView?.delegate as? LayoutAlignment)?.insetsForIndexPath(indexPath) {
            return inset
        }
        
        return UIEdgeInsetsZero
    }
}
