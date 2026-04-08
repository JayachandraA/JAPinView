//
//  JAPinConfiguration.swift
//  Pods
//
//  Created by Jayachandra Agraharam on 01/04/26.
//

import Foundation

/// Defines animation behaviors used by `JAPinView`.
///
/// This configuration controls which animation is applied
/// during different interaction states such as focus,
/// text entry, and error feedback.
public struct JAPinAnimation {

    /// Animation applied when a PIN cell becomes focused.
    public var focus: JAPinAnimationType

    /// Animation applied when a character is entered.
    public var textEntry: JAPinAnimationType

    /// Animation applied when an error occurs.
    public var error: JAPinAnimationType

    /// Creates a new animation configuration.
    ///
    /// - Parameters:
    ///   - focus: Animation used for focus transitions.
    ///   - textEntry: Animation used when text is entered.
    ///   - error: Animation used for error indication.
    public init(
        focus: JAPinAnimationType,
        textEntry: JAPinAnimationType,
        error: JAPinAnimationType
    ) {
        self.focus = focus
        self.textEntry = textEntry
        self.error = error
    }
}

/// Supported animation types for PIN cell transitions.
///
/// These animations are executed by `JAPinAnimator`
/// depending on user interaction state.
public enum JAPinAnimationType {

    /// No animation is performed.
    case none

    /// Scales the cell slightly to emphasize focus.
    case scale

    /// Applies a spring/bounce effect during entry.
    case bounce

    /// Fades the element in or out.
    case fade

    /// Performs a horizontal shake to indicate error.
    case shake
}

/// Default animation configuration used by `JAPinView`.
public extension JAPinAnimation {

    /// Standard animation preset.
    ///
    /// Includes:
    /// - Scale animation on focus
    /// - Bounce animation on text entry
    /// - Shake animation on error
    static let `default` = JAPinAnimation(
        focus: .scale,
        textEntry: .bounce,
        error: .shake
    )
}
