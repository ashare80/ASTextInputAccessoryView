//
//  ViewController.swift
//  ASTextInputAccessoryView
//
//  Created by Adam Share on 04/10/2016.
//  Copyright (c) 2016 Adam Share. All rights reserved.
//

import UIKit
import ASTextInputAccessoryView

class ASTableViewController: UITableViewController {
    
    var messages: [String] = []
    
    var iaView: ASResizeableInputAccessoryView!
    let messageView = ASTextInputAccessoryView(frame: CGRect(x: 0, y: 0, width: 320, height: 44))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        iaView = ASResizeableInputAccessoryView(contentViews: [messageView])
        iaView.delegate = self
        
        // Add a target to the standard send button or optionally set your own custom button
        messageView.defaultSendButton.addTarget(
            self,
            action: #selector(self.sendMessage),
            forControlEvents: .TouchUpInside
        )
        
        // Add a left button such as a camera icon
        addCameraButton()
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
        
        if let last = tableView.lastIndexPath {
            
            CATransaction.begin()
            CATransaction.setCompletionBlock({
                self.tableView.scrollToLastCell()
            })
            tableView.insertRowsAtIndexPaths([last], withRowAnimation: .Right)
            CATransaction.commit()
        }
    }
    
    func changeAppearance() {
        messageView.minimumHeight = 60
        messageView.margin = 3
        messageView.font = UIFont.boldSystemFontOfSize(30)
    }
}

//MARK: Input Accessory View
extension ASTableViewController {
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
extension ASTableViewController: ASResizeableInputAccessoryViewDelegate {
    
    /** 
     - IMPORTANT: Remove auto content inset functionality by overriding viewWillAppear
     
     We are going to want to handle setting the keyboard inset ourselves for animation of the tableView to scroll along with changes to the inputAccessoryView height. Otherwise super.viewWillAppear(animated) will start internal changes to the tableView content that causes problems.
     */
    override func viewWillAppear(animated: Bool) { }
    
    func updateInsets(keyboardHeight: CGFloat) {
        var contentInset = tableView.contentInset
        contentInset.bottom = keyboardHeight
        tableView.contentInset = contentInset
        tableView.scrollIndicatorInsets = contentInset
    }
    
    func inputAccessoryViewWillAnimateToHeight(view: UIView, height: CGFloat, keyboardHeight: CGFloat) -> (() -> Void)? {
        
        return { [weak self] in
            self?.updateInsets(keyboardHeight)
            self?.tableView.scrollToBottomContent(false)
        }
    }
    
    func inputAccessoryViewKeyboardWillPresent(view: UIView, notification: NSNotification) -> (() -> Void)? {
        return { [weak self] in
            self?.updateInsets(notification.keyboardFrameEnd.height)
            self?.tableView.scrollToBottomContent(false)
        }
    }
    
    func inputAccessoryViewKeyboardWillDismiss(view: UIView, notification: NSNotification) -> (() -> Void)? {
        return { [weak self] in
            self?.updateInsets(view.frame.size.height)
        }
    }
    
    func inputAccessoryViewKeyboardDidChangeHeight(view: UIView, notification: NSNotification) {
        let shouldScroll = tableView.isScrolledToBottom
        
        updateInsets(notification.keyboardFrameEnd.height)
        if shouldScroll {
            self.tableView.scrollToBottomContent(false)
        }
    }
}



//MARK: DataSource
extension ASTableViewController {
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("MessageCell", forIndexPath: indexPath)
        cell.textLabel?.text = messages[indexPath.row]
        
        return cell
    }
}


// MARK: Actions
extension ASTableViewController {
    
    @IBAction func dismissKeyboard(sender: AnyObject) {
        messageView.textView.resignFirstResponder()
    }
    
}

