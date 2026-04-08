//
//  JAPinConfiguration.swift
//  Pods
//
//  Created by Jayachandra Agraharam on 01/04/26.
//

import Foundation

/// Represents the visual and interaction state of a single JAPin cell.
/// Used internally to determine styling, animations, and behavior updates.
public enum JAPinCellState: Equatable {

    /// The cell contains no value.
    case empty

    /// The cell contains an entered digit.
    case filled

    /// The cell is currently focused and ready for input.
    case focused

    /// The cell is displaying an error state.
    case error

    /// The cell is disabled and does not accept interaction.
    case disabled
}
