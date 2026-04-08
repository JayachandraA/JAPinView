//
//  JAPinAnimator.swift
//
//  Responsible for executing animations defined by `JAPinAnimationType`.
//  Provides a centralized animation dispatcher used by JAPin components.
//

import UIKit

/// Animation executor used by `JAPinView` and `JAPinCellView`.
///
/// `JAPinAnimator` maps high-level animation configurations
/// (`JAPinAnimationType`) to concrete UIKit animations.
/// This ensures animation behavior is fully configuration-driven.
enum JAPinAnimator {

    /// Dispatches the configured animation onto a view.
    ///
    /// This method should be used instead of calling animation
    /// implementations directly, allowing animation behavior
    /// to be controlled entirely via configuration.
    ///
    /// - Parameters:
    ///   - type: The animation type to perform.
    ///   - view: The target view receiving the animation.
    static func animate(_ type: JAPinAnimationType, on view: UIView) {
        switch type {
        case .none:
            break
        case .scale:
            focus(view)
        case .bounce:
            entry(view)
        case .fade:
            fade(view)
        case .shake:
            error(view)
        }
    }

    // MARK: - Concrete Animations

    /// Performs a spring-based scale animation used
    /// when a PIN cell gains focus.
    ///
    /// The view briefly shrinks and springs back to
    /// its original size to emphasize interaction.
    ///
    /// - Parameter view: The view to animate.
    static func focus(_ view: UIView) {
        view.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)

        UIView.animate(
            withDuration: 0.25,
            delay: 0,
            usingSpringWithDamping: 0.6,
            initialSpringVelocity: 3
        ) {
            view.transform = .identity
        }
    }

    /// Performs a bounce animation used when text
    /// is entered into a PIN cell.
    ///
    /// The cell briefly enlarges and returns to normal,
    /// providing tactile visual feedback.
    ///
    /// - Parameter view: The view to animate.
    static func entry(_ view: UIView) {
        UIView.animate(withDuration: 0.15, animations: {
            view.transform = CGAffineTransform(scaleX: 1.15, y: 1.15)
        }) { _ in
            UIView.animate(withDuration: 0.15) {
                view.transform = .identity
            }
        }
    }

    /// Performs a horizontal shake animation used
    /// to indicate validation errors.
    ///
    /// This animation mimics common PIN/password
    /// error feedback patterns.
    ///
    /// - Parameter view: The view to animate.
    static func error(_ view: UIView) {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.values = [-12, 12, -8, 8, -4, 4, 0]
        animation.duration = 0.4
        view.layer.add(animation, forKey: "shake")
    }

    /// Performs a fade-in animation.
    ///
    /// Can be used as an alternative focus or entry animation
    /// depending on configuration.
    ///
    /// - Parameter view: The view to animate.
    static func fade(_ view: UIView) {
        view.alpha = 0

        UIView.animate(withDuration: 0.2) {
            view.alpha = 1
        }
    }
}
