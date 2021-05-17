//
//  YSPanModalPresentationDelegate.swift
//  YSPanModal
//
//  Created by Mustafa Gunes on 5.05.2021.
//  Copyright © 2021 yemeksepeti. All rights reserved.
//

import UIKit

/**
 The YSPanModalPresentationDelegate conforms to the various transition delegates
 and vends the appropriate object for each transition controller requested.

 Usage:
 ```
 viewController.modalPresentationStyle = .custom
 viewController.transitioningDelegate = YSPanModalPresentationDelegate.default
 ```
 */
public class YSPanModalPresentationDelegate: NSObject {
    /**
     Returns an instance of the delegate, retained for the duration of presentation
     */
    public static var `default`: YSPanModalPresentationDelegate = {
        YSPanModalPresentationDelegate()
    }()
}

extension YSPanModalPresentationDelegate: UIViewControllerTransitioningDelegate {
    /**
     Returns a modal presentation animator configured for the presenting state
     */
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return YSPanModalPresentationAnimator(transitionStyle: .presentation)
    }

    /**
     Returns a modal presentation animator configured for the dismissing state
     */
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return YSPanModalPresentationAnimator(transitionStyle: .dismissal)
    }

    /**
     Returns a modal presentation controller to coordinate the transition from the presenting
     view controller to the presented view controller.

     Changes in size class during presentation are handled via the adaptive presentation delegate
     */
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let controller = YSPanModalPresentationController(presentedViewController: presented, presenting: presenting)
        controller.delegate = self
        return controller
    }
}

extension YSPanModalPresentationDelegate: UIAdaptivePresentationControllerDelegate, UIPopoverPresentationControllerDelegate {
    /**
     - Note: We do not adapt to size classes due to the introduction of the UIPresentationController
     & deprecation of UIPopoverController (iOS 9), there is no way to have more than one
     presentation controller in use during the same presentation

     This is essential when transitioning from .popover to .custom on iPad split view... unless a custom popover view is also implemented
     (popover uses UIPopoverPresentationController & we use PanModalPresentationController)
     */

    /**
     Dismisses the presented view controller
     */
    public func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}
