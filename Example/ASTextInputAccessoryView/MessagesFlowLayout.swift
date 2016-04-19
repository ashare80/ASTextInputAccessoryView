//
//  MessagesFlowLayout.swift
//  ASTextInputAccessoryView
//
//  Created by Adam J Share on 4/19/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit

public enum MessagesCellAlignment {
    case Left, Right
}

public extension UICollectionViewLayoutAttributes {
    
    func rightAlignFrameOnWidth(width: CGFloat) {
        var frame = self.frame
        frame.origin.x = width - frame.size.width - 16
        self.frame = frame
    }
}


public extension UICollectionViewDelegateFlowLayout {
    
    func alignmentForItemAtIndexPath(indexPath: NSIndexPath) -> MessagesCellAlignment {
        return .Right
    }
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
        
        let isFirstItemInSection = indexPath.item == 0
        
        if isFirstItemInSection {
            currentItemAttributes?.rightAlignFrameOnWidth(collectionView!.frame.size.width)
            return currentItemAttributes
        }
        
        let previousIndexPath = NSIndexPath(forItem: indexPath.item-1, inSection: indexPath.section)
        let previousFrame = layoutAttributesForItemAtIndexPath(previousIndexPath)!.frame
        let currentFrame = currentItemAttributes!.frame
        let strecthedCurrentFrame = CGRect(x: 0,
                                           y: currentFrame.origin.y,
                                           width: collectionView!.frame.size.width,
                                           height: currentFrame.size.height
        )
        // if the current frame, once left aligned to the left and stretched to the full collection view
        // widht intersects the previous frame then they are on the same line
        let isFirstItemInRow = !CGRectIntersectsRect(previousFrame, strecthedCurrentFrame)
        
        if isFirstItemInRow {
            currentItemAttributes!.rightAlignFrameOnWidth(collectionView!.frame.size.width)
            return currentItemAttributes
        }
        
        let previousFrameLeftPoint = previousFrame.origin.x
        var frame = currentItemAttributes!.frame
        let minimumInteritemSpacing = evaluatedMinimumInteritemSpacingForItemAtIndex(indexPath.row)
        frame.origin.x = previousFrameLeftPoint - minimumInteritemSpacing - frame.size.width
        currentItemAttributes!.frame = frame
        return currentItemAttributes
    }
    
    func evaluatedMinimumInteritemSpacingForItemAtIndex(index: Int) -> CGFloat {
        let selector = #selector(UICollectionViewDelegateFlowLayout.collectionView(
            _:layout:minimumInteritemSpacingForSectionAtIndex:))
        if let delegate = collectionView?.delegate as? UICollectionViewDelegateFlowLayout where
            delegate.respondsToSelector(selector) == true {
            return delegate.collectionView!(collectionView!, layout:self, minimumInteritemSpacingForSectionAtIndex: index)
        }
        
        return self.minimumInteritemSpacing
    }
}
