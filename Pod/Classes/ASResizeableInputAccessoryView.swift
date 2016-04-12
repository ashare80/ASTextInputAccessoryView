//
//  ASResizeableInputAccessoryView.swift
//  Pods
//
//  Created by Adam J Share on 4/11/16.
//
//

import Foundation

public protocol ASResizeableInputAccessoryViewDelegate: class {
    /**
     The maximum point in the window's Y axis that the InputAccessoryView origin should reach.
     
     - default:
     ````
     UIApplication.sharedApplication().statusBarFrame.size.height + navigationController!.navigationBar.frame.size.height
     ````
     */
    func maximumBarY() -> CGFloat
    
    /**
     On reload, asks the delegate what the next height should be.
     
     - parameters:
        - nextHeight: Suggested content height based off the view's calculations.
        - currentHeight: CurrentHeight view height.
     
     - returns: Desired height. Defaults to nextHeight.
     */
    func nextHeight(nextHeight: CGFloat, currentHeight: CGFloat) -> CGFloat
}

extension ASResizeableInputAccessoryViewDelegate {
    
    func nextHeight(nextHeight: CGFloat, currentHeight: CGFloat) -> CGFloat {
        return nextHeight
    }
}

extension ASResizeableInputAccessoryViewDelegate where Self: UIViewController {
    
    func maximumBarY() -> CGFloat {
        return topBarHeight
    }
}


public class ASResizeableInputAccessoryView: UIView {
    
    public weak var delegate: ASResizeableInputAccessoryViewDelegate?
    
    public var animationOptions: ASAnimationOptions! = ASAnimationOptions()
    
    /**
     Animates changes to the contentView height before height change of self
     */
    public var animateBarHeightOnReload: Bool = true
    
    /**
     The maximum point in the window's Y axis that the InputAccessoryView origin should reach.
     */
    public var maximumBarY: CGFloat {
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
            reloadHeight()
        }
    }
    
    /**
     Subclasses should override this var to return a desired height for content.
     */
    public var contentHeight: CGFloat {
        return minimumHeight
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
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        minimumHeight = frame.size.height
        setupContentView()
    }
    
    // MARK: Main Content Views
    
    /**
     Any custom views should be added to the contentView subview hierarchy.
     */
    public let contentView = UIView()
    
    public var contentViewHeight: NSLayoutConstraint!
    
    func setupContentView() {
        
        backgroundColor = UIColor.clearColor()
        
        addSubview(contentView)
        contentView.backgroundColor = UIColor.clearColor()
        contentView.autoLayoutToSuperview([.Bottom, .Left, .Right], inset: 0)
        contentViewHeight = contentView.addHeightConstraint(minimumHeight)
    }
    
    /**
     Executes animation with completion. Override to insert animateable changes.
     */
    func updateBarHeight(animated: Bool, options: ASAnimationOptions, animateableChange:() -> Void, completion:() -> Void) {
        
        if !animated {
            animateableChange()
            completion()
            return
        }
        
        layer.removeAllAnimations()
        UIView.animateWithDuration(
            options.duration,
            delay: options.delay,
            usingSpringWithDamping: options.damping,
            initialSpringVelocity: options.velocity,
            options: options.options,
            animations: {
                animateableChange()
            },
            completion: { (finished) in
                if finished {
                    completion()
                }
            }
        )
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
            return contentViewHeight.constant
        }
    }
    
    /**
     Max height of the view in relation to the keyboard height and maximumBarY value.
     */
    var maxHeight: CGFloat {
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
        if let delegatedHeight = delegate?.nextHeight(nextBarHeight, currentHeight: contentViewHeight.constant) {
            nextBarHeight = delegatedHeight
        }
        
        guard contentViewHeight.constant.roundToNearestHalf  != nextBarHeight.roundToNearestHalf else {
            return
        }
        
        guard let heightConstraint = heightConstraint else {
            print("ASTextInputAccessoryView heightConstraint was not found.")
            if autoresizingMask != .None {
                // If internal height constraint wasn't found the view layout mask may have been set
                print("AutoresizingMask should be set to .None (0). Current autoresizingMask: ", autoresizingMask)
            }
            return
        }
        
        var options = options
        if options == nil {
            options = self.animationOptions
        }
        
        updateBarHeight(
            animated,
            options: options!,
            animateableChange: {
                self.contentViewHeight.constant = nextBarHeight
                self.contentView.layoutIfNeeded()
            }, completion: {
                heightConstraint.constant = nextBarHeight
            }
        )
    }
}