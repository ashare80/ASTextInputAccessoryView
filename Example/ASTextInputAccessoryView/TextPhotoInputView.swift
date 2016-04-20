//
//  TextPhotoInputView.swift
//  ASTextViewController
//
//  Created by Adam J Share on 4/13/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import Photos
import ASTextInputAccessoryView

class TextPhotoInputView: ASTextInputAccessoryView {
    
    var photoView: PhotoComponent!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addPhotosView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addPhotosView()
    }
    
    func addPhotosView() {
        photoView = UINib
            .init(nibName: "PhotoComponent", bundle: nil)
            .instantiateWithOwner(self, options: nil)
            .first as! PhotoComponent
        photoView.collectionView.delegate = self
        contentView.addSubview(photoView)
        photoView.autoLayoutToSuperview()
        photoView.hidden = true
        photoView.closeButton.addTarget(self, action: #selector(self.togglePhotoView(_:)), forControlEvents: .TouchUpInside)
    }

    override var contentHeight: CGFloat {
        
        if !photoView.hidden {
            return 200
        }
        
        return super.contentHeight
    }

    
    func togglePhotoView(sender: UIButton? = nil) {
        self.show = !self.show
    }
    
    var show: Bool {
        set {
            photoView.hidden = !newValue
            messageView.hidden = newValue
            
            if newValue {
                PHPhotoLibrary.requestAuthorization { (status) in
                    NSOperationQueue.mainQueue().addOperationWithBlock({
                        self.photoView.getPhotoLibrary()
                        self.reloadHeight()
                    })
                }
            }
            reloadHeight()
        }
        get {
            return !photoView.hidden
        }
    }
    
    override func updateBarHeight(animated: Bool, options: ASAnimationOptions, animateableChange: () -> Void, completion: (Bool) -> Void) {
        super.updateBarHeight(animated, options: options, animateableChange: { [weak self] in
            animateableChange()
            self?.photoView.collectionView.reloadData()
            }, completion: completion)
    }
}

extension TextPhotoInputView: UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if photoView.selectButton.selected {
            return
        }
        let asset = photoView.assets![indexPath.item]
        let options = PHImageRequestOptions()
        options.synchronous = true
        options.deliveryMode = .HighQualityFormat
        let m = PHImageManager.defaultManager()
        m.requestImageForAsset(
            asset as! PHAsset,
            targetSize: UIScreen.mainScreen().bounds.size,
            contentMode: .Default,
            options: options
        ) { [weak self] (image, info) in
            guard let image = image else {
                return
            }
            self?.textView.insertImages([image])
            self?.show = false
        }
    }
}


extension TextPhotoInputView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return photoView.cellSize
    }
}
