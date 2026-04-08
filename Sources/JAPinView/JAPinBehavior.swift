//
//  JAPinConfiguration.swift
//  Pods
//
//  Created by Jayachandra Agraharam on 01/04/26.
//

import UIKit

/// Defines behavioral configuration for JAPinView.
/// Controls keyboard behavior, security options, autofill,
/// focus handling, and user interaction rules.
public struct JAPinBehavior {

    /// Keyboard type presented when editing begins.
    public var keyboardType: UIKeyboardType

    /// Determines whether entered digits are hidden.
    public var isSecureEntry: Bool

    /// Symbol displayed when secure entry is enabled.
    public var secureSymbol: String

    /// Automatically focuses the PIN view when it appears.
    public var autoFocus: Bool

    /// Automatically triggers completion when all digits are entered.
    public var autoSubmit: Bool

    /// Allows pasting a PIN from clipboard.
    public var allowsPaste: Bool

    /// Enables iOS One-Time-Code AutoFill support.
    public var enablesAutoFill: Bool

    /// Moves focus backward when delete is pressed on an empty field.
    public var deleteBackwardMovesFocus: Bool

    /// Creates a new behavior configuration.
    ///
    /// - Parameters:
    ///   - keyboardType: Keyboard type used for input.
    ///   - isSecureEntry: Enables secure digit masking.
    ///   - secureSymbol: Mask symbol shown when secure entry is enabled.
    ///   - autoFocus: Automatically focuses on appearance.
    ///   - autoSubmit: Automatically completes after last digit.
    ///   - allowsPaste: Enables clipboard paste support.
    ///   - enablesAutoFill: Enables OTP AutoFill suggestions.
    ///   - deleteBackwardMovesFocus: Moves cursor backward on delete.
    public init(
        keyboardType: UIKeyboardType,
        isSecureEntry: Bool,
        secureSymbol: String,
        autoFocus: Bool,
        autoSubmit: Bool,
        allowsPaste: Bool,
        enablesAutoFill: Bool,
        deleteBackwardMovesFocus: Bool
    ) {
        self.keyboardType = keyboardType
        self.isSecureEntry = isSecureEntry
        self.secureSymbol = secureSymbol
        self.autoFocus = autoFocus
        self.autoSubmit = autoSubmit
        self.allowsPaste = allowsPaste
        self.enablesAutoFill = enablesAutoFill
        self.deleteBackwardMovesFocus = deleteBackwardMovesFocus
    }
}

public extension JAPinBehavior {

    /// Default behavior configuration used by JAPinView.
    static let `default` = JAPinBehavior(
        keyboardType: .numberPad,
        isSecureEntry: false,
        secureSymbol: "•",
        autoFocus: true,
        autoSubmit: true,
        allowsPaste: true,
        enablesAutoFill: true,
        deleteBackwardMovesFocus: true
    )
}
