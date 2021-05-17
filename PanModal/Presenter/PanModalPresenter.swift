//
//  YSPanModalPresenter.swift
//  YSPanModal
//
//  Created by Mustafa Gunes on 5.05.2021.
//  Copyright © 2021 yemeksepeti. All rights reserved.
//

import UIKit

/**
 A protocol for objects that will present a view controller as a PanModal

 - Usage:
 ```
 viewController.presentPanModal(viewControllerToPresent: presentingVC,
 sourceView: presentingVC.view,
 sourceRect: .zero)
 ```
 */
protocol YSPanModalPresenter: AnyObject {
    /**
     Presents a view controller that conforms to the YSPanModalPresentable protocol
     */
    func presentPanModal(_ viewControllerToPresent: YSPanModalPresentable.LayoutType,
                         sourceView: UIView?,
                         sourceRect: CGRect,
                         completion: (() -> Void)?)
}
