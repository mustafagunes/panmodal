//
//  YSPanModalPresentable+Defaults.swift
//  YSPanModal
//
//  Created by Mustafa Gunes on 5.05.2021.
//  Copyright © 2021 yemeksepeti. All rights reserved.
//

import UIKit

/**
 Default values for the YSPanModalPresentable.
 */
public extension YSPanModalPresentable where Self: UIViewController {
    var topOffset: CGFloat {
        return topLayoutOffset + 55.0
    }

    var shortFormHeight: YSPanModalHeight {
        return self.longFormHeight
    }

    var longFormHeight: YSPanModalHeight {
        guard let scrollView = panScrollable
        else { return .maxHeight }

        // called once during presentation and stored
        scrollView.layoutIfNeeded()
        return .contentHeight(scrollView.contentSize.height)
    }

    var cornerRadius: CGFloat {
        return 8.0
    }

    var springDamping: CGFloat {
        return 0.8
    }

    var transitionDuration: Double {
        return YSPanModalAnimator.Constants.defaultTransitionDuration
    }

    var transitionAnimationOptions: UIView.AnimationOptions {
        return [.curveEaseInOut, .allowUserInteraction, .beginFromCurrentState]
    }

    var panModalBackgroundColor: UIColor {
        return UIColor.black.withAlphaComponent(0.7)
    }

    var indicatorBackgroundColor: UIColor {
        return .white
    }
    
    var dragIndicatorBackgroundColor: UIColor {
        return UIColor(red: 0.82, green: 0.82, blue: 0.82, alpha: 1.00)
    }
    
    var controllerTitleColor: UIColor {
        return UIColor(red: 0.84, green: 0.07, blue: 0.09, alpha: 1.00)
    }
    
    var controllerTitle: NSAttributedString? {
        return nil
    }
    
    var dragIndicatorCornerRadius: CGFloat {
        return 24.0
    }

    var scrollIndicatorInsets: UIEdgeInsets {
        let top = self.shouldRoundTopCorners ? self.cornerRadius : 0
        return UIEdgeInsets(top: CGFloat(top), left: 0, bottom: bottomLayoutOffset, right: 0)
    }

    var anchorModalToLongForm: Bool {
        return true
    }

    var allowsExtendedPanScrolling: Bool {
        guard let scrollView = panScrollable
        else { return false }

        scrollView.layoutIfNeeded()
        return scrollView.contentSize.height > (scrollView.frame.height - bottomLayoutOffset)
    }

    var allowsDragToDismiss: Bool {
        return true
    }

    var allowsTapToDismiss: Bool {
        return true
    }

    var isUserInteractionEnabled: Bool {
        return true
    }

    var isHapticFeedbackEnabled: Bool {
        return true
    }

    var shouldRoundTopCorners: Bool {
        return isPanModalPresented
    }

    var showCloseButton: Bool {
        return true
    }

    func shouldRespond(to panModalGestureRecognizer: UIPanGestureRecognizer) -> Bool {
        return true
    }

    func willRespond(to panModalGestureRecognizer: UIPanGestureRecognizer) {}

    func shouldTransition(to state: YSPanModalPresentationController.PresentationState) -> Bool {
        return true
    }

    func shouldPrioritize(panModalGestureRecognizer: UIPanGestureRecognizer) -> Bool {
        return false
    }

    func willTransition(to state: YSPanModalPresentationController.PresentationState) {}

    func panModalWillDismiss() {}

    func panModalDidDismiss() {}
}
