//
//  JAPinConfiguration.swift
//  Pods
//
//  Created by Jayachandra Agraharam on 01/04/26.
//

import UIKit

/// Defines visual appearance configuration for JAPinView.
/// Controls typography, colors, spacing, borders, and cursor styling.
public struct JAPinAppearance {

    /// Font used to display PIN digits.
    public var font: UIFont

    /// Text color of entered digits.
    public var textColor: UIColor

    /// Border color when the field is active (focused).
    public var activeBorderColor: UIColor

    /// Border color when the field is inactive.
    public var inactiveBorderColor: UIColor

    /// Border color shown during error state.
    public var errorBorderColor: UIColor

    /// Background color of each PIN box.
    public var backgroundColor: UIColor

    /// Corner radius applied to PIN boxes.
    public var cornerRadius: CGFloat

    /// Color of the blinking cursor indicator.
    public var cursorColor: UIColor

    /// Width of the cursor indicator.
    public var cursorWidth: CGFloat

    /// Spacing between PIN boxes.
    public var spacing: CGFloat

    /// Creates a new appearance configuration.
    ///
    /// - Parameters:
    ///   - font: Font used for digits.
    ///   - textColor: Digit text color.
    ///   - activeBorderColor: Border color when focused.
    ///   - inactiveBorderColor: Border color when not focused.
    ///   - errorBorderColor: Border color during error state.
    ///   - backgroundColor: Background color of boxes.
    ///   - cornerRadius: Corner radius of boxes.
    ///   - cursorColor: Cursor color.
    ///   - cursorWidth: Cursor thickness.
    ///   - spacing: Space between boxes.
    public init(
        font: UIFont,
        textColor: UIColor,
        activeBorderColor: UIColor,
        inactiveBorderColor: UIColor,
        errorBorderColor: UIColor,
        backgroundColor: UIColor,
        cornerRadius: CGFloat,
        cursorColor: UIColor,
        cursorWidth: CGFloat,
        spacing: CGFloat
    ) {
        self.font = font
        self.textColor = textColor
        self.activeBorderColor = activeBorderColor
        self.inactiveBorderColor = inactiveBorderColor
        self.errorBorderColor = errorBorderColor
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
        self.cursorColor = cursorColor
        self.cursorWidth = cursorWidth
        self.spacing = spacing
    }
}

public extension JAPinAppearance {

    /// Default appearance used by JAPinView.
    static let `default` = JAPinAppearance(
        font: .systemFont(ofSize: 20, weight: .medium),
        textColor: .label,
        activeBorderColor: .systemBlue,
        inactiveBorderColor: .systemGray4,
        errorBorderColor: .systemRed,
        backgroundColor: .clear,
        cornerRadius: 8,
        cursorColor: .systemBlue,
        cursorWidth: 2,
        spacing: 12
    )
}
