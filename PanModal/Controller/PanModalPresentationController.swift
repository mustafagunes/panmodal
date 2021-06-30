//
//  YSPanModalPresentationController.swift
//  YSPanModal
//
//  Created by Mustafa Gunes on 5.05.2021.
//  Copyright © 2021 yemeksepeti. All rights reserved.
//

import UIKit

/**
 The YSPanModalPresentationController is the middle layer between the presentingViewController
 and the presentedViewController.

 It controls the coordination between the individual transition classes as well as
 provides an abstraction over how the presented view is presented & displayed.

 For example, we add a drag indicator view above the presented view and
 a background overlay between the presenting & presented view.

 The presented view's layout configuration & presentation is defined using the YSPanModalPresentable.

 By conforming to the YSPanModalPresentable protocol & overriding values
 the presented view can define its layout configuration & presentation.
 */
open class YSPanModalPresentationController: UIPresentationController {
    /**
     Enum representing the possible presentation states
     */
    public enum PresentationState {
        case shortForm
        case longForm
    }

    /**
     Constants
     */
    enum Constants {
        static let indicatorYOffset = CGFloat(8.0)
        static let snapMovementSensitivity = CGFloat(0.7)
        static let indicatorContentHeight = CGFloat(55.0)
        static let dragIndicatorSize = CGSize(width: 42.0, height: 5.0)
    }

    // MARK: - Properties

    /**
     A flag to track if the presented view is animating
     */
    private var isPresentedViewAnimating = false

    /**
     A flag to determine if scrolling should seamlessly transition
     from the pan modal container view to the scroll view
     once the scroll limit has been reached.
     */
    private var extendsPanScrolling = true

    /**
     A flag to determine if scrolling should be limited to the longFormHeight.
     Return false to cap scrolling at .max height.
     */
    private var anchorModalToLongForm = true

    /**
     The y content offset value of the embedded scroll view
     */
    private var scrollViewYOffset: CGFloat = 0.0

    /**
     An observer for the scroll view content offset
     */
    private var scrollObserver: NSKeyValueObservation?

    // store the y positions so we don't have to keep re-calculating

    /**
     The y value for the short form presentation state
     */
    private var shortFormYPosition: CGFloat = 0

    /**
     The y value for the long form presentation state
     */
    private var longFormYPosition: CGFloat = 0

    /**
     Determine anchored Y postion based on the `anchorModalToLongForm` flag
     */
    private var anchoredYPosition: CGFloat {
        let defaultTopOffset = self.presentable?.topOffset ?? 0
        return self.anchorModalToLongForm ? self.longFormYPosition : defaultTopOffset
    }

    /**
     Configuration object for YSPanModalPresentationController
     */
    private var presentable: YSPanModalPresentable? {
        return presentedViewController as? YSPanModalPresentable
    }

    // MARK: - Views

    /**
     Background view used as an overlay over the presenting view
     */
    private lazy var backgroundView: YSDimmedView = {
        let view: YSDimmedView
        if let color = presentable?.panModalBackgroundColor {
            view = YSDimmedView(dimColor: color)
        } else {
            view = YSDimmedView()
        }
        view.didTap = { [weak self] _ in
            if self?.presentable?.allowsTapToDismiss == true {
                self?.presentedViewController.dismiss(animated: true)
            }
        }
        return view
    }()

    /**
     A wrapper around the presented view so that we can modify
     the presented view apperance without changing
     the presented view's properties
     */
    private lazy var panContainerView: YSPanContainerView = {
        let frame = containerView?.frame ?? .zero
        return YSPanContainerView(presentedView: presentedViewController.view, frame: frame)
    }()

    private lazy var dragIndicatorContentView: UIView = {
        let view = UIView()
        view.backgroundColor = presentable?.indicatorBackgroundColor
        return view
    }()
    
    /**
     Drag Indicator View
     */
    private lazy var dragIndicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = presentable?.dragIndicatorBackgroundColor
        view.layer.cornerRadius = Constants.dragIndicatorSize.height / 2.0
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = presentable?.controllerTitle
        label.textColor = UIColor(red: 0.84, green: 0.07, blue: 0.09, alpha: 1.00)
        label.font = .boldSystemFont(ofSize: 17)
        return label
    }()

    /**
     Override presented view to return the pan container wrapper
     */
    override public var presentedView: UIView {
        return self.panContainerView
    }

    // MARK: - Gesture Recognizers

    /**
     Gesture recognizer to detect & track pan gestures
     */
    private lazy var panGestureRecognizer: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(didPanOnPresentedView(_:)))
        gesture.minimumNumberOfTouches = 1
        gesture.maximumNumberOfTouches = 1
        gesture.delegate = self
        return gesture
    }()

    // MARK: - Deinitializers

    deinit {
        scrollObserver?.invalidate()
    }

    // MARK: - Lifecycle

    override public func containerViewWillLayoutSubviews() {
        super.containerViewWillLayoutSubviews()
        configureViewLayout()
    }

    override public func presentationTransitionWillBegin() {
        guard let containerView = containerView
        else { return }

        layoutBackgroundView(in: containerView)
        layoutPresentedView(in: containerView)
        configureScrollViewInsets()

        guard let coordinator = presentedViewController.transitionCoordinator else {
            self.backgroundView.dimState = .max
            return
        }

        coordinator.animate(alongsideTransition: { [weak self] _ in
            self?.backgroundView.dimState = .max
            self?.presentedViewController.setNeedsStatusBarAppearanceUpdate()
        })
    }

    override public func presentationTransitionDidEnd(_ completed: Bool) {
        if completed { return }

        self.backgroundView.removeFromSuperview()
    }

    override public func dismissalTransitionWillBegin() {
        self.presentable?.panModalWillDismiss()

        guard let coordinator = presentedViewController.transitionCoordinator else {
            self.backgroundView.dimState = .off
            return
        }

        /**
         Drag indicator is drawn outside of view bounds
         so hiding it on view dismiss means avoiding visual bugs
         */
        coordinator.animate(alongsideTransition: { [weak self] _ in
            self?.backgroundView.dimState = .off
            self?.presentingViewController.setNeedsStatusBarAppearanceUpdate()
        })
    }

    override public func dismissalTransitionDidEnd(_ completed: Bool) {
        if !completed { return }

        self.presentable?.panModalDidDismiss()
    }

    /**
     Update presented view size in response to size class changes
     */
    override public func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)

        coordinator.animate(alongsideTransition: { [weak self] _ in
            guard let self = self else { return }
            self.adjustPresentedViewFrame()
        })
    }
}

// MARK: - Public Methods

public extension YSPanModalPresentationController {
    /**
     Transition the YSPanModalPresentationController
     to the given presentation state
     */
    func transition(to state: PresentationState, animated: Bool = true) {
        guard self.presentable?.shouldTransition(to: state) == true
        else { return }

        self.presentable?.willTransition(to: state)

        switch state {
        case .shortForm:
            snap(toYPosition: self.shortFormYPosition, animated: animated)
        case .longForm:
            snap(toYPosition: self.longFormYPosition, animated: animated)
        }
    }

    /**
     Updates the YSPanModalPresentationController layout
     based on values in the YSPanModalPresentable

     - Note: This should be called whenever any
     pan modal presentable value changes after the initial presentation
     */
    func setNeedsLayoutUpdate() {
        configureViewLayout()
        adjustPresentedViewFrame()
        observe(scrollView: self.presentable?.panScrollable)
        configureScrollViewInsets()
    }
}

// MARK: - Presented View Layout Configuration

private extension YSPanModalPresentationController {
    /**
     Boolean flag to determine if the presented view is anchored
     */
    var isPresentedViewAnchored: Bool {
        if !self.isPresentedViewAnimating,
           self.extendsPanScrolling,
           self.presentedView.frame.minY.rounded() <= self.anchoredYPosition.rounded()
        {
            return true
        }

        return false
    }

    /**
     Adds the presented view to the given container view
     & configures the view elements such as drag indicator, rounded corners
     based on the pan modal presentable.
     */
    func layoutPresentedView(in containerView: UIView) {

        /**
         ⚠️ If this class is NOT used in conjunction with the PanModalPresentationAnimator
         & YSPanModalPresentable, the presented view should be added to the container view
         in the presentation animator instead of here
         */
        containerView.addSubview(self.presentedView)
        containerView.addGestureRecognizer(self.panGestureRecognizer)

        self.addDragIndicatorContentView(to: self.presentedView)
        
        addDragIndicatorView(to: dragIndicatorContentView)
        addTitleLabel(to: dragIndicatorContentView)

        self.setNeedsLayoutUpdate()
        self.adjustPanContainerBackgroundColor()
    }

    /**
     Reduce height of presentedView so that it sits at the bottom of the screen
     */
    func adjustPresentedViewFrame() {
        guard let frame = containerView?.frame
        else { return }

        let adjustedSize = CGSize(width: frame.size.width, height: frame.size.height - self.anchoredYPosition)
        let panFrame = self.panContainerView.frame
        self.panContainerView.frame.size = frame.size

        if ![self.shortFormYPosition, self.longFormYPosition].contains(panFrame.origin.y) {
            // if the container is already in the correct position, no need to adjust positioning
            // (rotations & size changes cause positioning to be out of sync)
            let yPosition = panFrame.origin.y - panFrame.height + frame.height
            self.presentedView.frame.origin.y = max(yPosition, self.anchoredYPosition)
        }
        self.panContainerView.frame.origin.x = frame.origin.x
        presentedViewController.view.frame = CGRect(origin: .zero, size: adjustedSize)
    }

    /**
     Adds a background color to the pan container view
     in order to avoid a gap at the bottom
     during initial view presentation in longForm (when view bounces)
     */
    func adjustPanContainerBackgroundColor() {
        self.panContainerView.backgroundColor = presentedViewController.view.backgroundColor
            ?? self.presentable?.panScrollable?.backgroundColor
    }

    /**
     Adds the background view to the view hierarchy
     & configures its layout constraints.
     */
    func layoutBackgroundView(in containerView: UIView) {
        containerView.addSubview(self.backgroundView)
        self.backgroundView.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        self.backgroundView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor).isActive = true
        self.backgroundView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor).isActive = true
        self.backgroundView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
    }

    /**
     Adds the drag indicator content view to the view hierarchy
     & configures its layout constraints.
     */
    func addDragIndicatorContentView(to view: UIView) {
        view.addSubview(self.dragIndicatorContentView)
        self.dragIndicatorContentView.translatesAutoresizingMaskIntoConstraints = false
        self.dragIndicatorContentView.bottomAnchor.constraint(equalTo: view.topAnchor, constant: 1.0).isActive = true
        self.dragIndicatorContentView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        self.dragIndicatorContentView.widthAnchor.constraint(equalTo: self.presentedView.widthAnchor).isActive = true
        self.dragIndicatorContentView.heightAnchor.constraint(equalToConstant: Constants.indicatorContentHeight).isActive = true
        self.dragIndicatorContentView.roundCorners(corners: [.topLeft, .topRight], radius: 10.0)
    }
    
    /**
     Adds the drag indicator view to the view hierarchy
     & configures its layout constraints.
     */
    func addDragIndicatorView(to view: UIView) {
        view.addSubview(dragIndicatorView)
        dragIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        dragIndicatorView.topAnchor.constraint(equalTo: view.topAnchor, constant: Constants.indicatorYOffset).isActive = true
        dragIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        dragIndicatorView.widthAnchor.constraint(equalToConstant: Constants.dragIndicatorSize.width).isActive = true
        dragIndicatorView.heightAnchor.constraint(equalToConstant: Constants.dragIndicatorSize.height).isActive = true
    }
    
    /**
     Adds the title label to the view hierarchy
     & configures its layout constraints.
     */
    func addTitleLabel(to view: UIView) {
        view.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.topAnchor.constraint(equalTo: dragIndicatorView.bottomAnchor, constant: 20).isActive = true
        titleLabel.bottomAnchor.constraint(equalTo: dragIndicatorContentView.bottomAnchor).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16).isActive = true
    }

    /**
     Calculates & stores the layout anchor points & options
     */
    func configureViewLayout() {
        guard let layoutPresentable = presentedViewController as? YSPanModalPresentable.LayoutType
        else { return }

        self.shortFormYPosition = layoutPresentable.shortFormYPos
        self.longFormYPosition = layoutPresentable.longFormYPos
        self.anchorModalToLongForm = layoutPresentable.anchorModalToLongForm
        self.extendsPanScrolling = layoutPresentable.allowsExtendedPanScrolling

        containerView?.isUserInteractionEnabled = layoutPresentable.isUserInteractionEnabled
    }

    /**
     Configures the scroll view insets
     */
    func configureScrollViewInsets() {
        guard
            let scrollView = presentable?.panScrollable,
            !scrollView.isScrolling
        else { return }

        /**
         Disable vertical scroll indicator until we start to scroll
         to avoid visual bugs
         */
        scrollView.showsVerticalScrollIndicator = false
        scrollView.scrollIndicatorInsets = self.presentable?.scrollIndicatorInsets ?? .zero

        /**
         Set the appropriate contentInset as the configuration within this class
         offsets it
         */
        scrollView.contentInset.bottom = presentingViewController.bottomLayoutGuide.length

        /**
         As we adjust the bounds during `handleScrollViewTopBounce`
         we should assume that contentInsetAdjustmentBehavior will not be correct
         */
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
    }
}

// MARK: - Pan Gesture Event Handler

private extension YSPanModalPresentationController {
    /**
     The designated function for handling pan gesture events
     */
    @objc func didPanOnPresentedView(_ recognizer: UIPanGestureRecognizer) {
        guard
            self.shouldRespond(to: recognizer),
            let containerView = containerView
        else {
            recognizer.setTranslation(.zero, in: recognizer.view)
            return
        }

        switch recognizer.state {
        case .began, .changed:

            /**
             Respond accordingly to pan gesture translation
             */
            self.respond(to: recognizer)

            /**
             If presentedView is translated above the longForm threshold, treat as transition
             */
            if self.presentedView.frame.origin.y == self.anchoredYPosition, self.extendsPanScrolling {
                self.presentable?.willTransition(to: .longForm)
            }

        default:

            /**
             Use velocity sensitivity value to restrict snapping
             */
            let velocity = recognizer.velocity(in: self.presentedView)

            if self.isVelocityWithinSensitivityRange(velocity.y) {
                /**
                 If velocity is within the sensitivity range,
                 transition to a presentation state or dismiss entirely.

                 This allows the user to dismiss directly from long form
                 instead of going to the short form state first.
                 */
                if velocity.y < 0 {
                    self.transition(to: .longForm)

                } else if (self.nearest(to: self.presentedView.frame.minY, inValues: [self.longFormYPosition, containerView.bounds.height]) == self.longFormYPosition
                    && self.presentedView.frame.minY < self.shortFormYPosition) || self.presentable?.allowsDragToDismiss == false
                {
                    self.transition(to: .shortForm)

                } else {
                    presentedViewController.dismiss(animated: true)
                }

            } else {
                /**
                 The `containerView.bounds.height` is used to determine
                 how close the presented view is to the bottom of the screen
                 */
                let position = self.nearest(to: self.presentedView.frame.minY, inValues: [containerView.bounds.height, self.shortFormYPosition, self.longFormYPosition])

                if position == self.longFormYPosition {
                    self.transition(to: .longForm)

                } else if position == self.shortFormYPosition || self.presentable?.allowsDragToDismiss == false {
                    self.transition(to: .shortForm)

                } else {
                    presentedViewController.dismiss(animated: true)
                }
            }
        }
    }

    /**
     Determine if the pan modal should respond to the gesture recognizer.

     If the pan modal is already being dragged & the delegate returns false, ignore until
     the recognizer is back to it's original state (.began)

     ⚠️ This is the only time we should be cancelling the pan modal gesture recognizer
     */
    func shouldRespond(to panGestureRecognizer: UIPanGestureRecognizer) -> Bool {
        guard
            self.presentable?.shouldRespond(to: panGestureRecognizer) == true ||
            !(panGestureRecognizer.state == .began || panGestureRecognizer.state == .cancelled)
        else {
            panGestureRecognizer.isEnabled = false
            panGestureRecognizer.isEnabled = true
            return false
        }
        return !self.shouldFail(panGestureRecognizer: panGestureRecognizer)
    }

    /**
     Communicate intentions to presentable and adjust subviews in containerView
     */
    func respond(to panGestureRecognizer: UIPanGestureRecognizer) {
        self.presentable?.willRespond(to: panGestureRecognizer)

        var yDisplacement = panGestureRecognizer.translation(in: self.presentedView).y

        /**
         If the presentedView is not anchored to long form, reduce the rate of movement
         above the threshold
         */
        if self.presentedView.frame.origin.y < self.longFormYPosition {
            yDisplacement /= 2.0
        }
        self.adjust(toYPosition: self.presentedView.frame.origin.y + yDisplacement)

        panGestureRecognizer.setTranslation(.zero, in: self.presentedView)
    }

    /**
     Determines if we should fail the gesture recognizer based on certain conditions

     We fail the presented view's pan gesture recognizer if we are actively scrolling on the scroll view.
     This allows the user to drag whole view controller from outside scrollView touch area.

     Unfortunately, cancelling a gestureRecognizer means that we lose the effect of transition scrolling
     from one view to another in the same pan gesture so don't cancel
     */
    func shouldFail(panGestureRecognizer: UIPanGestureRecognizer) -> Bool {
        /**
         Allow api consumers to override the internal conditions &
         decide if the pan gesture recognizer should be prioritized.

         ⚠️ This is the only time we should be cancelling the panScrollable recognizer,
         for the purpose of ensuring we're no longer tracking the scrollView
         */
        guard !self.shouldPrioritize(panGestureRecognizer: panGestureRecognizer) else {
            self.presentable?.panScrollable?.panGestureRecognizer.isEnabled = false
            self.presentable?.panScrollable?.panGestureRecognizer.isEnabled = true
            return false
        }

        guard
            self.isPresentedViewAnchored,
            let scrollView = presentable?.panScrollable,
            scrollView.contentOffset.y > 0
        else {
            return false
        }

        let loc = panGestureRecognizer.location(in: self.presentedView)
        return (scrollView.frame.contains(loc) || scrollView.isScrolling)
    }

    /**
     Determine if the presented view's panGestureRecognizer should be prioritized over
     embedded scrollView's panGestureRecognizer.
     */
    func shouldPrioritize(panGestureRecognizer: UIPanGestureRecognizer) -> Bool {
        return panGestureRecognizer.state == .began &&
            self.presentable?.shouldPrioritize(panModalGestureRecognizer: panGestureRecognizer) == true
    }

    /**
     Check if the given velocity is within the sensitivity range
     */
    func isVelocityWithinSensitivityRange(_ velocity: CGFloat) -> Bool {
        return (abs(velocity) - (1000 * (1 - Constants.snapMovementSensitivity))) > 0
    }

    func snap(toYPosition yPos: CGFloat, animated: Bool = true) {
        if animated {
            YSPanModalAnimator.animate({ [weak self] in
                self?.adjust(toYPosition: yPos)
                self?.isPresentedViewAnimating = true
            }, config: self.presentable) { [weak self] didComplete in
                self?.isPresentedViewAnimating = !didComplete
            }
        } else {
            self.adjust(toYPosition: yPos)
        }
    }

    /**
     Sets the y position of the presentedView & adjusts the backgroundView.
     */
    func adjust(toYPosition yPos: CGFloat) {
        self.presentedView.frame.origin.y = max(yPos, self.anchoredYPosition)

        guard self.presentedView.frame.origin.y > self.shortFormYPosition else {
            self.backgroundView.dimState = .max
            return
        }

        let yDisplacementFromShortForm = self.presentedView.frame.origin.y - self.shortFormYPosition

        /**
         Once presentedView is translated below shortForm, calculate yPos relative to bottom of screen
         and apply percentage to backgroundView alpha
         */
        self.backgroundView.dimState = .percent(1.0 - (yDisplacementFromShortForm / self.presentedView.frame.height))
    }

    /**
     Finds the nearest value to a given number out of a given array of float values

     - Parameters:
     - number: reference float we are trying to find the closest value to
     - values: array of floats we would like to compare against
     */
    func nearest(to number: CGFloat, inValues values: [CGFloat]) -> CGFloat {
        guard let nearestVal = values.min(by: { abs(number - $0) < abs(number - $1) })
        else { return number }
        return nearestVal
    }

    /**
     Allows the current controller to be turned off.
     */
    @objc func closeButtonAction() {
        presentedViewController.dismiss(animated: true)
    }
}

// MARK: - UIScrollView Observer

private extension YSPanModalPresentationController {
    /**
     Creates & stores an observer on the given scroll view's content offset.
     This allows us to track scrolling without overriding the scrollView delegate
     */
    func observe(scrollView: UIScrollView?) {
        self.scrollObserver?.invalidate()
        self.scrollObserver = scrollView?.observe(\.contentOffset, options: .old) { [weak self] scrollView, change in

            /**
             Incase we have a situation where we have two containerViews in the same presentation
             */
            guard self?.containerView != nil
            else { return }

            self?.didPanOnScrollView(scrollView, change: change)
        }
    }

    /**
     Scroll view content offset change event handler

     Also when scrollView is scrolled to the top, we disable the scroll indicator
     otherwise glitchy behaviour occurs

     This is also shown in Apple Maps (reverse engineering)
     which allows us to seamlessly transition scrolling from the YSPanContainerView to the scrollView
     */
    func didPanOnScrollView(_ scrollView: UIScrollView, change: NSKeyValueObservedChange<CGPoint>) {
        guard
            !presentedViewController.isBeingDismissed,
            !presentedViewController.isBeingPresented
        else { return }

        if !self.isPresentedViewAnchored && scrollView.contentOffset.y > 0 {
            /**
             Hold the scrollView in place if we're actively scrolling and not handling top bounce
             */
            self.haltScrolling(scrollView)

        } else if scrollView.isScrolling || self.isPresentedViewAnimating {
            if self.isPresentedViewAnchored {
                /**
                 While we're scrolling upwards on the scrollView,
                 store the last content offset position
                 */
                self.trackScrolling(scrollView)
            } else {
                /**
                 Keep scroll view in place while we're panning on main view
                 */
                self.haltScrolling(scrollView)
            }

        } else if presentedViewController.view.isKind(of: UIScrollView.self),
                  !self.isPresentedViewAnimating, scrollView.contentOffset.y <= 0
        {
            /**
             In the case where we drag down quickly on the scroll view and let go,
             `handleScrollViewTopBounce` adds a nice elegant touch.
             */
            self.handleScrollViewTopBounce(scrollView: scrollView, change: change)
        } else {
            self.trackScrolling(scrollView)
        }
    }

    /**
     Halts the scroll of a given scroll view & anchors it at the `scrollViewYOffset`
     */
    func haltScrolling(_ scrollView: UIScrollView) {
        scrollView.setContentOffset(CGPoint(x: 0, y: self.scrollViewYOffset), animated: false)
        scrollView.showsVerticalScrollIndicator = false
    }

    /**
     As the user scrolls, track & save the scroll view y offset.
     This helps halt scrolling when we want to hold the scroll view in place.
     */
    func trackScrolling(_ scrollView: UIScrollView) {
        self.scrollViewYOffset = max(scrollView.contentOffset.y, 0)
        scrollView.showsVerticalScrollIndicator = true
    }

    /**
     To ensure that the scroll transition between the scrollView & the modal
     is completely seamless, we need to handle the case where content offset is negative.

     In this case, we follow the curve of the decelerating scroll view.
     This gives the effect that the modal view and the scroll view are one view entirely.

     - Note: This works best where the view behind view controller is a UIScrollView.
     So, for example, a UITableViewController.
     */
    func handleScrollViewTopBounce(scrollView: UIScrollView, change: NSKeyValueObservedChange<CGPoint>) {
        guard let oldYValue = change.oldValue?.y, scrollView.isDecelerating
        else { return }

        let yOffset = scrollView.contentOffset.y
        let presentedSize = containerView?.frame.size ?? .zero

        /**
         Decrease the view bounds by the y offset so the scroll view stays in place
         and we can still get updates on its content offset
         */
        self.presentedView.bounds.size = CGSize(width: presentedSize.width, height: presentedSize.height + yOffset)

        if oldYValue > yOffset {
            /**
             Move the view in the opposite direction to the decreasing bounds
             until half way through the deceleration so that it appears
             as if we're transferring the scrollView drag momentum to the entire view
             */
            self.presentedView.frame.origin.y = self.longFormYPosition - yOffset
        } else {
            self.scrollViewYOffset = 0
            self.snap(toYPosition: self.longFormYPosition)
        }

        scrollView.showsVerticalScrollIndicator = false
    }
}

// MARK: - UIGestureRecognizerDelegate

extension YSPanModalPresentationController: UIGestureRecognizerDelegate {
    /**
     Do not require any other gesture recognizers to fail
     */
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }

    /**
     Allow simultaneous gesture recognizers only when the other gesture recognizer's view
     is the pan scrollable view
     */
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return otherGestureRecognizer.view == self.presentable?.panScrollable
    }
}

// MARK: - Helper Extensions

private extension UIScrollView {
    /**
     A flag to determine if a scroll view is scrolling
     */
    var isScrolling: Bool {
        return isDragging && !isDecelerating || isTracking
    }
}

private extension UIView {
    /**
     Sets the edge roundness of views.
     */
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        if #available(iOS 11, *) {
            var masked = CACornerMask()

            self.clipsToBounds = true
            self.layer.cornerRadius = radius

            if corners.contains(.topLeft) { masked.insert(.layerMinXMinYCorner) }
            if corners.contains(.topRight) { masked.insert(.layerMaxXMinYCorner) }
            if corners.contains(.bottomLeft) { masked.insert(.layerMinXMaxYCorner) }
            if corners.contains(.bottomRight) { masked.insert(.layerMaxXMaxYCorner) }

            self.layer.maskedCorners = masked
        } else {
            let cornerRadius = CGSize(width: radius, height: radius)
            let path = UIBezierPath(roundedRect: bounds,
                                    byRoundingCorners: corners,
                                    cornerRadii: cornerRadius)
            let mask = CAShapeLayer()

            mask.path = path.cgPath
            layer.mask = mask
        }
    }
}
