//
//  JAPinCursorAnimator.swift
//  Pods
//
//  Created by Jayachandra Agraharam on 01/04/26.
//

import UIKit

/// Handles the blinking animation of the cursor displayed
/// inside a `JAPinCellView`.
///
/// The animator applies a repeating opacity animation to
/// simulate a native text-input cursor blink behavior.
final class JAPinCursorAnimator {

    /// Weak reference to the cursor view being animated.
    private weak var cursor: UIView?

    /// Creates a cursor animator.
    ///
    /// - Parameter cursor: The cursor view to animate.
    init(cursor: UIView) {
        self.cursor = cursor
    }

    /// Starts the blinking cursor animation.
    ///
    /// Any existing animation is removed before starting
    /// a new one to prevent stacking animations.
    func start() {
        guard let cursor else { return }

        stop()

        let animation = CABasicAnimation(keyPath: "opacity")
        animation.fromValue = 1
        animation.toValue = 0
        animation.duration = 0.7
        animation.autoreverses = true
        animation.repeatCount = .infinity
        animation.timingFunction =
            CAMediaTimingFunction(name: .easeInEaseOut)

        cursor.layer.add(animation, forKey: "blink")
    }

    /// Stops the blinking animation and restores
    /// the cursor to a visible state.
    func stop() {
        cursor?.layer.removeAnimation(forKey: "blink")
        cursor?.layer.opacity = 1
    }
}
