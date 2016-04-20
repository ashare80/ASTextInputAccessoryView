//
//  ASTextInputViewController.swift
//  ASTextInputAccessoryView
//
//  Created by Adam J Share on 4/19/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import ASTextInputAccessoryView

class ASTextInputViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var iaView: ASResizeableInputAccessoryView!
    let messageView = ASTextInputAccessoryView(frame: CGRect(x: 0, y: 0, width: 320, height: 44))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        iaView = ASResizeableInputAccessoryView(components: [messageView])
        iaView.delegate = self
        
        //        Experimental feature
        //        iaView.interactiveEngage(collectionView)
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
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        iaView.reloadHeight()
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
    
}