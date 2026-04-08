# JAPinView

A lightweight, fully configurable PIN / OTP entry view for iOS, written in Swift.  
Drop it in, set a configuration, and get a production-ready input field with animations, theming, async validation, and full VoiceOver support — in minutes.

---

## Table of Contents

- [Features](#features)
- [Screenshots](#screenshots)
- [Requirements](#requirements)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Configuration](#configuration)
  - [JAPinConfiguration](#japinconfiguration)
  - [JAPinStyle](#japinstyle)
  - [JAPinTheme](#japintheme)
  - [JAPinAppearance](#japinappearance)
  - [JAPinBehavior](#japinbehavior)
  - [JAPinAnimation](#japinanimation)
  - [JAPinAccessibility](#japinaccessibility)
- [Public API](#public-api)
  - [Properties](#properties)
  - [Methods](#methods)
  - [Closures](#closures)
  - [Async Validation](#async-validation)
- [Delegate](#delegate)
- [Custom Cell Style](#custom-cell-style)
- [Styles Reference](#styles-reference)
- [Animation Types](#animation-types)
- [Cell States](#cell-states)
- [Examples](#examples)
  - [Basic OTP](#basic-otp)
  - [Banking PIN](#banking-pin)
  - [Theming Demo](#theming-demo)
  - [Validation Demo](#validation-demo)
  - [Accessibility Demo](#accessibility-demo)
- [File Structure](#file-structure)
- [Accessibility](#accessibility)
- [License](#license)

---

## Features

- **5 built-in styles** — Boxed, Underlined, Rounded, Filled, and fully Custom
- **Per-state theming** — independent colours for empty, focused, filled, error, and disabled states
- **Async validation** — attach a `(String) async -> Bool` closure; the view handles loading state, success, and failure automatically
- **Configurable animations** — choose independently for focus, text entry, and error events from `none`, `scale`, `bounce`, `fade`, or `shake`
- **Blinking cursor** — appears on the active cell with a smooth `CABasicAnimation` blink
- **Secure entry** — masks digits with any symbol (default `•`)
- **SMS AutoFill** — set `textContentType = .oneTimeCode` via a single flag
- **Paste control** — allow or block paste per use-case
- **Attempt limiting & disabled state** — set `isDisabled = true` to lock the entire field
- **Full VoiceOver support** — per-cell accessibility labels, live region announcements, completion announcements
- **Dynamic Type** — fonts scale with the user's preferred text size
- **Reduce Motion aware** — animations switch off or simplify automatically
- **Delegate + closure APIs** — use whichever fits your architecture
- **Zero dependencies** — pure UIKit, no third-party packages

---

## Screenshots

| Basic OTP | Banking PIN | Theming Demo |
|:---------:|:-----------:|:------------:|
| ![Basic OTP](https://raw.githubusercontent.com/JayachandraA/JAPinView/master/Example/example1.png) | ![Banking PIN](https://raw.githubusercontent.com/JayachandraA/JAPinView/master/Example/example2.png) | ![Theming Demo](https://raw.githubusercontent.com/JayachandraA/JAPinView/master/Example/example3.png) |

| Validation Demo | Accessibility Demo |
|:---------------:|:-----------------:|
| ![Validation Demo](https://raw.githubusercontent.com/JayachandraA/JAPinView/master/Example/example4.png) | ![Accessibility Demo](https://raw.githubusercontent.com/JayachandraA/JAPinView/master/Example/example5.png) |

---

## Requirements

| Requirement | Minimum |
|---|---|
| iOS | 15.0 |
| Swift | 5.7 |
| Xcode | 14.0 |

---

## Installation

### Swift Package Manager

Add the following to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/jayachandra-agraharam/JAPinView.git", from: "1.0.0")
]
```

Or in Xcode: **File → Add Package Dependencies** and paste the repository URL.

### CocoaPods

```ruby
pod 'JAPinView'
```

### Manual

Copy all `.swift` files from the `JAPinView/` folder directly into your project. No bridging header needed.

---

## Quick Start

```swift
import UIKit

class ViewController: UIViewController {

    private let pinView = JAPinView()

    override func viewDidLoad() {
        super.viewDidLoad()

        pinView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pinView)

        NSLayoutConstraint.activate([
            pinView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pinView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            pinView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            pinView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            pinView.heightAnchor.constraint(equalToConstant: 56)
        ])

        pinView.onComplete = { pin in
            print("Entered PIN:", pin)
        }
    }
}
```

That's it. The view uses `.default` configuration: 4-digit boxed style, number pad keyboard, autoFocus on, SMS autofill on.

---

## Configuration

All behaviour is controlled through a single `JAPinConfiguration` struct that you build once and assign to `pinView.configuration`. Updating `configuration` at runtime rebuilds the view automatically.

### JAPinConfiguration

```swift
public struct JAPinConfiguration {
    public var pinLength:    Int               // Number of cells (default: 4)
    public var style:        JAPinStyle        // Visual style of each cell
    public var appearance:   JAPinAppearance   // Fonts, colours, sizing
    public var behavior:     JAPinBehavior     // Keyboard, paste, secure entry
    public var animation:    JAPinAnimation    // Per-event animation types
    public var accessibility: JAPinAccessibility
    public var theme:        JAPinTheme        // Per-state border/cursor colours
}
```

**Default configuration:**

```swift
let pinView = JAPinView(configuration: .default)
// pinLength: 4, style: .boxed, all sub-configs use .default
```

---

### JAPinStyle

Controls the shape and border rendering of each cell.

```swift
public enum JAPinStyle {
    case boxed        // Solid border rectangle (default)
    case underlined   // Bottom line only — common in banking/fintech UIs
    case rounded      // Full pill shape (cornerRadius = height / 2)
    case filled       // No border; background colour changes per state
    case custom(JAPinCellStyle)  // Provide your own renderer
}
```

**Usage:**

```swift
var config = JAPinConfiguration.default
config.style = .underlined
pinView.configuration = config
```

---

### JAPinTheme

Fine-grained colour control for each cell state. Takes precedence over the colours in `JAPinAppearance`.

```swift
public struct JAPinTheme {
    public var backgroundColor:   UIColor   // Cell fill (used by .filled style)
    public var textColor:         UIColor
    public var emptyBorderColor:  UIColor   // Cell with no digit
    public var focusedBorderColor: UIColor  // Active / cursor cell
    public var filledBorderColor: UIColor   // Cell that has a digit
    public var errorBorderColor:  UIColor   // Error state
    public var cursorColor:       UIColor
    public var font:              UIFont
    public var cornerRadius:      CGFloat
    public var borderWidth:       CGFloat
}
```

**Usage:**

```swift
var config = JAPinConfiguration.default
config.theme.focusedBorderColor = .systemPurple
config.theme.filledBorderColor  = .systemPurple
config.theme.cursorColor        = .systemPurple
pinView.configuration = config
```

---

### JAPinAppearance

Controls sizing, spacing, and fallback colours (overridden by `JAPinTheme` where applicable).

```swift
public struct JAPinAppearance {
    public var font:                 UIFont
    public var textColor:            UIColor
    public var activeBorderColor:    UIColor
    public var inactiveBorderColor:  UIColor
    public var errorBorderColor:     UIColor
    public var backgroundColor:      UIColor
    public var cornerRadius:         CGFloat
    public var cursorColor:          UIColor
    public var cursorWidth:          CGFloat   // Width of the blinking cursor bar
    public var spacing:              CGFloat   // Gap between cells
}
```

**Usage:**

```swift
var appearance = JAPinAppearance.default
appearance.font         = .monospacedDigitSystemFont(ofSize: 28, weight: .bold)
appearance.spacing      = 20
appearance.cornerRadius = 12
appearance.cursorWidth  = 3

var config = JAPinConfiguration.default
config.appearance = appearance
```

---

### JAPinBehavior

Controls keyboard type, security, autofill, paste, and navigation.

```swift
public struct JAPinBehavior {
    public var keyboardType:             UIKeyboardType  // Default: .numberPad
    public var isSecureEntry:            Bool            // Mask digits with secureSymbol
    public var secureSymbol:             String          // Default: "•"
    public var autoFocus:                Bool            // Become first responder on appear
    public var autoSubmit:               Bool            // Trigger completion when full
    public var allowsPaste:              Bool            // Allow paste into the field
    public var enablesAutoFill:          Bool            // SMS OTP autofill (textContentType)
    public var deleteBackwardMovesFocus: Bool            // Backspace clears last digit
}
```

**Usage — secure banking PIN:**

```swift
var behavior = JAPinBehavior.default
behavior.isSecureEntry   = true
behavior.secureSymbol    = "●"
behavior.allowsPaste     = false   // Never allow paste for PINs
behavior.enablesAutoFill = false   // No SMS autofill for PINs

var config = JAPinConfiguration.default
config.behavior = behavior
```

**Usage — SMS OTP:**

```swift
var behavior = JAPinBehavior.default
behavior.enablesAutoFill = true    // Adds textContentType = .oneTimeCode
behavior.allowsPaste     = true
behavior.isSecureEntry   = false

var config = JAPinConfiguration.default
config.pinLength = 6
config.behavior  = behavior
```

---

### JAPinAnimation

Choose the animation played for each of the three trigger events independently.

```swift
public struct JAPinAnimation {
    public var focus:     JAPinAnimationType  // When a cell becomes active
    public var textEntry: JAPinAnimationType  // When a digit is typed
    public var error:     JAPinAnimationType  // When validation fails
}

public enum JAPinAnimationType {
    case none     // No animation
    case scale    // Spring-scale pop (shrink then spring back)
    case bounce   // Overshoot scale (grow then settle)
    case fade     // Fade in from alpha 0
    case shake    // Horizontal keyframe shake
}
```

**Usage:**

```swift
var config = JAPinConfiguration.default
config.animation = JAPinAnimation(
    focus:     .scale,
    textEntry: .bounce,
    error:     .shake
)

// Disable all animation (e.g. respecting Reduce Motion):
config.animation = JAPinAnimation(focus: .none, textEntry: .none, error: .none)
```

---

### JAPinAccessibility

Controls VoiceOver behaviour.

```swift
public struct JAPinAccessibility {
    public var announcesCompletion: Bool    // Post VoiceOver announcement when PIN is complete
    public var digitLabelFormat:    String  // Format string for per-cell label, e.g. "Digit %d of %d"
}
```

The format string receives two `Int` arguments: `(position, total)`. Example values:

| Format string | VoiceOver reads |
|---|---|
| `"Digit %d of %d"` | "Digit 1 of 4" |
| `"Position %d of %d"` | "Position 3 of 6" |
| `"OTP digit %d"` | "OTP digit 2" |

**Usage:**

```swift
var config = JAPinConfiguration.default
config.accessibility = JAPinAccessibility(
    announcesCompletion: true,
    digitLabelFormat: "OTP digit %d of %d"
)
```

---

## Public API

### Properties

```swift
// The text currently entered. Read-only; updated as the user types.
public private(set) var text: String

// True when text.count == configuration.pinLength
public var isComplete: Bool

// Disables the field and renders all cells in the .disabled state.
// Also sets isUserInteractionEnabled = false.
public var isDisabled: Bool

// Live configuration. Assigning a new value rebuilds the view if pinLength changed,
// or updates appearance only if pinLength is the same.
public var configuration: JAPinConfiguration

// Delegate for event callbacks (optional; closures are the alternative).
public weak var delegate: JAPinViewDelegate?
```

---

### Methods

```swift
// Make the hidden input field first responder (shows keyboard).
pinView.focus()

// Resign first responder (hides keyboard).
pinView.resignFocus()

// Clear all entered digits and reset error state.
pinView.clear()

// Manually trigger the error animation + haptic without clearing.
pinView.shake()

// Set or clear the error visual state without animation.
pinView.setErrorState(_ enabled: Bool)

// Show / hide a loading overlay (dims to 60% alpha, disables interaction).
pinView.setLoading(_ loading: Bool)

// Trigger the success haptic (medium impact). Called automatically by the
// validation coordinator on a successful async validation.
pinView.validationSucceeded()

// Trigger the error animation, then clear + refocus after 0.45 s.
// Called automatically by the validation coordinator on failure.
pinView.validationFailed()

// Attach an async validator closure. Invoked automatically once isComplete is true.
pinView.setValidator(_ validator: @escaping (String) async -> Bool)
```

---

### Closures

```swift
// Called every time the text changes (every keystroke).
pinView.onChange = { text in
    print("Current input:", text)
}

// Called once when text.count reaches pinLength.
// If a validator is attached, this fires before validation begins.
pinView.onComplete = { pin in
    print("Complete PIN:", pin)
}
```

---

### Async Validation

Attach a validator with `setValidator(_:)`. The view handles the entire lifecycle:

1. `onComplete` fires
2. `setLoading(true)` — dims the view
3. Your async closure runs (network call, local check, etc.)
4. On `true` → `setLoading(false)` + `validationSucceeded()` (success haptic)
5. On `false` → `setLoading(false)` + `validationFailed()` (shake + clear + refocus)

```swift
pinView.setValidator { pin async -> Bool in
    // Any async work — network, Keychain, local rules
    let result = try? await MyAuthService.verify(pin: pin)
    return result == true
}
```

You can swap the validator at any time (e.g. switching between "create PIN" and "verify PIN" steps):

```swift
// Step 1 — create
pinView.setValidator(creationValidator)

// Step 2 — verify
pinView.setValidator(verificationValidator)
```

---

## Delegate

Conform to `JAPinViewDelegate` for event callbacks. All methods are required by the protocol; implement empty bodies for those you don't need.

```swift
public protocol JAPinViewDelegate: AnyObject {

    // Called when the hidden input field becomes first responder.
    func pinViewDidBeginEditing(_ pinView: JAPinView)

    // Called on every keystroke (forward and backward).
    func pinView(_ pinView: JAPinView, didChangeText text: String)

    // Called once when text.count reaches pinLength.
    func pinView(_ pinView: JAPinView, didComplete text: String)

    // Called when the hidden input field resigns first responder.
    func pinViewDidEndEditing(_ pinView: JAPinView)
}
```

**Usage:**

```swift
class MyViewController: UIViewController, JAPinViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        pinView.delegate = self
    }

    func pinViewDidBeginEditing(_ pinView: JAPinView) { /* keyboard appeared */ }
    func pinView(_ pinView: JAPinView, didChangeText text: String) { /* each digit */ }
    func pinView(_ pinView: JAPinView, didComplete text: String) { verify(text) }
    func pinViewDidEndEditing(_ pinView: JAPinView) { /* keyboard dismissed */ }
}
```

---

## Custom Cell Style

Implement `JAPinCellStyle` and pass it to `JAPinStyle.custom(_:)` to take full control of each cell's appearance.

```swift
public protocol JAPinCellStyle {
    // Called every time a cell transitions to a new JAPinCellState.
    func apply(to view: UIView, state: JAPinCellState)
}
```

Your `apply(to:state:)` implementation receives the raw `UIView` for the cell and the new state. You can set any view or layer property — borders, backgrounds, shadows, sublayers, blur effects, gradients, etc.

**Example — gradient border cell:**

```swift
final class GradientBorderCellStyle: JAPinCellStyle {

    func apply(to view: UIView, state: JAPinCellState) {
        view.layer.cornerRadius = 12
        view.layer.borderWidth  = 0  // Use a gradient sublayer instead

        // Remove old gradient layer
        view.layer.sublayers?
            .filter { $0.name == "gradientBorder" }
            .forEach { $0.removeFromSuperlayer() }

        guard state == .focused else {
            view.layer.borderWidth = 1.5
            view.layer.borderColor = UIColor.systemGray4.cgColor
            return
        }

        let gradient = CAGradientLayer()
        gradient.name   = "gradientBorder"
        gradient.frame  = view.bounds
        gradient.colors = [UIColor.systemPurple.cgColor, UIColor.systemPink.cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint   = CGPoint(x: 1, y: 1)

        let shape = CAShapeLayer()
        shape.lineWidth   = 2
        shape.path        = UIBezierPath(roundedRect: view.bounds, cornerRadius: 12).cgPath
        shape.fillColor   = UIColor.clear.cgColor
        shape.strokeColor = UIColor.black.cgColor
        gradient.mask     = shape

        view.layer.addSublayer(gradient)
    }
}

// Usage:
var config = JAPinConfiguration.default
config.style = .custom(GradientBorderCellStyle())
pinView.configuration = config
```

Two concrete built-in styles are also provided for convenience:

| Type | Description |
|---|---|
| `JAPinBoxedCellStyle` | Configurable boxed style with per-state border colours |
| `JAPinUnderlinedCellStyle` | Bottom-line only; manages a named `CALayer` sublayer |

---

## Styles Reference

| Style | Border | Background | Best for |
|---|---|---|---|
| `.boxed` | All four sides | Transparent | General OTP, passcode |
| `.underlined` | Bottom only | None | Banking, fintech |
| `.rounded` | All sides, pill shape | Transparent | Consumer apps, playful UIs |
| `.filled` | None | Tinted per state | Cards, dark mode |
| `.custom(...)` | Your implementation | Your implementation | Brand-specific UI |

---

## Animation Types

| Type | Description | Recommended for |
|---|---|---|
| `.none` | No animation | Reduce Motion, testing |
| `.scale` | Spring pop (92% → 100%) | Focus events |
| `.bounce` | Overshoot scale (115% → 100%) | Text entry |
| `.fade` | Alpha 0 → 1 | Subtle entry, secure mode |
| `.shake` | Horizontal keyframe (CAKeyframeAnimation) | Error events |

---

## Cell States

Each cell is independently rendered based on its current `JAPinCellState`.

```swift
public enum JAPinCellState: Equatable {
    case empty     // No digit, field not focused here
    case focused   // Active cell — shows blinking cursor
    case filled    // Has a digit entered
    case error     // Validation failed
    case disabled  // isDisabled = true — alpha 0.5, no interaction
}
```

State transitions trigger animations only when the state actually changes (tracked via `previousState`), preventing redundant animations on every `updateUI` call.

---

## Examples

### Basic OTP

A 6-digit SMS verification screen with SMS autofill, a 30-second resend timer, and inline success/failure feedback.

```swift
var config = JAPinConfiguration.default
config.pinLength  = 6
config.style      = .boxed
config.behavior.enablesAutoFill = true   // Reads SMS code automatically
config.behavior.allowsPaste     = true
config.theme.focusedBorderColor = .systemIndigo
config.theme.filledBorderColor  = .systemIndigo
config.theme.cursorColor        = .systemIndigo

pinView.configuration = config

pinView.onComplete = { [weak self] otp in
    self?.verify(otp)
}
```

See `BasicOTPViewController.swift` for the complete implementation.

---

### Banking PIN

A 4-digit secure PIN with a create → confirm → verify flow, attempt limiting with lockout, and biometric authentication.

```swift
var config = JAPinConfiguration.default
config.style = .underlined
config.behavior = JAPinBehavior(
    keyboardType: .numberPad,
    isSecureEntry: true,
    secureSymbol: "●",
    autoFocus: true,
    autoSubmit: true,
    allowsPaste: false,       // Critical: never allow paste for PINs
    enablesAutoFill: false,   // No SMS autofill for PINs
    deleteBackwardMovesFocus: true
)

// Lock the field after too many failed attempts
if failedAttempts >= maxAttempts {
    pinView.isDisabled = true
}
```

See `BankingPINViewController.swift` for the complete implementation including `LocalAuthentication`.

---

### Theming Demo

An interactive gallery of all 5 styles with a live colour-theme picker, length stepper, and a `GlassmorphicCellStyle` custom renderer using `UIVisualEffectView`.

```swift
// Switch style at runtime — no VC reload needed
config.style = .filled
pinView.configuration = config

// Custom style with UIBlurEffect
config.style = .custom(GlassmorphicCellStyle())
pinView.configuration = config
```

See `ThemingDemoViewController.swift` for the complete implementation.

---

### Validation Demo

Three swappable async validators (Smart / Strict / Server-simulated) with a retry counter, progressive cooldown lockout, attempt history log, and a confetti `CAEmitterLayer` on success.

```swift
// Smart validator — bans common PINs and all-identical digits
pinView.setValidator { pin async -> Bool in
    let banned = ["1234", "0000", "1111"]
    guard !banned.contains(pin) else { return false }
    let digits = pin.map { $0.wholeNumberValue ?? 0 }
    return Set(digits).count > 1
}

// Swap validator for a different step without rebuilding the view
pinView.setValidator(strictValidator)
```

See `ValidationDemoViewController.swift` for the complete implementation.

---

### Accessibility Demo

A VoiceOver-first implementation that observes system accessibility notifications and rebuilds the PIN configuration in response.

```swift
// Observe system Reduce Motion preference
NotificationCenter.default.addObserver(
    forName: UIAccessibility.reduceMotionStatusDidChangeNotification,
    object: nil,
    queue: .main
) { [weak self] _ in
    self?.useReduceMotion = UIAccessibility.isReduceMotionEnabled
    self?.applyCurrentA11yConfiguration()
}

// Apply motion-safe animation types
config.animation = JAPinAnimation(
    focus:     useReduceMotion ? .fade  : .scale,
    textEntry: useReduceMotion ? .none  : .bounce,
    error:     useReduceMotion ? .none  : .shake
)

// Post VoiceOver announcement
UIAccessibility.post(
    notification: UIAccessibility.Notification.announcement,
    argument: "PIN entry complete"
)
```

See `AccessibilityDemoViewController.swift` for the complete implementation.

---

## File Structure

```
JAPinView/
├── JAPinView.swift                  Main view — entry point for all usage
├── JAPinConfiguration.swift         Top-level config struct (composes all below)
├── JAPinStyle.swift                 Enum: boxed | underlined | rounded | filled | custom
├── JAPinTheme.swift                 Per-state colours and border metrics
├── JAPinAppearance.swift            Font, spacing, corner radius, cursor dimensions
├── JAPinBehavior.swift              Keyboard, secure entry, paste, autofill flags
├── JAPinAnimation.swift             Per-event animation type selection
├── JAPinAnimator.swift              Concrete UIKit animation implementations
├── JAPinAccessibility.swift         VoiceOver label format + completion announcement
├── JAPinCellState.swift             Enum: empty | focused | filled | error | disabled
├── JAPinCellStyle.swift             Protocol for custom renderers + built-in styles
├── JAPinState.swift                 Enum: idle | editing | filled | error (view-level)
├── JAPinViewDelegate.swift          Protocol for begin/change/complete/end callbacks
├── JAPinValidationCoordinator.swift Async validation lifecycle manager
├── JAPinCursorAnimator.swift        CABasicAnimation blink controller
└── String+SafeIndex.swift           Safe Character subscript extension

Examples/
├── BasicOTPViewController.swift     SMS OTP with autofill and resend timer
├── BankingPINViewController.swift   Secure create → confirm → verify PIN flow
├── ThemingDemoViewController.swift  Live style/theme/length switcher gallery
├── ValidationDemoViewController.swift  Async validators, retry logic, confetti
└── AccessibilityDemoViewController.swift  VoiceOver, Dynamic Type, Reduce Motion
```

---

## Accessibility

JAPinView is built accessibility-first:

| Feature | Implementation |
|---|---|
| Per-cell VoiceOver label | `accessibilityLabel` set from `JAPinAccessibility.digitLabelFormat` |
| Cell value announced | `accessibilityValue` = `"filled"` or `"empty"` per state |
| Completion announcement | `UIAccessibility.post(notification: .announcement, ...)` when `announcesCompletion = true` |
| Container excluded | `isAccessibilityElement = false` on the container so VoiceOver navigates individual cells |
| Error announced | Error haptic + VoiceOver announcement on `validationFailed()` |
| Reduce Motion | Swap animation types to `.none` / `.fade` via `JAPinAnimation` |
| Dynamic Type | Use `UIFont.preferredFont(forTextStyle:)` in `JAPinAppearance.font` |
| High Contrast | Use adaptive `UIColor` with `UITraitCollection` in `JAPinTheme` |

> **Tip:** Set `config.accessibility.announcesCompletion = false` for banking PINs where announcing "PIN entry complete" aloud would be a security concern.

---

## License

```
Copyright (c) 2018 Jayachandra Agraharam <ajchandra15@gmail.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
```
