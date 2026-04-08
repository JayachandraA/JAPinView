//
//  JAPinConfiguration.swift
//  Pods
//
//  Created by Jayachandra Agraharam on 01/04/26.
//

import UIKit

/// Defines the visual theme applied to a `JAPinView`.
///
/// `JAPinTheme` controls colors, typography, and structural
/// styling shared across all PIN cells. Unlike `JAPinAppearance`,
/// which focuses on layout and spacing, the theme primarily
/// manages visual branding and state-based colors.
public struct JAPinTheme {

    /// Background color applied to cells when using styles
    /// that support filled backgrounds.
    public var backgroundColor: UIColor = .clear

    /// Default text color used for entered digits.
    public var textColor: UIColor = .label

    /// Border color when a cell is empty.
    public var emptyBorderColor: UIColor = .systemGray4

    /// Border color when a cell is focused.
    public var focusedBorderColor: UIColor = .systemBlue

    /// Border color when a cell contains a value.
    public var filledBorderColor: UIColor = .label

    /// Border color used during error states.
    public var errorBorderColor: UIColor = .systemRed

    /// Color of the blinking cursor.
    public var cursorColor: UIColor = .systemBlue

    /// Font used to render PIN digits.
    ///
    /// Defaults to a monospaced digit font for consistent alignment.
    public var font: UIFont = .monospacedDigitSystemFont(
        ofSize: 22,
        weight: .medium
    )

    /// Corner radius applied to supported cell styles.
    public var cornerRadius: CGFloat = 10

    /// Border width applied to bordered styles.
    public var borderWidth: CGFloat = 1

    /// Creates a theme using default values.
    public init() {}
}
