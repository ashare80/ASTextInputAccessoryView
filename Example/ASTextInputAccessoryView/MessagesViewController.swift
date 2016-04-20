//
//  MessagesViewController.swift
//  ASTextInputAccessoryView
//
//  Created by Adam J Share on 4/17/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import ASTextInputAccessoryView


extension Dictionary where Key : NSDate, Value: _ArrayType, Value.Generator.Element: Message {
    
    var sortedKeys: [Key] {
        return keys.sort({ $0.timeIntervalSince1970 < $1.timeIntervalSince1970})
    }
    
    
    func itemForIndexPath(indexPath: NSIndexPath) -> Message {
        return self[sortedKeys[indexPath.section]]![indexPath.item]
    }
    
    func arrayForIndex(section: Int) -> [Message] {
        return self[sortedKeys[section]] as! [Message]
    }
}

class MessagesViewController: UIViewController {
    
    let thisUser = User(id: 1)
    let otherUser = User(id: 2)
    
    @IBOutlet weak var collectionView: UICollectionView!

    var messages: [NSDate: [Message]] = [:]
    
    var iaView: ASResizeableInputAccessoryView!
    let messageView = ASTextInputAccessoryView(frame: CGRect(x: 0, y: 0, width: 320, height: 44))
    
    let sizingLabel: UILabel = UILabel()
    var messageInsideMargin: CGFloat = 16
    var messageOppositeMargin: CGFloat = 60
    var font: UIFont = UIFont.systemFontOfSize(16)
    var textInsets: UIEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
    var screenSize = UIScreen.mainScreen().bounds.size
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.registerNib(UINib(nibName: "RightCell", bundle: nil), forCellWithReuseIdentifier: "RightCell")
        collectionView.registerNib(UINib(nibName: "LeftCell", bundle: nil), forCellWithReuseIdentifier: "LeftCell")
        collectionView.registerNib(UINib(nibName: "DateHeader", bundle: nil), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "DateHeader")
        
        collectionView.keyboardDismissMode = .Interactive
        collectionView.collectionViewLayout = MessagesFlowLayout()
        
        
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
        
        addSomeMessages()
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
        
        let previousSections = numberOfSectionsInCollectionView(collectionView)
        
        if let text = messageView.textView.text {
            addNewMessage(Message(text: text, user: thisUser))
        }
        
        messageView.textView.text = nil
        
        if let last = collectionView.lastIndexPath {
            
            collectionView.performBatchUpdates({
                if last.section == previousSections {
                    self.collectionView.insertSections(NSIndexSet(index: last.section))
                }
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
        return messages.keys.count
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.arrayForIndex(section).count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let message = messages.itemForIndexPath(indexPath)
        var cell: MessageCell!
        
        if message.user == thisUser {
            cell = collectionView.dequeueReusableCellWithReuseIdentifier("RightCell", forIndexPath: indexPath) as! MessageCell
        }
        else {
            cell = collectionView.dequeueReusableCellWithReuseIdentifier("LeftCell", forIndexPath: indexPath) as! MessageCell
        }
        
        cell.label.text = message.text
        cell.label.font = font
        
        return cell
    }
    
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionElementKindSectionHeader {
            let view = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: "DateHeader", forIndexPath: indexPath) as! MessageGroupDateReusableView
            view.label.text = messages.sortedKeys[indexPath.section].headerFormattedString
            return view
        }
        
        return UICollectionReusableView()
    }
}


extension MessagesViewController: UICollectionViewDelegate {
    
    
}

extension MessagesViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        return CGSize(width: screenSize.width, height: 30)
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        if size.width < view.frame.size.width {
            collectionView.collectionViewLayout.invalidateLayout()
        }
        screenSize = size
        coordinator.animateAlongsideTransition({ (context) in
            self.collectionView.reloadData()
            }) { (context) in
                self.collectionView.collectionViewLayout.invalidateLayout()
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        let text = messages.itemForIndexPath(indexPath).text
        
        let cellWidth = screenSize.width - messageInsideMargin - messageOppositeMargin
        let maxTextWidth = cellWidth - textInsets.left - textInsets.right
        
        sizingLabel.text = text
        sizingLabel.font = font
        sizingLabel.numberOfLines = 0
        
        let size = sizingLabel.sizeThatFits(CGSize(width: maxTextWidth, height: CGFloat.max))
        
        var cellSize = CGSize(width: cellWidth, height: size.height)
        
        cellSize.height += textInsets.top + textInsets.bottom
        
        if cellSize.height < MessageCell.minimumHeight {
            cellSize.height = MessageCell.minimumHeight
        }
        
        return cellSize
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        
        if section+1 == numberOfSectionsInCollectionView(collectionView) {
            return UIEdgeInsetsMake(0, 0, 8, 0)
        }
        
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 4
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
}

extension MessagesViewController: LayoutAlignment {
    
    func insetsForIndexPath(indexPath: NSIndexPath) -> UIEdgeInsets {
        
        let message = messages.itemForIndexPath(indexPath)
        
        if message.user == thisUser {
            return UIEdgeInsets(top: 4, left: messageOppositeMargin, bottom: 4, right: messageInsideMargin)
        }
        
        return UIEdgeInsets(top: 4, left: messageInsideMargin, bottom: 4, right: messageOppositeMargin)
    }
}


// MARK: Actions
extension MessagesViewController {
    
    @IBAction func dismissKeyboard(sender: AnyObject) {
        self.messageView.textView.resignFirstResponder()
    }
    
}


extension MessagesViewController {
    
    func addNewMessage(message: Message) {
        for key in messages.keys {
            let interval = message.date.timeIntervalSinceDate(key)
            if interval >= 0 && interval < 60 * 60  {
                messages[key]!.append(message)
                return
            }
        }
        
        messages[message.date] = [message]
    }
    
    func addSomeMessages() {
        let texts = [
            "This is a UIViewController that contains a UICollectionView with a contentInset that is managed in the controller from callbacks by the inputAccessoryView's delegate.",
            "If you use a UITableViewController, you will need to override 'viewWillAppear:' without calling 'super.viewWillAppear()' to remove the automatic keyboard contentInset adjustments made by the controller in order to manage contentInset from the delegate. Or you can add a UITableView to a UIViewController instead."
        ]
        
        var multiplier: NSTimeInterval = 60
        for text in texts {
            let message = Message(text: text, user: otherUser)
            message.date = NSDate().dateByAddingTimeInterval(-60*60*multiplier)
            addNewMessage(message)
            multiplier = multiplier/2
        }
    }
}

