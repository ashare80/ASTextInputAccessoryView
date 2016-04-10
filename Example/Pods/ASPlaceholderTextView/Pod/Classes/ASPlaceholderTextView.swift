//
//  ASPlaceholderTextView.swift
//  Pods
//
//  Created by Adam J Share on 4/9/16.
//
//

import UIKit

@IBDesignable
public class ASPlaceholderTextView: UITextView {
    
    @IBInspectable public var placeholder: String? {
        set {
            placeholderLabel.text = newValue
        }
        get {
            return placeholderLabel.text
        }
    }
    
    @IBInspectable public var placeholderColor: UIColor? {
        set {
            placeholderLabel.textColor = newValue
        }
        get {
            return placeholderLabel.textColor
        }
    }
    
    private weak var secondaryDelegate: UITextViewDelegate?
    
    public override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setupPlaceholderLabel()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupPlaceholderLabel()
    }
    
    var left: NSLayoutConstraint?
    var width: NSLayoutConstraint?
    var top: NSLayoutConstraint?
    
    public var placeholderLabel: UILabel = UILabel()
    
    func setupPlaceholderLabel() {
        
        placeholderLabel.userInteractionEnabled = false
        placeholderLabel.textColor = placeholderColor
        placeholderLabel.text = placeholder;
        placeholderLabel.backgroundColor = UIColor.clearColor()
        placeholderLabel.textColor = UIColor.lightGrayColor()
        placeholderLabel.numberOfLines = 0;
        placeholderLabel.font = font;
        
        refreshLabelHidden()
        
        addSubview(placeholderLabel)
        
        let offset = textContainer.lineFragmentPadding;
        
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false;
        
        left = NSLayoutConstraint(
            item: placeholderLabel,
            attribute: .Left,
            relatedBy: .Equal,
            toItem: self,
            attribute: .Left,
            multiplier: 1,
            constant: textContainerInset.left + offset
        )
        
        width = NSLayoutConstraint(
            item: placeholderLabel,
            attribute: .Width,
            relatedBy: .Equal,
            toItem: self,
            attribute: .Width,
            multiplier: 1,
            constant: -(textContainerInset.right + offset + textContainerInset.left + offset)
        )
        
        top = NSLayoutConstraint(
            item: placeholderLabel,
            attribute: .Top,
            relatedBy: .Equal,
            toItem: self,
            attribute: .Top,
            multiplier: 1,
            constant: textContainerInset.top
        )
        
        addConstraints([left!, width!, top!])
    }
    
    func updateLabelConstraints() {
        
        let offset = textContainer.lineFragmentPadding;
        
        left?.constant = textContainerInset.left + offset
        width?.constant = -(textContainerInset.right + offset + textContainerInset.left + offset)
        top?.constant = textContainerInset.top
        
        setNeedsLayout()
    }
    
    func refreshLabelHidden() {
        if text == "" || text == nil {
            placeholderLabel.hidden = false;
            return
        } else {
            placeholderLabel.hidden = true;
        }
    }
}

// MARK: Forwarding Delegate
public extension ASPlaceholderTextView {
    
    override var delegate: UITextViewDelegate? {
        set {
            secondaryDelegate = newValue
        }
        get {
            return self
        }
    }
    
    override func respondsToSelector(aSelector: Selector) -> Bool {
        return super.respondsToSelector(aSelector) || secondaryDelegate?.respondsToSelector(aSelector) == true
    }
    
    override func forwardingTargetForSelector(aSelector: Selector) -> AnyObject? {
        
        if (secondaryDelegate?.respondsToSelector(aSelector) == true) {
            return secondaryDelegate
        }
        
        return super.forwardingTargetForSelector(aSelector)
    }
}


// MARK: Override text setters
public extension ASPlaceholderTextView {
    
    public override var font: UIFont? {
        didSet{
            placeholderLabel.font = font
        }
    }
    
    public override var textContainerInset: UIEdgeInsets {
        didSet {
            updateLabelConstraints()
        }
    }
    
    public override var text: String! {
        didSet {
            refreshLabelHidden()
            
            textViewDidChange(self)
        }
    }
    
    public override var textAlignment: NSTextAlignment {
        didSet {
            placeholderLabel.textAlignment = textAlignment
        }
    }
}

// MARK: UITextView Delegate
extension ASPlaceholderTextView: UITextViewDelegate {
    
    public func textViewDidChange(textView: UITextView) {
        
        refreshLabelHidden()
        
        secondaryDelegate?.textViewDidChange?(textView)
    }
}

