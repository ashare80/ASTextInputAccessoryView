//
//  ASTextInputAccessoryView.swift
//  Pods
//
//  Created by Adam J Share on 4/9/16.
//
//

import UIKit
import ASPlaceholderTextView

public protocol ASTextInputAccessoryViewDelegate: UITextViewDelegate {
    /**
     The maximum point in the window's Y axis that the InputAccessoryView origin should reach. 
     
     - default: 
     ````
     UIApplication.sharedApplication().statusBarFrame.size.height + navigationController!.navigationBar.frame.size.height
     ````
     */
    func maximumBarY() -> CGFloat
}

extension ASTextInputAccessoryViewDelegate where Self: UIViewController {
    
    func maximumBarY() -> CGFloat {
        return topBarHeight
    }
}

public class ASTextInputAccessoryView: UIView {
    
    /**
     The maximum point in the window's Y axis that the InputAccessoryView origin should reach.
    */
    private var maximumBarY: CGFloat {
        if let max = delegate?.maximumBarY() {
            return max
        }
        return UIViewController.topViewController.topBarHeight
    }
    
    /**
     Standard height of bar without text.
     */
    public var minimumHeight: CGFloat = 44 {
        didSet {
            refreshBarHeight()
        }
    }
    
    /**
     Animates changes to the contentView height before height change of self
     */
    public var animateBarHeight: Bool = true
    
    /**
     Internal height constraint that is created when added to keyboard.
     */
    private var heightConstraint: NSLayoutConstraint?
    override public func addConstraint(constraint: NSLayoutConstraint) {
        // Capture the height layout constraint
        if constraint.firstAttribute == .Height && constraint.firstItem as? NSObject == self {
            heightConstraint = constraint
        }
        super.addConstraint(constraint)
    }

    
    public weak var delegate: ASTextInputAccessoryViewDelegate?
    
    public convenience init(minimumHeight: CGFloat = 44) {
        self.init(frame: CGRect(
            x: 0,
            y: 0,
            width: UIScreen.mainScreen().bounds.width,
            height: minimumHeight
            )
        )
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
    
    /**
     Any custom views should be added to the contentView subview hierarchy.
     */
    public let contentView = UIView()
    
    /**
     Background toolbar for standard appearance.
     */
    public let toolbar = UIToolbar()
    
    private var contentViewHeight: NSLayoutConstraint!
    
    func setupContentView() {
        
        backgroundColor = UIColor.clearColor()
        
        addSubview(contentView)
        contentView.backgroundColor = UIColor.clearColor()
        contentView.autoLayoutToSuperview([.Bottom, .Left, .Right], inset: 0)
        contentViewHeight = contentView.addHeightConstraint(minimumHeight)
        
        contentView.insertSubview(toolbar, atIndex: 0)
        toolbar.barStyle = .Default
        toolbar.autoLayoutToSuperview()
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
            refreshBarHeight()
            resetTextContainerInset()
        }
    }
    
    /**
     Resets textContainerInset based off the text line height and margin.
     */
    public func resetTextContainerInset() {
        var height = contentViewHeight.constant
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
    
    private var maxHeight: CGFloat {
        var keyboardHeight:CGFloat = 0
        if let superview = superview {
            keyboardHeight = superview.frame.size.height
        }
        let fullHeight = UIScreen.mainScreen().bounds.size.height
        let barHeight = frame.size.height
        
        return fullHeight - keyboardHeight - maximumBarY + barHeight
    }

    /**
     Refreshes the bar height based on minimumHeight, textView.lineHeight, and maximumBarY.
     
     - parameters:
        - forced: If `true` will set values even if the height did not change.
     */
    public func refreshBarHeight(forced: Bool = false) {
        var nextBarHeight = minimumHeight
        
        if textView.text.characters.count == 0 {
            height = nextBarHeight
            return
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
        
        
        height = nextBarHeight
    }
    
    
    public var height: CGFloat {
        set {
            _setHeight(newValue)
        }
        get {
            return contentViewHeight.constant
        }
    }
    
    private func _setHeight(nextBarHeight: CGFloat) {
        guard contentViewHeight.constant.roundToNearestHalf  != nextBarHeight.roundToNearestHalf else {
            return
        }
        
        guard let heightConstraint = heightConstraint else {
            print("ASTextInputAccessoryView heightConstraint was not found")
            // If internal height constraint wasn't found this can work but not optimal...
            // resignFirstResponder to allow frame change and then regain responder
            // Because of resignFirstResponder and becomeFirstResponder, the backspace can't be held down
            var nextFrame = frame
            nextFrame.size.height = nextBarHeight
            textView.resignFirstResponder()
            frame = nextFrame
            contentViewHeight.constant = nextBarHeight
            contentView.layoutIfNeeded()
            textView.becomeFirstResponder()
            textView.scrollToBottomText()
            return
        }
        
        barChangeAnimation({
            self.contentViewHeight.constant = nextBarHeight
            self.contentView.layoutIfNeeded()
            self.textView.scrollToBottomText()
            }, completion: {
                heightConstraint.constant = nextBarHeight
                self.textView.layoutIfNeeded()
        })
    }
    
    func barChangeAnimation(animate:() -> Void, completion:() -> Void) {
        
        if !animateBarHeight {
            animate()
            completion()
            return
        }
        
        UIView.animateWithDuration(
            0.2,
            delay: 0.0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.8,
            options: .BeginFromCurrentState,
            animations: {
                animate()
            },
            completion: { [weak self] (finished) in
                completion()
            }
        )
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
        
        if delegate?.respondsToSelector(aSelector) == true {
            return delegate
        }
        
        return super.forwardingTargetForSelector(aSelector)
    }
}
