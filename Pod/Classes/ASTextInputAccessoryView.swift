//
//  ASTextInputAccessoryView.swift
//  Pods
//
//  Created by Adam J Share on 4/9/16.
//
//

import UIKit
import ASPlaceholderTextView


public class ASTextInputAccessoryView: ASResizeableInputAccessoryView {
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupMessageView()
        monitorTextViewContentSize()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupMessageView()
        monitorTextViewContentSize()
    }
    
    //MARK: Monitor textView contentSize updates
    
    private let contentSizeKey = "contentSize"
    
    deinit {
        textView.removeObserver(self, forKeyPath: contentSizeKey)
    }
    
    func monitorTextViewContentSize() {
        textView.addObserver(self, forKeyPath: contentSizeKey, options: .New, context: nil)
    }
    
    public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        if let object = object as? UITextView where object == textView, let keyPath = keyPath {
            switch keyPath {
            case contentSizeKey:
                reloadHeight()
            default:
                break
            }
        }
    }
    
    
    // MARK: Height changes
    
    public override var contentHeight: CGFloat {
        var nextBarHeight = minimumHeight
        
        if textView.text.characters.count == 0 {
            return nextBarHeight
        }
        
        let lineHeight = textView.lineHeight
        let rows = textView.numberOfRows
        let maxBarHeight = maxHeight
        
        nextBarHeight = (CGFloat(rows) * lineHeight) + (minimumHeight - lineHeight)
        
        if nextBarHeight > maxBarHeight {
            nextBarHeight = maxBarHeight
        }
        if nextBarHeight < minimumHeight {
            nextBarHeight = minimumHeight
        }
        
        return nextBarHeight
    }
    
    override func updateBarHeight(animated: Bool, options: ASAnimationOptions, animateableChange: () -> Void, completion: () -> Void) {
        
        super.updateBarHeight(
            animated,
            options: options,
            animateableChange:{
                animateableChange()
                self.textView.scrollToBottomText()
            },
            completion:{
                completion()
                self.textView.layoutIfNeeded()
            }
        )
    }
    
    // MARK: Message Views
    
    /**
     Container view for textView and buttonContainerViews.
     */
    public let messageView = UIView()
    
    /**
     Placeholder textView.
     
     - Note: For automatic resizing, update the font var on the accessory view.
     */
    public let textView = ASPlaceholderTextView(frame: CGRectZero, textContainer: nil)
    
    /**
     Container view for a custom button view autoresized to the left of the textView.
     */
    public let leftButtonContainerView = UIView()
    
    /**
     Container view for a custom button view autoresized to the right of the textView.
     */
    public let rightButtonContainerView = UIView()
    
    
    /**
     Space the textView and button views keep from surrounding views.
     */
    public var margin: CGFloat = 7 {
        didSet {
            updateContentConstraints()
            reloadHeight()
            resetTextContainerInset()
        }
    }
    
    
    /**
     Resets textContainerInset based off the text line height and margin.
     */
    public func resetTextContainerInset() {
        let inset = (contentViewHeight.constant - margin * 2 - textView.lineHeight)/2
        textView.textContainerInset = UIEdgeInsets(top: inset, left: 3, bottom: inset, right: 3)
    }
    
    func setupMessageView() {
        messageView.backgroundColor = UIColor.clearColor()
        leftButtonContainerView.backgroundColor = UIColor.clearColor()
        rightButtonContainerView.backgroundColor = UIColor.clearColor()
        
        contentView.addSubview(messageView)
        messageView.autoLayoutToSuperview()
        
        messageView.addSubview(leftButtonContainerView)
        messageView.addSubview(rightButtonContainerView)
        messageView.addSubview(textView)
        
        textView.allowImages = true
        textView.placeholder = "Text Message"
        textView.placeholderColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.7)
        textView.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        textView.layer.cornerRadius = 5.0
        textView.layer.borderColor = UIColor.lightGrayColor().CGColor
        textView.layer.borderWidth = 0.5
        textView.delegate = self
        
        resetTextContainerInset()
        
        updateContentConstraints()
        
        addStandardSendButton()
    }
    
    func updateContentConstraints() {
        
        messageView.removeConstraints(messageView.constraints)
        
        leftButtonContainerView.autoLayoutToSuperview([.Left, .Bottom], inset: margin)
        rightButtonContainerView.autoLayoutToSuperview([.Right, .Bottom], inset: margin)
        textView.autoLayoutToSuperview([.Top, .Bottom], inset: margin)
        
        let left = NSLayoutConstraint(
            item: textView,
            attribute: .Left,
            relatedBy: .Equal,
            toItem: leftButtonContainerView,
            attribute: .Right,
            multiplier: 1,
            constant: margin
        )
        let right = NSLayoutConstraint(
            item: textView,
            attribute: .Right,
            relatedBy: .Equal,
            toItem: rightButtonContainerView,
            attribute: .Left,
            multiplier: 1,
            constant: -margin
        )
        messageView.addConstraint(left)
        messageView.addConstraint(right)
        
        textView.setContentHuggingPriority(UILayoutPriorityDefaultLow, forAxis: .Horizontal)
        textView.setContentHuggingPriority(UILayoutPriorityDefaultLow, forAxis: .Vertical)
        textView.setContentCompressionResistancePriority(UILayoutPriorityDefaultLow, forAxis: .Horizontal)
        textView.setContentCompressionResistancePriority(UILayoutPriorityDefaultLow, forAxis: .Vertical)
        
        for view in [leftButtonContainerView, rightButtonContainerView] {
            
            view.addHeightConstraint(minimumHeight - margin * 2)
            view.addWidthConstraint(0, priority: UILayoutPriorityDefaultLow)
            view.setContentHuggingPriority(UILayoutPriorityRequired, forAxis: .Horizontal)
            view.setContentCompressionResistancePriority(UILayoutPriorityDefaultHigh, forAxis: .Horizontal)
        }
    }
    
    
    // MARK: Button Views
    
    /**
     Standard "Send" button set as the rightButton.
     */
    public let defaultSendButton: UIButton = UIButton(type: .Custom)
    
    /**
     Sets the standard "Send" button as the rightButton.
     */
    public func addStandardSendButton() {
        
        defaultSendButton.setTitle("Send", forState: .Normal)
        defaultSendButton.setTitleColor(tintColor, forState: .Normal)
        defaultSendButton.setTitleColor(tintColor.colorWithAlphaComponent(0.5), forState: .Highlighted)
        defaultSendButton.setTitleColor(UIColor.lightGrayColor().colorWithAlphaComponent(0.5), forState: .Disabled)
        defaultSendButton.titleLabel?.font = UIFont.boldSystemFontOfSize(17)
        defaultSendButton.enabled = false
        
        rightButton = defaultSendButton
    }
    
    /**
     Sets the left button view and removes any existing subviews.
     */
    public weak var leftButton: UIView? {
        didSet {
            leftButtonContainerView.subviews.forEach({ $0.removeFromSuperview() })
            
            if let button = leftButton {
                leftButtonContainerView.addSubview(button)
                button.autoLayoutToSuperview()
            }
        }
    }
    
    /**
     Sets the right button view and removes any existing subviews.
     */
    public weak var rightButton: UIView? {
        didSet {
            rightButtonContainerView.subviews.forEach({ $0.removeFromSuperview() })
            
            if let button = rightButton {
                rightButtonContainerView.addSubview(button)
                button.autoLayoutToSuperview()
            }
        }
    }
}

// MARK: Get / Set

public extension ASTextInputAccessoryView {
    /**
     Font for the textView.
     */
    var font: UIFont {
        set {
            textView.font = newValue
            reloadHeight()
            resetTextContainerInset()
        }
        get {
            return textView.font!
        }
    }
}


// MARK: Update Send Button Enabled

extension ASTextInputAccessoryView: UITextViewDelegate {
    
    public func textViewDidChange(textView: UITextView) {
        if textView == self.textView {
            defaultSendButton.enabled = textView.text.characters.count != 0
        }
    }
}


// MARK: UIInputViewAudioFeedback
extension ASTextInputAccessoryView: UIInputViewAudioFeedback {
    
    public var enableInputClicksWhenVisible: Bool {
        return true
    }
}
