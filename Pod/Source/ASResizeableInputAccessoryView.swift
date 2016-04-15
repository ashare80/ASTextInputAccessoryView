//
//  ASResizeableInputAccessoryView.swift
//  Pods
//
//  Created by Adam J Share on 4/11/16.
//
//

import Foundation

public class ASResizeableInputAccessoryView: UIView {
    
    public weak var delegate: ASResizeableInputAccessoryViewDelegate?
    
    public var animationOptions: ASAnimationOptions! = ASAnimationOptions()
    
    /**
     Animates changes to the containerView height before height change of self. 
     - default: `true`
     */
    public var animateBarHeightOnReload: Bool = true
    
    /**
     The maximum point in the window's Y axis that the InputAccessoryView origin should reach.
     */
    public var maximumBarY: CGFloat {
        if let max = delegate?.inputAccessoryViewMaximumBarY(self) {
            return max
        }
        return UIViewController.topViewController.topBarHeight
    }
    
    /**
     Height of the selected content.
     */
    public var contentHeight: CGFloat {
        if let height = selectedContentView?.contentHeight {
            return height
        }
        return 0
    }
    
    /**
     Sets height to the current content height. Will animate if animateBarHeightOnReload is true.
     
     - parameters:
        - options: Optional animation options. Defaults to animationOptions.
     */
    
    public func reloadHeight(options: ASAnimationOptions? = nil) {
        self.setHeight(contentHeight, animated: animateBarHeightOnReload, options: options)
    }
    
    /**
     Internal height constraint that is created when added to keyboard. This is the true height of the view. When animating this will stay at the previous height until completion of animation. Canceling animations could cause this height to be set incorrectly
     */
    private var heightConstraint: NSLayoutConstraint?
    override public func addConstraint(constraint: NSLayoutConstraint) {
        // Capture the height layout constraint
        if constraint.firstAttribute == .Height && constraint.firstItem as? NSObject == self {
            heightConstraint = constraint
        }
        super.addConstraint(constraint)
    }
    
    public var contentViews: [ASResizeableContentView] = [] {
        didSet {
            selectedContentView = contentViews.first
        }
    }
    public var selectedContentView: ASResizeableContentView? {
        willSet {
            if let view = selectedContentView as? UIView {
                view.removeFromSuperview()
            }
        }
        didSet {
            if let view = selectedContentView as? UIView {
                view.removeFromSuperview()
                containerView.addSubview(view)
                view.autoLayoutToSuperview()
            }
            reloadHeight()
        }
    }
    
    public convenience init(contentViews: [ASResizeableContentView]) {
        let containerView = contentViews.first!
        
        self.init(frame: CGRect(
            x: 0,
            y: 0,
            width: UIScreen.mainScreen().bounds.width,
            height: containerView.contentHeight
            )
        )
        self.contentViews = contentViews
        selectedContentView = contentViews.first
    }
    
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupcontainerView()
        addKeyboardNotificationsAll()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupcontainerView()
        addKeyboardNotificationsAll()
    }
    
    // MARK: Keyboard monitoring
    deinit {
        removeKeyboardNotificationsAll()
    }
    
    /**
     Keeps track of keyboard presentation as an interactive dismiss that cancels can trigger an event that mimics a standard keyboard presentation
     */
    private var keyboardPresented: Bool = false
    
    // MARK: Main Content Views
    
    /**
     Any custom views should be added to the containerView subview hierarchy.
     */
    public let containerView = UIView()
    
    /**
     Background toolbar for standard appearance.
     */
    public let toolbar = UIToolbar()
    
    
    /**
     Height constraint of the containerView. Is used to animate height and therefore can be used to find the most up to date height set.
     */
    public var containerViewHeightConstraint: NSLayoutConstraint!
    
    func setupcontainerView() {
        
        backgroundColor = UIColor.clearColor()
        
        addSubview(containerView)
        containerView.backgroundColor = UIColor.clearColor()
        containerView.autoLayoutToSuperview([.Bottom, .Left, .Right], inset: 0)
        
        var constant: CGFloat = 0
        if let height = selectedContentView?.contentHeight {
            constant = height
        }
        containerViewHeightConstraint = containerView.addHeightConstraint(constant, priority: UILayoutPriorityRequired)
        
        containerView.insertSubview(toolbar, atIndex: 0)
        toolbar.barStyle = .Default
        toolbar.autoLayoutToSuperview()
    }
    
    /**
     Executes animation with completion. Override to insert animateable changes.
     */
    public func updateBarHeight(animated: Bool, options: ASAnimationOptions, animateableChange:() -> Void, completion:(Bool) -> Void) {
        
        if !animated {
            animateableChange()
            completion(true)
            return
        }
        
        options.animate(animateableChange, completion: completion)
    }
}


extension ASResizeableInputAccessoryView {
    
    /**
     Height of the view. Changes will be immediate. To animate use the setHeight:animated: method
     */
    public var height: CGFloat {
        set {
            setHeight(newValue, animated: false)
        }
        get {
            return containerViewHeightConstraint.constant
        }
    }
    
    /**
     Max height of the view in relation to the keyboard height and maximumBarY value.
     */
    var maximumHeight: CGFloat {
        var keyboardHeight:CGFloat = 0
        if let superview = superview {
            keyboardHeight = superview.frame.size.height
        }
        let fullHeight = UIScreen.mainScreen().bounds.size.height
        let barHeight = frame.size.height
        
        return fullHeight - keyboardHeight - maximumBarY + barHeight
    }
    
    
    /**
     Sets the height of the view with option to animate.
     */
    public func setHeight(height: CGFloat, animated: Bool, options: ASAnimationOptions? = nil) {
        
        var nextBarHeight = height
        
        if nextBarHeight > maximumHeight {
            nextBarHeight = maximumHeight
        }
        
        if let delegatedHeight = delegate?
            .inputAccessoryViewNextHeight(self, suggestedHeight: nextBarHeight, currentHeight: containerViewHeightConstraint.constant) {
            nextBarHeight = delegatedHeight
        }
        
        guard let heightConstraint = heightConstraint else {
            print("ASTextInputAccessoryView heightConstraint was not found.")
            if autoresizingMask != .None {
                // If internal height constraint wasn't found the view layout mask may have been set
                print("AutoresizingMask should be set to .None (0). Current autoresizingMask: ", autoresizingMask)
            }
            return
        }
        
        let containerViewEqualHeight = containerViewHeightConstraint.constant.roundToNearestHalf == nextBarHeight.roundToNearestHalf
        
        guard !containerViewEqualHeight else {
            return
        }
        
        var options = options
        if options == nil {
            options = self.animationOptions
        }
        
        let fullHeight = superview?.frame.size.height != nil ? superview!.frame.size.height : 0
        var keyboardHeight = fullHeight - frame.size.height + nextBarHeight
        keyboardHeight = keyboardHeight < 0 ? nextBarHeight : keyboardHeight
        
        let delegateChange = delegate?.inputAccessoryViewWillAnimateToHeight(self, height: nextBarHeight, keyboardHeight: keyboardHeight)
        
        updateBarHeight(
            animated,
            options: options!,
            animateableChange: {
                self.containerViewHeightConstraint.constant = nextBarHeight
                self.containerView.layoutIfNeeded()
                delegateChange?()
            },
            completion: { (finished) in
                heightConstraint.constant = nextBarHeight
                self.layoutIfNeeded()
                self.delegate?.inputAccessoryViewDidAnimateToHeight(self, height: nextBarHeight, keyboardHeight: keyboardHeight)
            }
        )
    }
}



//MARK: Keyboard notifications
public extension ASResizeableInputAccessoryView {
    
    /**
    Interactive dismiss causes confusion with notifications so to try and regulate we'll keep track of when it was already shown and when it's being dismissed. We can compare the FrameEnd height to the view height and FrameBegin height to filter out willShow notes based on keyboard dismissing but the view sticking around.
    */
    
    public override func keyboardWillShow(notification: NSNotification) {
        
        guard
            !keyboardPresented &&
            notification.keyboardFrameEnd.height != frame.size.height &&
            notification.keyboardFrameBegin.height == notification.keyboardFrameEnd.height
            else {
            return
        }
        
        keyboardPresented = true
        
        let animation = delegate?.inputAccessoryViewKeyboardWillPresent(self, notification: notification)
        keyboardAnimation(notification, block: animation)
    }
    
    public override func keyboardWillHide(notification: NSNotification) {
        keyboardPresented = false
        
        let animation = delegate?.inputAccessoryViewKeyboardWillDismiss(self, notification: notification)
        keyboardAnimation(notification, block: animation)
    }
    
    public override func keyboardDidChangeFrame(notification: NSNotification) {
        
        let isAnimating = containerView.layer.animationKeys()?.count > 0
        if !isAnimating && keyboardPresented {
            delegate?.inputAccessoryViewKeyboardDidChangeHeight(self, notification: notification)
        }
    }
    
    private func keyboardAnimation(notification: NSNotification, block: (() -> Void)?) {
        guard let animationBlock = block else {
            return
        }
        
        UIView.animateWithDuration(
            notification.keyboardAnimationDuration,
            delay: 0.0,
            options: notification.keyboardAnimationCurve,
            animations: animationBlock,
            completion: nil
        )
    }
}