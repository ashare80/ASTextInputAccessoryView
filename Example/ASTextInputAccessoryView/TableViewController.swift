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
    
    var textInputAccessoryView: ASTextInputAccessoryView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textInputAccessoryView = ASTextInputAccessoryView(minimumHeight: 44)
        
        // Add a target to the standard send button or optionally set your own custom button
        textInputAccessoryView.defaultSendButton.addTarget(
            self,
            action: #selector(self.sendMessage),
            forControlEvents: .TouchUpInside
        )
        
        // Add a left button such as a camera icon
        addCameraButton()
        
        addKeyboardNotifications()
    }
    
    deinit {
        removeKeyboardNotifications()
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
        
        textInputAccessoryView.leftButton = cameraButton
        
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
        if let text = textInputAccessoryView.textView.text {
            messages.append(text)
        }
        textInputAccessoryView.textView.text = nil
        
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
        textInputAccessoryView.minimumHeight = 60
        textInputAccessoryView.margin = 3
        textInputAccessoryView.font = UIFont.boldSystemFontOfSize(30)
    }
}

//MARK: Input Accessory View
extension ASTableViewController {
    override var inputAccessoryView: UIView? {
        return textInputAccessoryView
    }
    
    // IMPORTANT Allows input view to stay visible
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    // Handle Rotation
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        textInputAccessoryView.refreshBarHeight()
    }
}


//MARK: Keyboard notifications
extension ASTableViewController {
    
    override func keyboardWillShow(keyboardFrame: CGRect, animated: Bool) {
        
        // In case of weird results from interactive dismiss
        if keyboardFrame.origin.y + textInputAccessoryView.frame.size.height < view.frame.size.height {
            var contentInset = tableView.contentInset
            contentInset.bottom = keyboardFrame.height
            tableView.scrollToBottomContent(contentInset, animated: !animated)
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

