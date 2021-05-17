//
//  YSPanModalPresentable+LayoutHelpers.swift
//  YSPanModal
//
//  Created by Mustafa Gunes on 5.05.2021.
//  Copyright © 2021 yemeksepeti. All rights reserved.
//

import UIKit

/**
 ⚠️ [Internal Only] ⚠️
 Helper extensions that handle layout in the PanModalPresentationController
 */
extension YSPanModalPresentable where Self: UIViewController {
    /**
     Cast the presentation controller to PanModalPresentationController
     so we can access PanModalPresentationController properties and methods
     */
    var presentedVC: YSPanModalPresentationController? {
        return presentationController as? YSPanModalPresentationController
    }

    /**
     Length of the top layout guide of the presenting view controller.
     Gives us the safe area inset from the top.
     */
    var topLayoutOffset: CGFloat {
        guard let rootVC = rootViewController
        else { return 0 }

        if #available(iOS 11.0, *) { return rootVC.view.safeAreaInsets.top } else { return rootVC.topLayoutGuide.length }
    }

    /**
     Length of the bottom layout guide of the presenting view controller.
     Gives us the safe area inset from the bottom.
     */
    var bottomLayoutOffset: CGFloat {
        guard let rootVC = rootViewController
        else { return 0 }

        if #available(iOS 11.0, *) { return rootVC.view.safeAreaInsets.bottom } else { return rootVC.bottomLayoutGuide.length }
    }

    /**
     Returns the short form Y position

     - Note: If voiceover is on, the `longFormYPos` is returned.
     We do not support short form when voiceover is on as it would make it difficult for user to navigate.
     */
    var shortFormYPos: CGFloat {
        guard !UIAccessibility.isVoiceOverRunning
        else { return self.longFormYPos }

        let shortFormYPos = self.topMargin(from: shortFormHeight) + topOffset

        // shortForm shouldn't exceed longForm
        return max(shortFormYPos, self.longFormYPos)
    }

    /**
     Returns the long form Y position

     - Note: We cap this value to the max possible height
     to ensure content is not rendered outside of the view bounds
     */
    var longFormYPos: CGFloat {
        return max(self.topMargin(from: longFormHeight), self.topMargin(from: .maxHeight)) + topOffset
    }

    /**
     Use the container view for relative positioning as this view's frame
     is adjusted in PanModalPresentationController
     */
    var bottomYPos: CGFloat {
        guard let container = presentedVC?.containerView
        else { return view.bounds.height }

        return container.bounds.size.height - topOffset
    }

    /**
     Converts a given pan modal height value into a y position value
     calculated from top of view
     */
    func topMargin(from: YSPanModalHeight) -> CGFloat {
        switch from {
        case .maxHeight:
            return 0.0
        case let .maxHeightWithTopInset(inset):
            return inset
        case let .contentHeight(height):
            return self.bottomYPos - (height + self.bottomLayoutOffset)
        case let .contentHeightIgnoringSafeArea(height):
            return self.bottomYPos - height
        case .intrinsicHeight:
            view.layoutIfNeeded()
            let targetSize = CGSize(width: (presentedVC?.containerView?.bounds ?? UIScreen.main.bounds).width,
                                    height: UIView.layoutFittingCompressedSize.height)
            let intrinsicHeight = view.systemLayoutSizeFitting(targetSize).height
            return self.bottomYPos - (intrinsicHeight + self.bottomLayoutOffset)
        case let .intrinsicHeightWithInsets(insets: insets):
            view.layoutIfNeeded()
            let targetSize = CGSize(width: (presentedVC?.containerView?.bounds ?? UIScreen.main.bounds).width,
                                    height: UIView.layoutFittingCompressedSize.height)
            let intrinsicHeight = view.systemLayoutSizeFitting(targetSize).height
            let bottomOffset = self.bottomLayoutOffset + insets.bottom
            return self.bottomYPos - (intrinsicHeight + bottomOffset)
        }
    }

    private var rootViewController: UIViewController? {
        guard let application = UIApplication.value(forKeyPath: #keyPath(UIApplication.shared)) as? UIApplication
        else { return nil }

        return application.keyWindow?.rootViewController
    }
}
