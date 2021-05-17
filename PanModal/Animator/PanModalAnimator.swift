//
//  YSPanModalAnimator.swift
//  YSPanModal
//
//  Created by Mustafa Gunes on 5.05.2021.
//  Copyright © 2021 yemeksepeti. All rights reserved.
//

import UIKit

/**
 Helper animation function to keep animations consistent.
 */
struct YSPanModalAnimator {
    /**
     Constant Animation Properties
     */
    enum Constants {
        static let defaultSpringDamping: CGFloat = 1.0
        static let defaultTransitionDuration: TimeInterval = 0.5
    }

    static func animate(_ animations: @escaping YSPanModalPresentable.AnimationBlockType,
                        config: YSPanModalPresentable?,
                        _ completion: YSPanModalPresentable.AnimationCompletionType? = nil)
    {
        let transitionDuration = config?.transitionDuration ?? Constants.defaultTransitionDuration
        let springDamping = config?.springDamping ?? Constants.defaultSpringDamping
        let animationOptions = config?.transitionAnimationOptions ?? []

        UIView.animate(withDuration: transitionDuration,
                       delay: 0,
                       usingSpringWithDamping: springDamping,
                       initialSpringVelocity: 0,
                       options: animationOptions,
                       animations: animations,
                       completion: completion)
    }
}
