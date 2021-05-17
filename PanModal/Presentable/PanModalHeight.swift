//
//  YSPanModalHeight.swift
//  YSPanModal
//
//  Created by Mustafa Gunes on 5.05.2021.
//  Copyright © 2021 yemeksepeti. All rights reserved.
//

import UIKit

/**
 An enum that defines the possible states of the height of a pan modal container view
 for a given presentation state (shortForm, longForm)
 */
public enum YSPanModalHeight: Equatable {
    /**
     Sets the height to be the maximum height (+ topOffset)
     */
    case maxHeight

    /**
     Sets the height to be the max height with a specified top inset.
     - Note: A value of 0 is equivalent to .maxHeight
     */
    case maxHeightWithTopInset(CGFloat)

    /**
     Sets the height to be the specified content height
     */
    case contentHeight(CGFloat)

    /**
     Sets the height to be the specified content height
     & also ignores the bottomSafeAreaInset
     */
    case contentHeightIgnoringSafeArea(CGFloat)

    /**
     Sets the height to be the intrinsic content height
     */
    case intrinsicHeight

    /**
     Sets the height to be the intrinsic content height
     */
    case intrinsicHeightWithInsets(insets: UIEdgeInsets)
}
