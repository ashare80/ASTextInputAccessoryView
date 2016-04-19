//
//  MessagesViewController.swift
//  ASTextInputAccessoryView
//
//  Created by Adam J Share on 4/17/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import ASTextInputAccessoryView

class MessagesViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!

    var messages: [String] = []
    
    var font: UIFont = UIFont.systemFontOfSize(16)
    var textInsets: UIEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    
    var iaView: ASResizeableInputAccessoryView!
    let messageView = ASTextInputAccessoryView(frame: CGRect(x: 0, y: 0, width: 320, height: 44))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.registerNib(UINib(nibName: "RightCell", bundle: nil), forCellWithReuseIdentifier: "RightCell")
        collectionView.keyboardDismissMode = .Interactive
        collectionView.collectionViewLayout = MessagesFlowLayout()
        
        messages.append("This is a UIViewController that contains a UICollectionView with a contentInset that is managed in the controller from callbacks by the inputAccessoryView's delegate.")
        messages.append("If you use a UITableViewController, you will need to override 'viewWillAppear:' without calling 'super.viewWillAppear()' to remove the automatic keyboard contentInset adjustments made by the controller in order to manage contentInset from the delegate. Or you can add a UITableView to a UIViewController instead.")
        
        iaView = ASResizeableInputAccessoryView(components: [messageView])
        iaView.delegate = self
        
//        Experimental feature
//        iaView.interactiveEngage(collectionView)
        
        // Add a target to the standard send button or optionally set your own custom button
        messageView.defaultSendButton.addTarget(
            self,
            action: #selector(self.sendMessage),
            forControlEvents: .TouchUpInside
        )
        
        // Add a left button such as a camera icon
        addCameraButton()
        
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
    }
    
    func sendMessage() {
        if let text = messageView.textView.text {
            messages.append(text)
        }
        messageView.textView.text = nil
        
        if let last = collectionView.lastIndexPath {
            
            collectionView.performBatchUpdates({
                self.collectionView.insertItemsAtIndexPaths([last])
                }, completion: { (finished) in
                    self.collectionView.scrollToBottomContent()
            })
        }
    }
    
    func changeAppearance() {
        messageView.minimumHeight = 60
        messageView.margin = 3
        messageView.font = UIFont.boldSystemFontOfSize(30)
    }
}

//MARK: Input Accessory View
extension MessagesViewController {
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
extension MessagesViewController: ASResizeableInputAccessoryViewDelegate {
    
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



//MARK: DataSource
extension MessagesViewController: UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("RightCell", forIndexPath: indexPath) as! MessageCell
        cell.textView.text = messages[indexPath.item]
        cell.textView.textContainerInset = textInsets
        cell.textView.font = font
        
        return cell
    }
}


extension MessagesViewController: UICollectionViewDelegate {
    
    
}

extension MessagesViewController: UICollectionViewDelegateFlowLayout {
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
        coordinator.animateAlongsideTransition({ (context) in
            self.collectionView.collectionViewLayout.invalidateLayout()
            }) { (context) in
                self.collectionView.collectionViewLayout.invalidateLayout()
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let text = messages[indexPath.item]
        
        let maxTextWidth = view.frame.size.width - textInsets.left - textInsets.right - 60 - 16
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .ByWordWrapping
        let attributedString = NSAttributedString(string: text, attributes: [NSFontAttributeName: font, NSParagraphStyleAttributeName: paragraphStyle])
        let size = attributedString.boundingRectWithSize(CGSizeMake(maxTextWidth-1, CGFloat.max), options:[.UsesLineFragmentOrigin, .UsesFontLeading], context:nil)
        
        var cellSize = CGSize(width: collectionView.frame.width - 60 - 16, height: size.height)
        
        cellSize.height += textInsets.top + textInsets.bottom
        
        if cellSize.height < MessageCell.minimumHeight {
            cellSize.height = MessageCell.minimumHeight
        }
        
        return cellSize
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 4
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 60
    }
}


// MARK: Actions
extension MessagesViewController {
    
    @IBAction func dismissKeyboard(sender: AnyObject) {
        self.messageView.textView.resignFirstResponder()
    }
    
}


