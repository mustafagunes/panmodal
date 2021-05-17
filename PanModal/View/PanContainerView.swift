//
//  YSPanContainerView.swift
//  YSPanModal
//
//  Created by Mustafa Gunes on 5.05.2021.
//  Copyright © 2021 yemeksepeti. All rights reserved.
//

import UIKit

/**
 A view wrapper around the presented view in a PanModal transition.

 This allows us to make modifications to the presented view without
 having to do those changes directly on the view
 */
class YSPanContainerView: UIView {
    init(presentedView: UIView, frame: CGRect) {
        super.init(frame: frame)
        addSubview(presentedView)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UIView {
    /**
     Convenience property for retrieving a YSPanContainerView instance
     from the view hierachy
     */
    var panContainerView: YSPanContainerView? {
        return subviews.first(where: { view -> Bool in
            view is YSPanContainerView
        }) as? YSPanContainerView
    }
}
