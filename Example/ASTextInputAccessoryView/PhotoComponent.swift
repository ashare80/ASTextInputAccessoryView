//
//  PhotoComponent.swift
//  ASTextViewController
//
//  Created by Adam J Share on 4/13/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit

import Photos
import ASTextInputAccessoryView

class PhotoComponent: UIView {

    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var selectButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBAction func selectButton(sender: UIButton) {
        
        sender.selected = !sender.selected
    }
    
    var assets: PHFetchResult?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        collectionView.registerClass(ImageCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.layer.shadowOffset = CGSize(width: 0, height: 2)
        collectionView.layer.shadowColor = UIColor.blackColor().CGColor
        collectionView.layer.shadowOpacity = 0.2
        collectionView.layer.shadowRadius = 2
    }
}

extension PhotoComponent: ASResizeableContentView {
    
    var contentHeight: CGFloat {
        return 200
    }
    
    var textInputView: UITextInputTraits? {
        return searchBar
    }
    
    func animatedLayout(newheight: CGFloat) {
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.reloadData()
    }
    
    func postAnimationLayout(newheight: CGFloat) {
        collectionView.collectionViewLayout.invalidateLayout()
    }
}

extension PhotoComponent {
    
    @IBAction func close(sender: AnyObject) {
        parentView?.selectedComponent = parentView?.components.first
    }
}


// MARK: Photo library
extension PhotoComponent {
    
    func getPhotoLibrary() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        self.assets = PHAsset.fetchAssetsWithMediaType(.Image, options: fetchOptions)
        self.collectionView.reloadData()
    }
}


extension PhotoComponent: UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        guard let assets = assets else {
            return 0
        }
        
        return assets.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! ImageCell
        
        cell.asset = assets?[indexPath.item] as? PHAsset
        
        return cell
    }
}


class ImageCell: UICollectionViewCell {
    
    var requestID: PHImageRequestID = 0
    var asset: PHAsset? {
        didSet {
            imageView.image = nil
            if let asset = asset {
                let manager = PHImageManager.defaultManager()
                
                cancelRequest()
                
                requestID = manager.requestImageForAsset(
                    asset,
                    targetSize: frame.size,
                    contentMode: .Default,
                    options: nil
                ) { [weak self] (image, info) in
                    guard let id = info?[PHImageResultRequestIDKey] as? NSNumber
                        where PHImageRequestID(id.integerValue) == self?.requestID ||
                            self?.requestID == 0  else {
                        return
                    }
                    self?.imageView.image = image
                }
            }
        }
    }
    func cancelRequest() {
        if requestID != 0 {
            PHImageManager.defaultManager().cancelImageRequest(requestID)
            requestID = 0
        }
    }
    
    let imageView: UIImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupViews()
    }
    
    func setupViews() {
        contentView.addSubview(imageView)
        imageView.autoLayoutToSuperview()
        imageView.contentMode = .ScaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor.whiteColor()
    }
}


extension PhotoComponent: UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if selectButton.selected {
            return
        }
        let asset = assets![indexPath.item]
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
            if let view = self?.parentView?.components.first as? ASTextInputAccessoryView {
                view.textView.insertImages([image])
                self?.close(self!.closeButton)
            }
        }
    }
}


extension PhotoComponent: UICollectionViewDelegateFlowLayout {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        collectionView.collectionViewLayout.invalidateLayout()
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.size.height, height: collectionView.frame.size.height)
    }
}