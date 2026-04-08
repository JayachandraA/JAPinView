//
//  JAPinConfiguration.swift
//  Pods
//
//  Created by Jayachandra Agraharam on 01/04/26.
//

import Foundation

/// Represents the overall interaction state of a `JAPinView`.
///
/// Unlike `JAPinCellState`, which describes individual cell states,
/// `JAPinState` reflects the global state of the entire PIN input.
public enum JAPinState {

    /// The PIN view is inactive and waiting for user interaction.
    case idle

    /// The user is actively entering or editing the PIN.
    case editing

    /// All required digits have been entered successfully.
    case filled

    /// The PIN view is displaying an error state.
    case error
}
