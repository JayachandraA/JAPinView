//
//  JAPinConfiguration.swift
//  Pods
//
//  Created by Jayachandra Agraharam on 01/04/26.
//

import Foundation

/// Accessibility configuration for `JAPinView`.
///
/// Defines how the PIN input behaves for VoiceOver and
/// other accessibility services.
public struct JAPinAccessibility {

    /// Indicates whether an accessibility announcement
    /// should be spoken when PIN entry is completed.
    ///
    /// When enabled, VoiceOver announces completion once
    /// all digits are entered.
    public var announcesCompletion: Bool

    /// Format string used to describe each digit position
    /// for accessibility users.
    ///
    /// The format must support two integer placeholders:
    ///
    /// - First `%d` → Current digit index
    /// - Second `%d` → Total PIN length
    ///
    /// Example:
    /// `"Digit %d of %d"` → "Digit 2 of 6"
    public var digitLabelFormat: String

    /// Creates a new accessibility configuration.
    ///
    /// - Parameters:
    ///   - announcesCompletion: Whether completion should be announced.
    ///   - digitLabelFormat: Accessibility label format for digits.
    public init(
        announcesCompletion: Bool,
        digitLabelFormat: String
    ) {
        self.announcesCompletion = announcesCompletion
        self.digitLabelFormat = digitLabelFormat
    }
}

/// Default accessibility configuration.
public extension JAPinAccessibility {

    /// Standard accessibility behavior used by `JAPinView`.
    ///
    /// Includes:
    /// - Completion announcement enabled
    /// - Default digit labeling format
    static let `default` = JAPinAccessibility(
        announcesCompletion: true,
        digitLabelFormat: "Digit %d of %d"
    )
}
