//
//  YSPanModalPresentable+UIViewController.swift
//  YSPanModal
//
//  Created by Mustafa Gunes on 5.05.2021.
//  Copyright © 2021 yemeksepeti. All rights reserved.
//

import UIKit

/**
 Extends YSPanModalPresentable with helper methods
 when the conforming object is a UIViewController
 */
public extension YSPanModalPresentable where Self: UIViewController {
    typealias AnimationBlockType = () -> Void
    typealias AnimationCompletionType = (Bool) -> Void
    
    /**
     For Presentation, the object must be a UIViewController & confrom to the YSPanModalPresentable protocol.
     */
    typealias LayoutType = UIViewController & YSPanModalPresentable
    
    /**
     A function wrapper over the `transition(to state: PanModalPresentationController.PresentationState)`
     function in the PanModalPresentationController.
     */
    func panModalTransition(to state: YSPanModalPresentationController.PresentationState, animated: Bool) {
        presentedVC?.transition(to: state, animated: animated)
    }
    
    /**
     A function wrapper over the `setNeedsLayoutUpdate()`
     function in the PanModalPresentationController.
     
     - Note: This should be called whenever any of the values for the YSPanModalPresentable protocol are changed.
     */
    func panModalSetNeedsLayoutUpdate() {
        presentedVC?.setNeedsLayoutUpdate()
    }
    
    func panModalSetNeedsLayoutUpdateWithTransition(
        to state: YSPanModalPresentationController.PresentationState,
        animated: Bool
    ) {
        presentedVC?.setNeedsLayoutUpdate()
        self.panModalTransition(to: state, animated: animated)
    }
}
