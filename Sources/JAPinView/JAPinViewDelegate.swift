//
//  JAPinConfiguration.swift
//  Pods
//
//  Created by Jayachandra Agraharam on 01/04/26.
//

import Foundation

/// Delegate methods that notify about user interaction
/// and lifecycle events of a `JAPinView`.
///
/// Implement this protocol to observe PIN entry progress,
/// respond to completion, or react to editing state changes.
public protocol JAPinViewDelegate: AnyObject {

    /// Called when the PIN view becomes active and editing begins.
    ///
    /// - Parameter pinView: The PIN view that started editing.
    func pinViewDidBeginEditing(_ pinView: JAPinView)

    /// Called whenever the entered PIN text changes.
    ///
    /// - Parameters:
    ///   - pinView: The PIN view whose text changed.
    ///   - text: The current PIN value.
    func pinView(
        _ pinView: JAPinView,
        didChangeText text: String
    )

    /// Called when the user finishes entering all required digits.
    ///
    /// Triggered when the entered text length matches
    /// the configured `pinLength`.
    ///
    /// - Parameters:
    ///   - pinView: The PIN view that completed input.
    ///   - text: The completed PIN value.
    func pinView(
        _ pinView: JAPinView,
        didComplete text: String
    )

    /// Called when editing ends and the PIN view resigns first responder.
    ///
    /// - Parameter pinView: The PIN view that ended editing.
    func pinViewDidEndEditing(_ pinView: JAPinView)
}
