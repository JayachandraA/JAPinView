//
//  JAPinCellStyle.swift
//
//  - Original protocol preserved
//  - Added concrete built-in implementations for all JAPinStyle cases,
//    giving developers ready-made styles they can reuse or extend.
//

import UIKit

// MARK: - Protocol

/// Defines a customizable appearance provider for individual JAPin cells.
///
/// Implement this protocol to fully control how a cell looks
/// for each interaction state.
///
/// Assign your implementation using:
///
/// `JAPinStyle.custom(yourStyle)`
public protocol JAPinCellStyle {

    /// Applies visual styling to a cell view based on its state.
    ///
    /// - Parameters:
    ///   - view: The cell container view.
    ///   - state: Current state of the cell.
    func apply(to view: UIView, state: JAPinCellState)
}

// MARK: - Built-in concrete styles

/// A boxed style that renders cells as bordered rounded rectangles.
/// This is the default JAPin cell appearance.
public struct JAPinBoxedCellStyle: JAPinCellStyle {

    /// Width of the cell border.
    public var borderWidth: CGFloat

    /// Corner radius of the cell.
    public var cornerRadius: CGFloat

    /// Border color when the cell is empty.
    public var emptyColor: UIColor

    /// Border color when the cell is focused.
    public var focusedColor: UIColor

    /// Border color when the cell is filled.
    public var filledColor: UIColor

    /// Border color when the cell is in error state.
    public var errorColor: UIColor

    /// Creates a boxed cell style.
    ///
    /// - Parameters:
    ///   - borderWidth: Width of the border.
    ///   - cornerRadius: Corner radius of the cell.
    ///   - emptyColor: Color used for empty state.
    ///   - focusedColor: Color used for focused state.
    ///   - filledColor: Color used for filled state.
    ///   - errorColor: Color used for error state.
    public init(
        borderWidth: CGFloat = 1.5,
        cornerRadius: CGFloat = 8,
        emptyColor: UIColor = .systemGray4,
        focusedColor: UIColor = .systemBlue,
        filledColor: UIColor = .label,
        errorColor: UIColor = .systemRed
    ) {
        self.borderWidth = borderWidth
        self.cornerRadius = cornerRadius
        self.emptyColor = emptyColor
        self.focusedColor = focusedColor
        self.filledColor = filledColor
        self.errorColor = errorColor
    }

    /// Applies boxed styling to the cell.
    public func apply(to view: UIView, state: JAPinCellState) {
        view.layer.borderWidth = borderWidth
        view.layer.cornerRadius = cornerRadius
        view.layer.borderColor = color(for: state).cgColor
        view.alpha = state == .disabled ? 0.5 : 1
    }

    /// Resolves the appropriate color for a given state.
    private func color(for state: JAPinCellState) -> UIColor {
        switch state {
        case .focused:           return focusedColor
        case .filled:            return filledColor
        case .error:             return errorColor
        case .empty, .disabled:  return emptyColor
        }
    }
}

/// An underlined style that renders cells using only a bottom line.
/// Commonly used for OTP or minimal PIN UI designs.
public struct JAPinUnderlinedCellStyle: JAPinCellStyle {

    /// Height of the underline.
    public var lineHeight: CGFloat

    /// Line color when empty.
    public var emptyColor: UIColor

    /// Line color when focused.
    public var focusedColor: UIColor

    /// Line color when filled.
    public var filledColor: UIColor

    /// Line color when in error state.
    public var errorColor: UIColor

    /// Internal identifier used to reuse the underline layer.
    private let lineLayerKey = "underline"

    /// Creates an underlined cell style.
    ///
    /// - Parameters:
    ///   - lineHeight: Thickness of the underline.
    ///   - emptyColor: Color used for empty state.
    ///   - focusedColor: Color used for focused state.
    ///   - filledColor: Color used for filled state.
    ///   - errorColor: Color used for error state.
    public init(
        lineHeight: CGFloat = 2,
        emptyColor: UIColor = .systemGray4,
        focusedColor: UIColor = .systemBlue,
        filledColor: UIColor = .label,
        errorColor: UIColor = .systemRed
    ) {
        self.lineHeight = lineHeight
        self.emptyColor = emptyColor
        self.focusedColor = focusedColor
        self.filledColor = filledColor
        self.errorColor = errorColor
    }

    /// Applies underline styling to the cell.
    public func apply(to view: UIView, state: JAPinCellState) {
        view.layer.borderWidth = 0
        view.layer.cornerRadius = 0
        view.alpha = state == .disabled ? 0.5 : 1

        /// Reuse or create underline layer.
        let lineLayer: CALayer
        if let existing = view.layer.sublayers?.first(where: { $0.name == lineLayerKey }) {
            lineLayer = existing
        } else {
            lineLayer = CALayer()
            lineLayer.name = lineLayerKey
            view.layer.addSublayer(lineLayer)
        }

        lineLayer.frame = CGRect(
            x: 0,
            y: view.bounds.height - lineHeight,
            width: view.bounds.width,
            height: lineHeight
        )
        lineLayer.backgroundColor = color(for: state).cgColor
    }

    /// Resolves the appropriate underline color for a given state.
    private func color(for state: JAPinCellState) -> UIColor {
        switch state {
        case .focused:           return focusedColor
        case .filled:            return filledColor
        case .error:             return errorColor
        case .empty, .disabled:  return emptyColor
        }
    }
}
