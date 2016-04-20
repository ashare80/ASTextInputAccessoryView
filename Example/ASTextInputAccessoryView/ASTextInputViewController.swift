//
//  ASTextInputViewController.swift
//  ASTextInputAccessoryView
//
//  Created by Adam J Share on 4/19/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import Photos
import ASTextInputAccessoryView

class ASTextInputViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var iaView: ASResizeableInputAccessoryView!
    let messageView = ASTextInputAccessoryView(frame: CGRect(x: 0, y: 0, width: 320, height: 44))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let photoComponent = UINib
            .init(nibName: "PhotoComponent", bundle: nil)
            .instantiateWithOwner(self, options: nil)
            .first as! PhotoComponent
        iaView = ASResizeableInputAccessoryView(components: [messageView, photoComponent])
        iaView.delegate = self
        
        //        Experimental feature
        //        iaView.interactiveEngage(collectionView)
        
        updateInsets(iaView.contentViewHeightConstraint.constant)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        collectionView.reloadData()
        collectionView.scrollToBottomContent(false)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        //        Test layout of changed parameters after setup
        //        changeAppearance()
    }
    
    
    func changeAppearance() {
        messageView.minimumHeight = 60
        messageView.margin = 3
        messageView.font = UIFont.boldSystemFontOfSize(30)
    }
}

//MARK: Input Accessory View
extension ASTextInputViewController {
    override var inputAccessoryView: UIView? {
        return iaView
    }
    
    // IMPORTANT Allows input view to stay visible
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    // Handle Rotation
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        
        coordinator.animateAlongsideTransition({ (context) in
            self.messageView.textView.layoutIfNeeded()
            }) { (context) in
                self.iaView.reloadHeight()
        }
    }
}


// MARK: ASResizeableInputAccessoryViewDelegate
extension ASTextInputViewController: ASResizeableInputAccessoryViewDelegate {
    
    func updateInsets(bottom: CGFloat) {
        var contentInset = collectionView.contentInset
        contentInset.bottom = bottom
        collectionView.contentInset = contentInset
        collectionView.scrollIndicatorInsets = contentInset
    }
    
    func inputAccessoryViewWillAnimateToHeight(view: ASResizeableInputAccessoryView, height: CGFloat, keyboardHeight: CGFloat) -> (() -> Void)? {
        
        return { [weak self] in
            self?.updateInsets(keyboardHeight)
            self?.collectionView.scrollToBottomContent(false)
        }
    }
    
    func inputAccessoryViewKeyboardWillPresent(view: ASResizeableInputAccessoryView, height: CGFloat) -> (() -> Void)? {
        return { [weak self] in
            self?.updateInsets(height)
            self?.collectionView.scrollToBottomContent(false)
        }
    }
    
    func inputAccessoryViewKeyboardWillDismiss(view: ASResizeableInputAccessoryView, notification: NSNotification) -> (() -> Void)? {
        return { [weak self] in
            self?.updateInsets(view.frame.size.height)
        }
    }
    
    func inputAccessoryViewKeyboardDidChangeHeight(view: ASResizeableInputAccessoryView, height: CGFloat) {
        let shouldScroll = collectionView.isScrolledToBottom
        updateInsets(height)
        if shouldScroll {
            self.collectionView.scrollToBottomContent(false)
        }
    }
}



// MARK: Actions
extension ASTextInputViewController {
    
    @IBAction func dismissKeyboard(sender: AnyObject) {
        self.messageView.textView.resignFirstResponder()
    }
    
    func addCameraButton() {
        
        let cameraButton = UIButton(type: .Custom)
        let image = UIImage(named: "camera")?.imageWithRenderingMode(.AlwaysTemplate)
        cameraButton.setImage(image, forState: .Normal)
        cameraButton.tintColor = UIColor.grayColor()
        
        messageView.leftButton = cameraButton
        
        let width = NSLayoutConstraint(
            item: cameraButton,
            attribute: .Width,
            relatedBy: .Equal,
            toItem: nil,
            attribute: .NotAnAttribute,
            multiplier: 1,
            constant: 40
        )
        cameraButton.superview?.addConstraint(width)
        
        cameraButton.addTarget(self, action: #selector(self.showPictures), forControlEvents: .TouchUpInside)
    }
    
    func showPictures() {
        
        PHPhotoLibrary.requestAuthorization { (status) in
            NSOperationQueue.mainQueue().addOperationWithBlock({
                if let photoComponent = self.iaView.components[1] as? PhotoComponent {
                    self.iaView.selectedComponent = photoComponent
                    photoComponent.getPhotoLibrary()
                }
            })
        }
    }
}