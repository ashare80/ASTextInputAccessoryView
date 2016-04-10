//
//  ASTextInputAccessoryView.swift
//  Pods
//
//  Created by Adam J Share on 4/9/16.
//
//

import UIKit
import ASPlaceholderTextView

public class ASTextInputAccessoryView: UIView {
    
    public var maximumBarY: CGFloat = 64
    
    public var minimumHeight: CGFloat = 44 {
        didSet {
            refreshBarHeight()
        }
    }
    
    private var heightConstraint: NSLayoutConstraint?
    override public func addConstraint(constraint: NSLayoutConstraint) {
        // Capture the height layout constraint
        if constraint.firstAttribute == .Height {
            heightConstraint = constraint
        }
        super.addConstraint(constraint)
    }

    public weak var delegate: UITextViewDelegate?
    
    public convenience init(maximumBarY: CGFloat, minimumHeight: CGFloat = 44) {
        self.init(frame: CGRect(
            x: 0,
            y: 0,
            width: UIScreen.mainScreen().bounds.width,
            height: minimumHeight
            )
        )
        self.maximumBarY = maximumBarY
    }
    
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        minimumHeight = frame.size.height
        setupContentView()
        setupMessageView()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        minimumHeight = frame.size.height
        setupContentView()
        setupMessageView()
    }
    
    
    // MARK: Main Content Views
    
    public let contentView = UIView()
    public let toolbar = UIToolbar()
    
    func setupContentView() {
        
        backgroundColor = UIColor.clearColor()
        
        addSubview(contentView)
        contentView.autoLayoutToSuperview()
        contentView.backgroundColor = UIColor.clearColor()
        
        contentView.insertSubview(toolbar, atIndex: 0)
        toolbar.barStyle = .Default
        toolbar.autoLayoutToSuperview()
    }
    
    
    // MARK: Message Views
    
    public let messageView = UIView()
    public let textView = ASPlaceholderTextView(frame: CGRectZero, textContainer: nil)
    public let leftButtonContainerView = UIView()
    public let rightButtonContainerView = UIView()
    
    public var margin: CGFloat = 7 {
        didSet {
            updateContentConstraints()
            refreshBarHeight(true)
            resetTextContainerInset()
        }
    }
    
    public func resetTextContainerInset() {
        var height = frame.size.height
        if let constant = heightConstraint?.constant {
            height = constant
        }
        let inset = (height - margin * 2 - textView.lineHeight)/2
        textView.textContainerInset = UIEdgeInsets(top: inset, left: 3, bottom: inset, right: 3)
    }
    
    func setupMessageView() {
        contentView.addSubview(messageView)
        
        messageView.autoLayoutToSuperview()
        messageView.backgroundColor = UIColor.clearColor()
        messageView.addSubview(leftButtonContainerView)
        messageView.addSubview(rightButtonContainerView)
        messageView.addSubview(textView)
        
        textView.placeholder = "Text Message"
        textView.placeholderColor = UIColor.lightGrayColor().colorWithAlphaComponent(0.7)
        textView.delegate = self
        textView.layer.cornerRadius = 5.0
        textView.layer.borderColor = UIColor.lightGrayColor().CGColor
        textView.layer.borderWidth = 0.5
        
        textView.font = UIFont.systemFontOfSize(17)
        resetTextContainerInset()
        
        leftButtonContainerView.backgroundColor = UIColor.clearColor()
        rightButtonContainerView.backgroundColor = UIColor.clearColor()
        
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
            
            let width = NSLayoutConstraint(
                item: view,
                attribute: .Width,
                relatedBy: .Equal,
                toItem: nil,
                attribute: .NotAnAttribute,
                multiplier: 1,
                constant: 0
            )
            
            let height = NSLayoutConstraint(
                item: view,
                attribute: .Height,
                relatedBy: .Equal,
                toItem: nil,
                attribute: .NotAnAttribute,
                multiplier: 1,
                constant: minimumHeight - margin * 2
            )
            
            width.priority = UILayoutPriorityDefaultLow
            view.superview?.addConstraints([width, height])
            
            view.setContentHuggingPriority(UILayoutPriorityRequired, forAxis: .Horizontal)
            view.setContentCompressionResistancePriority(UILayoutPriorityDefaultHigh, forAxis: .Horizontal)
        }
    }
    
    
    // MARK: Button Views
    
    public let defaultSendButton: UIButton = UIButton(type: .Custom)
    
    public func addStandardSendButton() {
        
        defaultSendButton.setTitle("Send", forState: .Normal)
        defaultSendButton.setTitleColor(tintColor, forState: .Normal)
        defaultSendButton.setTitleColor(tintColor.colorWithAlphaComponent(0.5), forState: .Highlighted)
        defaultSendButton.setTitleColor(UIColor.lightGrayColor().colorWithAlphaComponent(0.5), forState: .Disabled)
        defaultSendButton.titleLabel?.font = UIFont.boldSystemFontOfSize(17)
        defaultSendButton.enabled = false
        
        rightButton = defaultSendButton
    }
    
    
    public func setRightView(view: UIView) {
        rightButtonContainerView.subviews.forEach({ $0.removeFromSuperview() })
        rightButtonContainerView.addSubview(view)
        view.autoLayoutToSuperview()
    }
    
    
    public weak var leftButton: UIView? {
        didSet {
            leftButtonContainerView.subviews.forEach({ $0.removeFromSuperview() })
            
            if let button = leftButton {
                leftButtonContainerView.addSubview(button)
                button.autoLayoutToSuperview()
            }
        }
    }
    
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
    
    var font: UIFont {
        set {
            textView.font = newValue
            
            refreshBarHeight()
            resetTextContainerInset()
        }
        get {
            return textView.font!
        }
    }
}

// MARK: UITextViewDelegate
extension ASTextInputAccessoryView: UITextViewDelegate {
    
    public func textViewDidChange(textView: UITextView) {
        
        defaultSendButton.enabled = textView.text.characters.count != 0
        
        refreshBarHeight()
        delegate?.textViewDidChange?(textView)
    }
    
    func barFrameChange(nextBarHeight: CGFloat, forced: Bool = false) {
        if (forced || frame.size.height != nextBarHeight) {
            
            if let heightConstraint = heightConstraint {
                heightConstraint.constant = nextBarHeight
                textView.layoutIfNeeded()
            } else {
                // If internal height constraint wasn't found this will do...
                // Because resign and become switch the backspace can't be held down
                var nextFrame = frame
                nextFrame.size.height = nextBarHeight
                textView.resignFirstResponder()
                frame = nextFrame
                textView.becomeFirstResponder()
            }
            
            textView.scrollToBottomText()
        }
    }
    
    private var maxHeight: CGFloat {
        var keyboardHeight:CGFloat = 0
        if let superview = superview {
            keyboardHeight = superview.frame.size.height
        }
        let fullHeight = UIScreen.mainScreen().bounds.size.height
        let barHeight = frame.size.height
        
        return fullHeight - keyboardHeight - maximumBarY + barHeight
    }

    func refreshBarHeight(forced: Bool = false) {
        var nextBarHeight = minimumHeight
        
        if (textView.text.characters.count == 0) {
            barFrameChange(nextBarHeight, forced: forced)
            return
        }
        
        let lineHeight = textView.lineHeight
        let rows = textView.numberOfRows
        let maxBarHeight = maxHeight
        
        nextBarHeight = (CGFloat(rows) * lineHeight) + (minimumHeight - lineHeight)
        
        if (nextBarHeight > maxBarHeight) {
            nextBarHeight = maxBarHeight
        }
        
        barFrameChange(nextBarHeight, forced: forced)
    }
}


// MARK: UIInputViewAudioFeedback
extension ASTextInputAccessoryView: UIInputViewAudioFeedback {
    
    public var enableInputClicksWhenVisible: Bool {
        return true
    }
}


// MARK: Forwarding Delegate
public extension ASTextInputAccessoryView {
    
    override func respondsToSelector(aSelector: Selector) -> Bool {
        return super.respondsToSelector(aSelector) || delegate?.respondsToSelector(aSelector) == true
    }
    
    override func forwardingTargetForSelector(aSelector: Selector) -> AnyObject? {
        
        if (delegate?.respondsToSelector(aSelector) == true) {
            return delegate
        }
        
        return super.forwardingTargetForSelector(aSelector)
    }
}