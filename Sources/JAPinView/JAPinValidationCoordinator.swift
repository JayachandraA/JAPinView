//
//  JAPinConfiguration.swift
//  Pods
//
//  Created by Jayachandra Agraharam on 01/04/26.
//

import UIKit

/// Coordinates asynchronous PIN validation for a `JAPinView`.
///
/// `JAPinValidationCoordinator` acts as an intermediary between
/// the PIN input UI and a developer-provided validation handler.
/// It manages loading state transitions and ensures UI updates
/// occur on the main thread.
final class JAPinValidationCoordinator {

    /// Async validation closure provided by the host application.
    ///
    /// The closure receives the entered PIN string and returns
    /// a Boolean indicating whether validation succeeded.
    var validator: ((String) async -> Bool)?

    /// Weak reference to the associated PIN view.
    ///
    /// Stored weakly to avoid retain cycles between the
    /// coordinator and the view.
    weak var pinView: JAPinView?

    /// Creates a validation coordinator for a specific PIN view.
    ///
    /// - Parameter pinView: The `JAPinView` that owns this coordinator.
    init(pinView: JAPinView) {
        self.pinView = pinView
    }

    /// Executes validation for the provided PIN code.
    ///
    /// This method:
    /// 1. Activates loading state
    /// 2. Awaits async validation
    /// 3. Updates UI based on the result
    ///
    /// - Parameter code: The entered PIN value.
    func validate(_ code: String) {

        guard let validator else { return }

        Task { @MainActor in

            pinView?.setLoading(true)

            let success = await validator(code)

            pinView?.setLoading(false)

            if success {
                pinView?.validationSucceeded()
            } else {
                pinView?.validationFailed()
            }
        }
    }
}
