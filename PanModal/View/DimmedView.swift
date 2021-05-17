//
//  YSDimmedView.swift
//  YSPanModal
//
//  Created by Mustafa Gunes on 5.05.2021.
//  Copyright © 2021 yemeksepeti. All rights reserved.
//

import UIKit

/**
 A dim view for use as an overlay over content you want dimmed.
 */
public class YSDimmedView: UIView {
    /**
     Represents the possible states of the dimmed view.
     max, off or a percentage of dimAlpha.
     */
    enum YSDimState {
        case max
        case off
        case percent(CGFloat)
    }

    // MARK: - Properties

    /**
     The state of the dimmed view
     */
    var dimState: YSDimState = .off {
        didSet {
            switch self.dimState {
            case .max:
                alpha = 1.0
            case .off:
                alpha = 0.0
            case let .percent(percentage):
                alpha = max(0.0, min(1.0, percentage))
            }
        }
    }

    /**
     The closure to be executed when a tap occurs
     */
    var didTap: ((_ recognizer: UIGestureRecognizer) -> Void)?

    /**
     Tap gesture recognizer
     */
    private lazy var tapGesture: UIGestureRecognizer = {
        UITapGestureRecognizer(target: self, action: #selector(didTapView))
    }()

    // MARK: - Initializers

    init(dimColor: UIColor = UIColor.black.withAlphaComponent(0.7)) {
        super.init(frame: .zero)
        alpha = 0.0
        backgroundColor = dimColor
        addGestureRecognizer(self.tapGesture)
    }

    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError()
    }

    // MARK: - Event Handlers

    @objc private func didTapView() {
        self.didTap?(self.tapGesture)
    }
}
