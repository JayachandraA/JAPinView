//
//  JAPinConfiguration.swift
//  Pods
//
//  Created by Jayachandra Agraharam on 01/04/26.
//

import Foundation

/// The central configuration object used to customize a `JAPinView`.
///
/// `JAPinConfiguration` combines styling, behavior, animation,
/// accessibility, and theming into a single structure.
/// Provide this during initialization to fully control
/// the appearance and interaction model of the PIN input view.
public struct JAPinConfiguration {

    /// Number of digits required for the PIN.
    public var pinLength: Int

    /// Visual style used to render PIN cells.
    public var style: JAPinStyle

    /// Appearance configuration such as fonts, colors, and spacing.
    public var appearance: JAPinAppearance

    /// Behavioral configuration including keyboard and autofill options.
    public var behavior: JAPinBehavior

    /// Animation configuration for focus, entry, and error transitions.
    public var animation: JAPinAnimation

    /// Accessibility configuration for VoiceOver and announcements.
    public var accessibility: JAPinAccessibility

    /// Theme configuration controlling shared visual tokens.
    ///
    /// Defaults to a new `JAPinTheme` instance.
    public var theme: JAPinTheme = .init()

    /// Creates a new PIN configuration.
    ///
    /// - Parameters:
    ///   - pinLength: Number of digits required.
    ///   - style: Cell rendering style.
    ///   - appearance: Appearance configuration.
    ///   - behavior: Interaction behavior configuration.
    ///   - animation: Animation configuration.
    ///   - accessibility: Accessibility configuration.
    public init(
        pinLength: Int,
        style: JAPinStyle,
        appearance: JAPinAppearance,
        behavior: JAPinBehavior,
        animation: JAPinAnimation,
        accessibility: JAPinAccessibility
    ) {
        self.pinLength = pinLength
        self.style = style
        self.appearance = appearance
        self.behavior = behavior
        self.animation = animation
        self.accessibility = accessibility
    }
}

// MARK: - Defaults

public extension JAPinConfiguration {

    /// Default configuration used when no customization is provided.
    ///
    /// Includes:
    /// - 4-digit PIN
    /// - Boxed style
    /// - Default appearance, behavior, animation, and accessibility settings
    static let `default`: JAPinConfiguration = {
        JAPinConfiguration(
            pinLength: 4,
            style: .boxed,
            appearance: .default,
            behavior: .default,
            animation: .default,
            accessibility: .default
        )
    }()
}
