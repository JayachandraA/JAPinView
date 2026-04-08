//
//  JAPinConfiguration.swift
//  Pods
//
//  Created by Jayachandra Agraharam on 01/04/26.
//

import Foundation

/// Defines the visual presentation style used to render
/// PIN input cells inside a `JAPinView`.
///
/// Each style determines how borders, backgrounds,
/// and shapes are applied to individual cells.
/// Custom appearances can be provided using
/// the `.custom` case.
public enum JAPinStyle {

    /// Cells are displayed as bordered rectangular boxes.
    ///
    /// This is the default and most commonly used style.
    case boxed

    /// Cells display only a bottom underline,
    /// similar to minimal OTP input fields.
    case underlined

    /// Cells appear as rounded capsules where
    /// the corner radius equals half the cell height.
    case rounded

    /// Cells use a filled background instead of borders.
    ///
    /// Background color changes based on cell state.
    case filled

    /// Allows a fully custom cell appearance.
    ///
    /// Provide an implementation conforming to
    /// `JAPinCellStyle` to control rendering and
    /// state transitions manually.
    ///
    /// - Parameter JAPinCellStyle: Custom styling implementation.
    case custom(JAPinCellStyle)
}
