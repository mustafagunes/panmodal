//
//  PanModalPresentable+UIViewController.swift
//  PanModal
//
//  Copyright © 2018 Tiny Speck, Inc. All rights reserved.
//

import UIKit

/**
 Extends PanModalPresentable with helper methods
 when the conforming object is a UIViewController
 */
public extension PanModalPresentable where Self: UIViewController {
    typealias AnimationBlockType = () -> Void
    typealias AnimationCompletionType = (Bool) -> Void
    
    /**
     For Presentation, the object must be a UIViewController & confrom to the PanModalPresentable protocol.
     */
    typealias LayoutType = UIViewController & PanModalPresentable
    
    /**
     A function wrapper over the `transition(to state: PanModalPresentationController.PresentationState)`
     function in the PanModalPresentationController.
     */
    func panModalTransition(to state: PanModalPresentationController.PresentationState, animated: Bool) {
        presentedVC?.transition(to: state, animated: animated)
    }
    
    /**
     A function wrapper over the `setNeedsLayoutUpdate()`
     function in the PanModalPresentationController.
     
     - Note: This should be called whenever any of the values for the PanModalPresentable protocol are changed.
     */
    func panModalSetNeedsLayoutUpdate() {
        presentedVC?.setNeedsLayoutUpdate()
    }
    
    func panModalSetNeedsLayoutUpdateWithTransition(
        to state: PanModalPresentationController.PresentationState,
        animated: Bool
    ) {
        presentedVC?.setNeedsLayoutUpdate()
        self.panModalTransition(to: state, animated: animated)
    }
}
