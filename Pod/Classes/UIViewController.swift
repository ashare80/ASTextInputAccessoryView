//
//  UIViewController.swift
//  Pods
//
//  Created by Adam J Share on 11/2/15.
//
//

import Foundation
import UIKit

public extension UIViewController {
    
    public var topBarHeight: CGFloat {
        
        var topHeight = UIApplication.sharedApplication().statusBarFrame.size.height
        if let height = navigationController?.navigationBar.frame.size.height {
            topHeight += height
        }
        
        return topHeight
    }
}

//MARK: - Hierarchy

public extension UIViewController {
    
    var firstPresentedViewController: UIViewController? {
        
        var viewController = presentedViewController
        
        while viewController?.presentingViewController != self && viewController?.presentingViewController != navigationController {
            
            viewController = viewController?.presentingViewController
            
            if viewController == nil {
                return nil
            }
        }
        
        if let controller = (viewController as? UINavigationController)?.viewControllers.first {
            return controller
        }
        
        return viewController
    }
    
    var isFirstController: Bool {
        
        return navigationController?.viewControllers.first == self
    }
    
    var topLevelController: UIViewController {
        
        if presentedViewController == nil {
            return self
        }
        
        return presentedViewController!.topLevelController
    }
    
    var isRootViewController: Bool {
        return navigationController?.viewControllers.count <= 1;
    }
    
    class var topViewController: UIViewController {
        
        let rootViewController = UIApplication.sharedApplication().delegate!.window!!.rootViewController
        return topViewControllerWithRootViewController(rootViewController!)
    }
    
    class func topViewControllerWithRootViewController(rootViewController: UIViewController) -> UIViewController {
        // Handling UITabBarController
        
        if let rootViewController = rootViewController as? UITabBarController, let selected = rootViewController.selectedViewController {
            return topViewControllerWithRootViewController(selected)
        }
        else if let rootViewController = rootViewController as? UINavigationController, let visible = rootViewController.visibleViewController {
            return topViewControllerWithRootViewController(visible)
        }
        else if let presentedViewController = rootViewController.presentedViewController {
            return topViewControllerWithRootViewController(presentedViewController)
        }
        
        return rootViewController
    }
}
